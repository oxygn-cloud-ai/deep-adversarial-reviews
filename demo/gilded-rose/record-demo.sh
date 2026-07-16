#!/usr/bin/env bash
# DARc Gilded Rose demo — recorded via asciinema in Docker
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear

# ── Title ──
echo -e "${BOLD}DARc — Deep Adversarial Review CLI${NC}"
echo "Iterative adversarial review: Claude self-review + OpenAI GPT-5.6 cross-model"
echo ""
sleep 1

# ── Show original code ──
echo -e "${CYAN}Target: gilded_rose.py (47 lines, 6 levels of nesting)${NC}"
echo ""
head -15 /demo/gilded_rose.py
echo "    ..."
echo ""
sleep 1

# ── Run /darc:1 ──
echo -e "${BOLD}$ /darc:1 gilded_rose.py${NC}"
sleep 1
echo ""

echo -e "${CYAN}═══ Round 1 (Self) — Claude adversarial review ═══${NC}"
sleep 1
echo ""

echo -e "${RED}CRITICAL${NC} — Missing Conjured item handling"
echo "  Evidence: No conditional for 'Conjured' in update_quality() (lines 8-36)"
echo "  Fix: Add conjured path — degrade by 2 (or 4 after sell-by)"
echo ""
sleep 1.5

echo -e "${RED}HIGH${NC} — Magic string anti-pattern"
echo "  Evidence: 'Aged Brie' repeated at lines 10, 27. 'Backstage passes' at 10, 17, 28."
echo "  Fix: Extract item name constants"
echo ""
sleep 1

echo -e "${RED}HIGH${NC} — Obscured quality reset"
echo "  Evidence: Line 33 — item.quality = item.quality - item.quality"
echo "  Fix: Replace with item.quality = 0"
echo ""
sleep 1

echo -e "${YELLOW}MEDIUM${NC} — Nesting depth of 6"
echo -e "${YELLOW}MEDIUM${NC} — Duplicate bounds checks (quality < 50 in 4 places)"
echo -e "${NC}LOW${NC} — No docstring or type hints"
echo ""
sleep 1

echo -e "${CYAN}6 findings total: 1 CRITICAL, 2 HIGH, 2 MEDIUM, 1 LOW${NC}"
echo ""
sleep 1.5

echo -e "${CYAN}═══ Round 1 (OpenAI GPT-5.6) — Cross-model verification ═══${NC}"
sleep 1
echo ""

echo -e "${RED}HIGH${NC} — Conjured items not implemented"
echo -e "${RED}HIGH${NC} — Quality invariants not enforced for arbitrary input"
echo -e "${YELLOW}MEDIUM${NC} — Behavior selected via fragile exact-name strings"
echo -e "${YELLOW}MEDIUM${NC} — Update logic deeply duplicated, hard to verify"
echo -e "${YELLOW}MEDIUM${NC} — Mutable public fields allow invariants to change at any time"
echo -e "${YELLOW}MEDIUM${NC} — No validation of item objects or field types"
echo -e "${NC}LOW${NC} — Magic values and duplicated literals obscure rules"
echo -e "${NC}LOW${NC} — Backstage expiration reset unnecessarily obscure"
echo -e "${NC}LOW${NC} — No tests cover boundary behavior"
echo ""
sleep 1.5

echo -e "${CYAN}9 findings total: 2 HIGH, 4 MEDIUM, 3 LOW${NC}"
echo ""
sleep 1

echo -e "${BOLD}═══ Round 1 Synthesis ═══${NC}"
echo ""
echo "Cross-model agreement: Conjured missing, magic strings, deep nesting."
echo "Cross-model complement: Self-review caught x-x code smell;"
echo "  OpenAI caught constructor validation + mutable-field risks."
echo "Neither model found everything alone."
echo ""
sleep 2

echo -e "${GREEN}15 findings across two model families.${NC}"
echo ""
sleep 1

# ── Show refactored code ──
echo -e "${BOLD}Applying fixes — strategy pattern refactoring${NC}"
sleep 1
echo ""
echo -e "  ${GREEN}✓${NC} Extracted named constants"
echo -e "  ${GREEN}✓${NC} Quality helpers (directional clamping)"
echo -e "  ${GREEN}✓${NC} Predicate functions for item classification"
echo -e "  ${GREEN}✓${NC} Strategy dispatch — one function per item type"
echo -e "  ${GREEN}✓${NC} Conjured items handled (case-insensitive)"
echo ""
sleep 1
echo "47 lines → 118 lines. 6 levels of nesting → 1."
echo ""
sleep 1

head -20 /demo/refactored.py
echo "    ..."
echo ""
sleep 1.5

# ── Round 2 — code-level pass, structural surfaces ──
echo -e "${BOLD}$ /darc:1 gilded_rose.py${NC}"
sleep 1
echo ""

echo -e "${CYAN}═══ Round 2 (OpenAI GPT-5.6) ═══${NC}"
sleep 1
echo ""

echo "Code-level: sell-in boundaries, quality caps, Sulfuras exemption,"
echo "  strategy precedence, Conjured detection — all correct."
echo ""
sleep 1

echo -e "${YELLOW}${BOLD}MEDIUM${NC}${YELLOW} — Sulfuras quality invariant is self-contradictory${NC}"
echo "  The spec says quality is both \"always 80\" AND \"never changes.\""
echo "  For non-80 input, these rules conflict. Code alone cannot resolve this."
echo ""
sleep 2

echo -e "${YELLOW}${BOLD}MEDIUM${NC}${YELLOW} — Quality bounds rely on caller discipline${NC}"
echo "  The constructor accepts any value. Spec says quality is never negative"
echo "  and never exceeds 50, but does not say whose job enforcement is."
echo ""
sleep 2

echo -e "${CYAN}0 CRITICAL, 0 HIGH, 2 MEDIUM${NC}"
echo ""
sleep 1

# ── Structural escalation ──
echo -e "${BOLD}═══ Structural Escalation ═══${NC}"
echo ""
echo "After 3+ rounds, DAR detects these are structural:"
echo "  they cannot be fixed in code alone."
echo ""
sleep 2

echo -e "${BOLD}Proposed resolutions:${NC}"
echo ""
echo "1. Sulfuras: require quality==80 at construction (reject otherwise)."
echo "   'Always 80' takes precedence over 'never changes.'"
echo ""
echo "2. Input validation: reject non-Sulfuras quality outside 0-50."
echo "   Fail fast — silent clamping hides caller errors."
echo ""
sleep 3

echo -e "${BOLD}Alternative perspectives:${NC}"
echo ""
echo "Perhaps 'never changes' was written for the common case"
echo "  and 'always 80' is the authoritative rule."
echo ""
echo "Consider whether the contradiction exists because Sulfuras"
echo "  was added after the other rules and never reconciled."
echo ""
echo "One perspective: if Sulfuras enters with quality 79, perhaps"
echo "  the real-world answer is 'that cannot happen' rather than"
echo "  'the code should handle it.'"
echo ""
sleep 4

echo -e "${BOLD}═══ Final Synthesis ═══${NC}"
echo ""
echo "Code-level: 15 findings → resolved."
echo "Structural: 2 findings → documented, resolutions proposed."
echo "Human decision required for the Sulfuras quality contract."
echo ""
sleep 2

echo -e "${GREEN}DAR does not rubber-stamp.${NC}"
echo ""
sleep 1

echo -e "${CYAN}DARc — Deep Adversarial Reviews${NC}"
echo "github.com/oxygn-cloud-ai/deep-adversarial-reviews"
echo ""
