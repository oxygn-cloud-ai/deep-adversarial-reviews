#!/usr/bin/env bash
# openai-review.sh — Deterministic Cycle 2 engine for 3cc-openai
# Calls OpenAI GPT-5.6 API with adversarial review prompt.
# Usage: openai-review.sh <target-file>
# Exit 0 = findings produced, Exit 1 = permanent failure (skip Cycle 2)
set -euo pipefail

TARGET="${1:-}"
[ -z "$TARGET" ] && { echo "ERROR: Usage: openai-review.sh <target-file>" >&2; exit 1; }
[ ! -f "$TARGET" ] && { echo "ERROR: file not found: $TARGET" >&2; exit 1; }
[ ! -s "$TARGET" ] && { echo "ERROR: file is empty" >&2; exit 1; }

# --- Encoding guard ---
if ! file -b "$TARGET" | grep -iqE 'text|JSON|markdown|ASCII|UTF-8|empty'; then
  echo "ERROR: not a text file — Cycle 2 skipped" >&2; exit 1
fi
if ! iconv -f UTF-8 "$TARGET" -t UTF-8 >/dev/null 2>&1; then
  echo "ERROR: file is not valid UTF-8 — Cycle 2 skipped" >&2; exit 1
fi

# --- API key guard ---
if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "ERROR: OPENAI_API_KEY not set — Cycle 2 skipped. Set it in your environment and re-run." >&2
  exit 1
fi
if [[ ! "$OPENAI_API_KEY" =~ ^sk- ]]; then
  echo "WARN: OPENAI_API_KEY does not start with 'sk-' — may be invalid" >&2
fi

# --- Read target (head+tail splice for large files, byte-aligned to UTF-8 boundaries) ---
SIZE=$(wc -c < "$TARGET")
TRUNCATED=false
if [ "$SIZE" -gt 81920 ]; then
  TRUNCATED=true
  echo "WARN: file is $SIZE bytes — sending head+tail only (40960 bytes each). Cycle 2 line numbers in tail portion will not match original file." >&2
  HEAD_CONTENT=$(head -c 40960 "$TARGET" | iconv -f UTF-8 -t UTF-8 -c 2>/dev/null)
  TAIL_CONTENT=$(tail -c 40960 "$TARGET" | iconv -f UTF-8 -t UTF-8 -c 2>/dev/null)
  CONTENT="${HEAD_CONTENT}"$'\n\n'"[... content truncated — $SIZE bytes total, showing first 40960 and last 40960 bytes ...]"$'\n\n'"${TAIL_CONTENT}"
else
  CONTENT=$(cat "$TARGET")
fi

# --- System prompt ---
SYSTEM_PROMPT="You are an adversarial reviewer. Find every flaw in the document below. Be deeply adversarial. Do not rubber-stamp. Report findings ranked by severity: CRITICAL > HIGH > MEDIUM > LOW. For each finding provide: (1) severity, (2) concrete evidence with section or line references, (3) recommended fix. If you find no flaws after thorough analysis, state 'No findings' with a brief justification of the areas checked."

# --- Call OpenAI with retry ---
FINDINGS=""
MAX_ATTEMPTS=3
TMP_BODY=$(mktemp)
TMP_HEADER=$(mktemp)
TMP_PAYLOAD=$(mktemp)
trap 'rm -f "$TMP_BODY" "$TMP_HEADER" "$TMP_PAYLOAD"' EXIT

# Write auth header to temp file (avoids API key in process argv / ps output)
printf 'Authorization: Bearer %s\n' "$OPENAI_API_KEY" > "$TMP_HEADER"

# Build JSON payload to temp file
jq -n \
  --arg system "$SYSTEM_PROMPT" \
  --arg content "$CONTENT" \
  '{
    model: "gpt-5.6",
    messages: [
      {role: "system", content: $system},
      {role: "user", content: $content}
    ],
    max_completion_tokens: 32000
  }' > "$TMP_PAYLOAD"

for attempt in $(seq 1 $MAX_ATTEMPTS); do
  HTTP_CODE=$(curl -sS --max-time 180 -w '%{http_code}' \
    -o "$TMP_BODY" \
    -H "Content-Type: application/json" \
    -H "@${TMP_HEADER}" \
    -d "@${TMP_PAYLOAD}" \
    https://api.openai.com/v1/chat/completions 2>/dev/null)

  if [ "$HTTP_CODE" = "200" ]; then
    BODY=$(cat "$TMP_BODY")
    FINISH=$(echo "$BODY" | jq -r '.choices[0].finish_reason // "unknown"')
    FINDINGS=$(echo "$BODY" | jq -r '.choices[0].message.content // ""')
    if [ "$FINISH" = "length" ]; then
      echo "WARN: OpenAI response truncated (finish_reason=length). Consider splitting the file." >&2
    fi
    break
  fi

  # Log error body for diagnostics
  if [ -s "$TMP_BODY" ]; then
    echo "DEBUG: API response body: $(cat "$TMP_BODY" | jq -r '.error.message // "non-JSON response"' 2>/dev/null || head -c 200 "$TMP_BODY")" >&2
  fi

  # Permanent failures — do not retry
  case "$HTTP_CODE" in
    401|403)
      echo "ERROR: OpenAI auth failed (HTTP $HTTP_CODE). Check OPENAI_API_KEY." >&2
      exit 1
      ;;
    400|404)
      echo "ERROR: OpenAI request failed (HTTP $HTTP_CODE). Model or endpoint may be invalid." >&2
      exit 1
      ;;
  esac

  # Transient failures — retry with backoff
  if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
    echo "WARN: OpenAI API attempt $attempt failed (HTTP $HTTP_CODE). Retrying in $((2 ** attempt))s..." >&2
    sleep $((2 ** attempt))
  fi
done

if [ -z "${FINDINGS:-}" ]; then
  echo "ERROR: OpenAI API failed after $MAX_ATTEMPTS attempts — Cycle 2 skipped." >&2
  exit 1
fi

printf '%s\n' "$FINDINGS"
