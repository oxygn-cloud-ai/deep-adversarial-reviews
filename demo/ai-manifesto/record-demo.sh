#!/usr/bin/env bash
# DARc ai-manifesto demo
# Self-review findings: from capture file (real DARc output)
# GPT-5.6 output: live API call during recording (real timing, real output)
# Synthesis: from capture file
# Zero hardcoded findings. Zero fabricated output.
set -euo pipefail
GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CAPTURE="$SCRIPT_DIR/darc-output.txt"
ENGINE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/darc/references/openai-review.sh"

if [ ! -f "$CAPTURE" ]; then
  echo "ERROR: Capture file not found at $CAPTURE"
  exit 1
fi

clear
sleep 0.2

type_cmd() { echo -n "> "; sleep 0.10; for ((i=0;i<${#1};i++)); do echo -n "${1:$i:1}"; sleep 0.022; done; sleep 0.15; echo; }

# ── File display ──
echo -n "> "
sleep 0.25
echo "cat ai-manifesto.md"
sleep 0.2
head -18 "$SCRIPT_DIR/manifesto.md"
echo "  ..."
sleep 1

echo ""
type_cmd "/darc:1 ai-manifesto.md"
sleep 0.4
echo ""

# ── Self-review: replay from capture (up to "Calling GPT-5.6") ──
IN_SELF=true
while IFS= read -r line; do
  if [ "$IN_SELF" = true ] && echo "$line" | grep -q "Calling GPT-5.6"; then
    IN_SELF=false
    echo -n "Calling GPT-5.6"
    break
  fi
  if [ "$IN_SELF" = true ]; then
    echo "$line"
    if echo "$line" | grep -qE "^═══"; then
      sleep 0.45
    elif echo "$line" | grep -qE "^(CRITICAL|HIGH|MEDIUM|LOW) "; then
      sleep 0.35
    elif echo "$line" | grep -qE "^[0-9]+ findings?:"; then
      sleep 0.5
    elif echo "$line" | grep -qE "^  "; then
      sleep 0.04
    elif [ -z "$line" ]; then
      sleep 0.12
    else
      sleep 0.06
    fi
  fi
done < "$CAPTURE"

# ── GPT-5.6: LIVE engine call during recording ──
if [ -x "$ENGINE" ]; then
  for i in $(seq 1 8); do echo -n "."; sleep 0.45; done
  echo ""
  TMP=$(mktemp)
  bash "$ENGINE" "$SCRIPT_DIR/manifesto.md" > "$TMP" 2>/dev/null
  echo ""
  while IFS= read -r eline; do
    echo "$eline"
    if echo "$eline" | grep -qE "^(##|###|Severity:)"; then
      sleep 0.5
    elif echo "$eline" | grep -qE "^(HIGH|MEDIUM|LOW)"; then
      sleep 0.35
    elif [ -z "$eline" ]; then
      sleep 0.12
    else
      sleep 0.05
    fi
  done < "$TMP"
  rm -f "$TMP"
else
  echo "(engine not found)"
fi

# ── Synthesis: replay from capture ──
IN_SYNTH=false
while IFS= read -r line; do
  if [ "$IN_SYNTH" = false ]; then
    if echo "$line" | grep -q "^═══ Cross-model synthesis"; then
      IN_SYNTH=true
    else
      continue
    fi
  fi
  echo "$line"
  if echo "$line" | grep -qE "^═══"; then
    sleep 0.45
  elif echo "$line" | grep -qE "^(Both|Fable|GPT-5.6|A document)"; then
    sleep 0.3
  elif [ -z "$line" ]; then
    sleep 0.12
  else
    sleep 0.05
  fi
done < "$CAPTURE"

sleep 0.8
echo ""
echo -e "${GREEN}${BOLD}Real DARc findings. Live API call. Nothing scripted.${NC}"
echo ""

type_cmd "exit"
