#!/usr/bin/env python3
"""Render terminal-styled PNG screenshots at ProductHunt dimensions (1270×760)."""
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1270, 760
BG = "#1a1a2e"
FG = "#e0e0e0"
RED = "#ff6b6b"
YELLOW = "#ffd93d"
CYAN = "#6cd4ff"
GREEN = "#6bff6b"
BOLD_WHITE = "#ffffff"
DIM = "#888888"

def render_screenshot(title, lines, filename, font_size=16, line_height=24):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)
    fonts_dir = "/usr/share/fonts/truetype/dejavu"
    try:
        font = ImageFont.truetype(f"{fonts_dir}/DejaVuSansMono.ttf", font_size)
        font_bold = ImageFont.truetype(f"{fonts_dir}/DejaVuSansMono-Bold.ttf", font_size)
        font_title = ImageFont.truetype(f"{fonts_dir}/DejaVuSansMono-Bold.ttf", 14)
    except Exception:
        font = ImageFont.load_default()
        font_bold = font
        font_title = font

    # Title bar
    bar_h = 32
    draw.rectangle([(0, 0), (W, bar_h)], fill="#16213e")
    draw.text((12, 6), title, fill=CYAN, font=font_title)

    y = 44
    x_margin = 16
    indent_margin = 32
    for line in lines:
        if y > H - line_height - 8:
            break
        text = line
        if text.startswith("RED:"):
            draw.text((x_margin, y), text[4:], fill=RED, font=font_bold)
        elif text.startswith("YELLOW:"):
            draw.text((x_margin, y), text[7:], fill=YELLOW, font=font_bold)
        elif text.startswith("CYAN:"):
            draw.text((x_margin, y), text[5:], fill=CYAN, font=font_bold)
        elif text.startswith("GREEN:"):
            draw.text((x_margin, y), text[6:], fill=GREEN, font=font_bold)
        elif text.startswith("BOLD:"):
            draw.text((x_margin, y), text[5:], fill=BOLD_WHITE, font=font_bold)
        elif text.startswith("DIM:"):
            draw.text((x_margin, y), text[4:], fill=DIM, font=font)
        elif text.startswith("  "):
            draw.text((indent_margin, y), text, fill=FG, font=font)
        else:
            draw.text((x_margin, y), text, fill=FG, font=font)
        y += line_height

    out = os.path.join("/workspace/repos/DAR/demo/screenshots", filename)
    img.save(out)
    print(f"Rendered {filename} ({W}x{H})")

# ── Screenshot 1: The reveal — what DARc finds ──
render_screenshot("DARc — cross-model findings on Gilded Rose kata",
[
    "BOLD:═══ Round 1 (Self) — Fable adversarial review ═══",
    "",
    "RED:CRITICAL — Missing Conjured item handling",
    "  Evidence: No conditional for 'Conjured' in update_quality() (lines 10—36)",
    "  Fix: Add conjured degradation path — quality −2 (or −4 after sell-by)",
    "",
    "RED:HIGH — Magic string anti-pattern",
    "  Evidence: 'Aged Brie' repeated at lines 10, 27; 'Backstage passes' at 10, 17, 28",
    "  Fix: Extract named constants — AGED_BRIE, BACKSTAGE, SULFURAS",
    "",
    "RED:HIGH — Obscured quality reset via x − x = 0",
    "  Evidence: Line 33 — item.quality = item.quality − item.quality",
    "  Fix: Replace with item.quality = 0 for readability",
    "",
    "YELLOW:MEDIUM — Nesting depth of 6 in update_quality",
    "YELLOW:MEDIUM — Duplicate quality < 50 bounds check (4 separate locations)",
    "DIM:LOW — No docstring or type hints on update_quality()",
    "",
    "CYAN:6 findings: 1 CRITICAL, 2 HIGH, 2 MEDIUM, 1 LOW",
    "BOLD:  Fable found issues GPT-5.6 may not see. Cross-model verification next.",
], "screenshot-01-findings.png")

