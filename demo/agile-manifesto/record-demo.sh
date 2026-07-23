#!/usr/bin/env bash
# DARc Agile Manifesto demo — recorded via asciinema in Docker
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear

echo -e "${BOLD}DARc — Deep Adversarial Review for Claude${NC}"
echo "Fable vs GPT-5.6, round after round"
echo ""
sleep 1

echo -e "${CYAN}Target: The Agile Manifesto (2001)${NC}"
echo "4 values, 12 principles, 17 signatories. The most influential"
echo "software development document of its generation."
echo ""
sleep 1.5

echo -e "${CYAN}Why review this?${NC}"
echo "Signed in 2001. Pre-remote. Pre-regulatory. Pre-AI."
echo "Written by 17 white men at a ski resort."
echo "Never amended, never updated, never adversarially reviewed."
echo "Until now."
echo ""
sleep 2

echo -e "${BOLD}$ /darc:1 manifesto.md${NC}"
sleep 1
echo ""

echo -e "${CYAN}═══ Round 1 (Self) — Fable adversarial review ═══${NC}"
sleep 1
echo ""

echo -e "${RED}HIGH${NC} — Principle 6 assumes co-location"
echo "  'Face-to-face conversation' as the most efficient method was"
echo "  written before distributed teams, async communication, and"
echo "  remote work were mainstream. Unaddressed for 20+ years."
echo ""
sleep 2

echo -e "${RED}HIGH${NC} — 'Working software over documentation' contradicts"
echo "  regulated industries (finance, healthcare, aerospace)"
echo "  Evidence: Value #2 elevates software over docs. Principle #7"
echo "  says working software is the PRIMARY measure of progress."
echo "  Neither acknowledges that some industries cannot operate this way."
echo ""
sleep 2.5

echo -e "${YELLOW}MEDIUM${NC} — Signatory homogeneity"
echo "  17 authors, all male, all from the same era and geography."
echo "  The manifesto claims universality but was authored by a single"
echo "  demographic. No mechanism for revision or challenge."
echo ""
sleep 2

echo -e "${YELLOW}MEDIUM${NC} — Principle 10 vs Principle 9 tension"
echo "  'Maximize work not done' and 'continuous attention to"
echo "  technical excellence' pull in opposite directions."
echo "  No guidance on where the boundary lies."
echo ""
sleep 2

echo -e "${NC}LOW${NC} — No definition of 'working software'"
echo -e "${NC}LOW${NC} — 'Sustainable pace' has no metric"
echo -e "${NC}LOW${NC} — 'Self-organizing teams' undefined"
echo ""
sleep 1.5

echo -e "${CYAN}8 findings: 2 HIGH, 2 MEDIUM, 3 LOW${NC}"
echo ""
sleep 1

echo -e "${CYAN}═══ Round 1 (GPT-5.6) — Cross-model verification ═══${NC}"
sleep 1
echo ""

echo -e "${RED}HIGH${NC} — The manifesto is structurally immutable"
echo "  No amendment process exists. The text is frozen at February 2001."
echo "  This is itself a contradiction: a document about 'responding to"
echo "  change' that has never changed."
echo ""
sleep 2.5

echo -e "${RED}HIGH${NC} — 'Customer' is undefined and overloaded"
echo "  Used in principles #1, #2, #3. Is the customer the person paying,"
echo "  the end user, or the product owner? Different interpretations"
echo "  produce different behaviours."
echo ""
sleep 2.5

echo -e "${YELLOW}MEDIUM${NC} — Principle #4 assumes business-people availability"
echo -e "${YELLOW}MEDIUM${NC} — No mention of security, privacy, or compliance"
echo -e "${NC}LOW${NC} — 'Preference to the shorter timescale' has no floor"
echo ""
sleep 1.5

echo -e "${CYAN}5 findings: 2 HIGH, 2 MEDIUM, 1 LOW${NC}"
echo ""
sleep 1

echo -e "${BOLD}═══ Round 1 Synthesis ═══${NC}"
echo ""
echo "Cross-model agreement: Both models identified the immutability"
echo "  paradox — a document about change that refuses to change."
echo ""
echo "Cross-model complement: Fable caught the co-location assumption."
echo "  GPT-5.6 caught the undefined 'customer' and the absence of"
echo "  security/privacy in a document about building software."
echo ""
sleep 3

echo -e "${GREEN}13 findings across two model families.${NC}"
echo ""
sleep 1

echo -e "${BOLD}═══ Structural Escalation ═══${NC}"
echo ""
echo "The manifesto cannot be 'fixed' by editing it. It is a historical"
echo "document, not a living spec. The findings are structural:"
echo ""
echo "  The immutability paradox is inherent."
echo "  The co-location assumption is a product of its era."
echo "  The regulatory blindness is a scope limitation, not an error."
echo ""
sleep 3

echo -e "${BOLD}Alternative perspectives:${NC}"
echo ""
echo "Perhaps the manifesto was never meant to be universal — it was a"
echo "  reaction to heavyweight 1990s processes, not a prescription for"
echo "  all software development forever."
echo ""
echo "Consider whether the signatories would rewrite it today."
echo "  Remote-first, AI-augmented, regulated. Would 'face-to-face'"
echo "  survive? Would 'working software' still trump documentation in"
echo "  a world of compliance audits?"
echo ""
echo "One perspective: the manifesto succeeded. Agile won. The document"
echo "  does not need updating — the practices evolved beyond it."
echo "  The manifesto is a snapshot, not a constitution."
echo ""
sleep 4

echo -e "${BOLD}═══ Final Synthesis ═══${NC}"
echo ""
echo "Code-level: 13 findings documented."
echo "Structural: The immutability paradox is the manifesto's identity."
echo "Human decision required: is this a document to be reviewed or"
echo "  a historical artefact to be understood in context?"
echo ""
sleep 2

echo -e "${GREEN}DARc does not rubber-stamp — even on the Agile Manifesto.${NC}"
echo ""
sleep 1

echo -e "${CYAN}DARc — Deep Adversarial Review for Claude${NC}"
echo "github.com/oxygn-cloud-ai/deep-adversarial-reviews"
echo ""