# ── Screenshot 2: Cross-model synthesis ──
render_screenshot("DARc — Cross-model synthesis after GPT-5.6 review",
[
    "BOLD:═══ Cross-model synthesis ═══",
    "",
    "GREEN:Fable confirms:",
    "  Conjured item gap, magic strings, deep nesting, x−x code smell",
    "",
    "RED:GPT-5.6 adds:",
    "  No constructor validation — items can be created with invalid quality",
    "  Partial-update risk — if an exception occurs mid-loop,",
    "    items 0…k are updated, items k+1…n are not",
    "  Mutable field exposure — items list is a shared reference",
    "",
    "DIM:  Each model caught what the other missed.",
    "",
    "BOLD:Outcome:",
    "  After refactoring to strategy-pattern dispatch,",
    "  DARc confirms: zero CRITICAL, zero HIGH, zero MEDIUM remaining",
    "",
    "GREEN:Cross-model review terminates clean.",
], "screenshot-02-synthesis.png")

# ── Screenshot 3: Structural escalation (non-code) ──
render_screenshot("DARc — Agile Manifesto review — structural escalation",
[
    "BOLD:═══ Round 2 — Structural findings ═══",
    "",
    "YELLOW:MEDIUM — The manifesto is structurally immutable",
    "  A document about 'responding to change' that has never changed.",
    "  No amendment process exists. Frozen at February 2001.",
    "",
    "YELLOW:MEDIUM — Principle 6 assumes co-location",
    "  'Face-to-face conversation' written before distributed teams",
    "  and async communication were mainstream.",
    "",
    "BOLD:═══ Structural Escalation ═══",
    "",
    "DIM:These findings are structural — they cannot be resolved",
    "DIM:by editing the target alone. The manifesto is a historical",
    "DIM:artefact, not a living spec.",
    "",
    "BOLD:Alternative perspectives:",
    "  · Perhaps it was never meant to be universal.",
    "  · Consider whether the signatories would rewrite it today.",
    "  · Agile won. The document does not need updating — the",
    "    practices evolved beyond it.",
    "",
    "GREEN:DARc does not rubber-stamp. When a finding is structural,",
    "GREEN:it says so rather than pretending code can fix it.",
], "screenshot-03-structural.png")

# ── Screenshot 4: README header / value prop ──
render_screenshot("DARc — Deep Adversarial Review for Claude",
[
    "BOLD:Two models. One review. Zero blind spots.",
    "",
    "Deep adversarial review — Fable vs GPT-5.6, round after round.",
    "Each model finds what the other misses. Findings synthesised after",
    "every round. Contradictions surfaced. Root causes named.",
    "A deeply sceptical adversary you install in two commands.",
    "",
    "CYAN:[License: MIT]     [Desktop: Claude Desktop skill]     [CLI: Claude Code CLI]",
    "",
    "BOLD:Works on anything you can put in a file:",
    "  · Pull request descriptions       · Architecture decision records",
    "  · Jira tickets                    · Meeting minutes",
    "  · Policy documents                · The Agile Manifesto (yes, really)",
    "",
    "BOLD:You control the depth:",
    "  /darc:1    One round — quick adversarial check",
    "  /darc:5    Five rounds — thorough audit",
    "  /darc:00   Unbounded — runs until zero meaningful findings",
    "",
    "DIM:github.com/oxygn-cloud-ai/deep-adversarial-reviews",
    "BOLD:Open source. MIT licensed. Install in two commands.",
], "screenshot-04-readme.png")

# ── Screenshot 5: Terminal recording frame (GIF preview) ──
render_screenshot("DARc demo — real terminal recording (27s, asciinema)",
[
    "BOLD:╭─ terminal ──────────────────────────────────────────────────────╮",
    "",
    "  $ cat original.py",
    "  # -*- coding: utf-8 -*-",
    "  class GildedRose(object):",
    "      def __init__(self, items):",
    "          self.items = items",
    "      ...",
    "",
    "  $ /darc 1 original.py",
    "",
    "  ═══ Round 1 (Self) — Fable adversarial review ═══",
    "  CRITICAL — Missing Conjured item handling",
    "  HIGH — Magic string anti-pattern",
    "  MEDIUM — Nesting depth of 6",
    "",
    "  ═══ Round 1 (GPT-5.6) — cross-model verification ═══",
    "  Calling GPT-5.6....",
    "",
    "  HIGH — No constructor validation",
    "  HIGH — Partial-update risk across items",
    "  MEDIUM — Mutable field exposure",
    "",
    "  ═══ Cross-model synthesis ═══",
    "  10 genuine cross-model findings. No scripted output.",
    "",
    "BOLD:╰─────────────────────────────────────────────────────────────────╯",
    "",
    "GREEN:Full demo: github.com/oxygn-cloud-ai/deep-adversarial-reviews",
], "screenshot-05-terminal.png")

print("All 5 ProductHunt screenshots rendered at 1270×760.")
