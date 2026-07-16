# DAR — Deep Adversarial Reviews

**Catch bugs your reviewers miss.** DAR pits Claude against GPT-5.6 in adversarial
review rounds — two model families, one target, zero blind spots. AI-powered code
review that finds flaws before they become bugs.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Desktop](https://img.shields.io/badge/Platform-Claude_Desktop-d97706)](https://claude.ai/download)
[![Claude Code CLI](https://img.shields.io/badge/Platform-Claude_Code_CLI-2563eb)](https://docs.anthropic.com/en/docs/claude-code/overview)

**New in v1.1:** Gilded Rose asciicast demo. Structural escalation prevents infinite loops on unfixable findings. `/DAR:00` no-cap mode. `/DAR:0` asks whether to continue at 20 rounds. `/goal` skill integration.

---

## Why DAR?

Single-model reviews have a blind spot: the same model that wrote the code
(or similar training data) reviews it. **Manual review misses ~15% of bugs. Single-model
AI review catches different things than cross-model review.** DAR crosses model
families — Claude (Anthropic) performs self-review, then OpenAI GPT-5.6 provides an
independent adversarial perspective. Findings from both models are synthesised after
every round. Rounds repeat until your quality bar is met.

**The result:** fewer false negatives, deeper edge-case coverage, and review
quality that scales with the number of rounds you choose. If you currently review
code manually or with a single AI assistant, DAR finds what both approaches miss.

---

## See It in Action

DAR reviewed the <a href="https://github.com/emilybache/GildedRose-Refactoring-Kata" target="_blank" rel="noopener">Gilded Rose kata</a> — the most famous refactoring exercise in software. Two model families, two rounds, 15 findings resolved to zero.

[![asciicast](https://asciinema.org/a/SF3I3ZgkUP0OAYYc.svg)](https://asciinema.org/a/SF3I3ZgkUP0OAYYc)

| | Original | After DAR |
|---|---|---|
| Lines | 47 | 118 |
| Nesting | 6 levels | 1 level |
| Findings | 15 | 0 |

[View the demo code →](demo/gilded-rose/)

**Cycle 1 (self-review) works offline with no API key.** Install DAR, skip `OPENAI_API_KEY`, and run `/DAR my-file.md` for a full Claude self-review. Add the key when you want GPT-5.6 cross-model verification.

---

## Which One Should I Use?

| You use… | Install this | Because |
|-----------|-------------|---------|
| **Claude Desktop** (the app) | `/DAR` — download `DAR.zip` | Desktop skills are .zip files |
| **Claude Code CLI** (the terminal) | `/DARc` — clone + `install.sh` | CLI skills use the router system |

Both do exactly the same thing. Same engine, same rounds, same output.

---

## Quick Start

### Claude Desktop

1. Download `DAR.zip` from the <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/releases" target="_blank" rel="noopener">latest release</a>
2. Unzip into `~/.claude/skills/DAR/`
3. `chmod +x ~/.claude/skills/DAR/references/openai-review.sh`
4. (Optional) Set `OPENAI_API_KEY` for cross-model review. Skip for self-review only.
5. Restart Claude Desktop
6. Type: "run DAR on my design doc"

### Claude Code CLI

```bash
git clone https://github.com/oxygn-cloud-ai/deep-adversarial-reviews.git
cd deep-adversarial-reviews/skills/darc && bash install.sh
# Optional: export OPENAI_API_KEY="sk-..." for cross-model review
/DARc my-file.md
```

---

## Usage

| Command | Rounds | Behaviour |
|---------|--------|-----------|
| `/DAR` | 3 | Classic 3-cycle: self → OpenAI → synthesis |
| `/DAR:5` | 5 | Five rounds, each: self → OpenAI → round synthesis. Final synthesis after all rounds |
| `/DAR:1` | 1 | One self round + one OpenAI round + synthesis |
| `/DAR:0` | Unbounded | Repeats until zero CRITICAL/HIGH/MEDIUM findings. Safety cap at 20 rounds — asks user whether to continue |
| `/DAR:00` | No cap | Repeats until zero CRITICAL/HIGH/MEDIUM findings with `/goal` tracking. No upper limit. Structural escalation prevents infinite loops |
| `/DAR:9` | 9 | Maximum user-specified rounds |

**Claude Code CLI:** same pattern with `/DARc`, `/DARc:5`, `/DARc:0`, `/DARc:00`, etc.

---

## How It Works

### Each Round

1. **Claude Self-Review** — Claude reads the target file, adopts a deeply adversarial stance, documents every finding with severity (CRITICAL/HIGH/MEDIUM/LOW), concrete evidence, and a recommended fix.

2. **OpenAI GPT-5.6 Cross-Model Review** — A deterministic script (`references/openai-review.sh`) sends the target file to OpenAI's API with an adversarial review system prompt. The response is reformatted to match the self-review style.

3. **Round Synthesis** — Both sets of findings are compared. Contradictions are resolved. Root causes are identified. The target is updated with cumulative fixes.

### After All Rounds

**Final Synthesis** — summary statistics across all rounds, root causes, resolution of any remaining contradictions, and a list of unresolved items requiring human input.

### Unbounded Mode (`/DAR:0` and `/DAR:00`)

**`/DAR:0`** — Rounds repeat until zero CRITICAL, HIGH, or MEDIUM findings remain. Safety cap at 20 rounds, after which DAR asks whether to continue (one round at a time). Invokes the `/goal` skill to track progress toward the quality target.

**`/DAR:00`** — No safety cap. Runs until zero CRITICAL, HIGH, or MEDIUM findings remain, tracking progress via the `/goal` skill. No upper limit — runs until the goal is met.

LOW findings are tracked but do not prevent completion in either mode.

---

## Architecture

```
references/
  openai-review.sh           — Shared Cycle 2 engine (both skills)

skills/dar/                  — Claude Desktop skill
  SKILL.md                   —   YAML frontmatter + process instructions
  references/ -> ../../references/  — Symlink to shared engine

skills/darc/                 — Claude Code CLI skill
  SKILL.md                   —   Full skill definition with routing
  install.sh                 —   One-command installer
  references/ -> ../../references/  — Symlink to shared engine
```

The `openai-review.sh` script: validates input, guards API keys, handles large files (>80KB head+tail), calls GPT-5.6 with 32K output tokens, retries with backoff, stores API key in temp file (0600, deleted on exit — never in process argv).

---

## Requirements

- **OpenAI API key:** `OPENAI_API_KEY` environment variable. <a href="https://platform.openai.com/api-keys" target="_blank" rel="noopener">platform.openai.com/api-keys</a>
- **System tools:** `curl`, `jq`, `file`, `iconv`, `seq` — standard on macOS/Linux
- **Claude Desktop** (for `/DAR`) or **Claude Code CLI** (for `/DARc`)

---

## Privacy

**Cycle 2 uploads target file content to OpenAI's API.** Do not use on files containing secrets, credentials, or PII. Transmitted over HTTPS under <a href="https://openai.com/policies/api-data-usage-policies" target="_blank" rel="noopener">OpenAI's data usage policy</a>.

---

## Security

- API key never in process listings — temp file 0600, curl `-H @file`, deleted on exit
- All shell variables quoted — no command injection
- `jq --arg` JSON-escapes user content
- Script exits cleanly on failure — no partial writes or dangling temp files
- Uses `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` — no hardcoded paths
- No secrets in source — env var references only

---

## FAQ

**Why two skills?** Desktop and CLI have different skill systems. DAR = `.zip` for Desktop. DARc = CLI format with router.

**Why OpenAI?** Cross-model verification. Different model families catch things same-family instances miss.

**Different model?** Edit `model: "gpt-5.6"` in `references/openai-review.sh`.

**API fails?** Non-fatal. Round skipped, synthesis continues with self-review only.

**Offline?** Cycle 1 works offline. Cycle 2 needs internet.

---

## License

<a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener">MIT</a>.

---

## Contributing

This repo is the public distributable face of a private BUILD repo. PRs welcome for documentation fixes and skill improvements to `skills/` and `references/`.

Full technical documentation: <a href="https://oxygn.atlassian.net/wiki/spaces/Tools/pages/38469638/DAR+Technical+Reference" target="_blank" rel="noopener">DAR Technical Reference</a> (Confluence)

---

## Support

DAR is built and maintained by one person who pays the OpenAI bills. If it catches a bug that would have ruined your Friday, a coffee keeps the rounds running. ☕

<a href="https://donate.stripe.com/aFa14n9dq6cy78lcq30ZW00" target="_blank" rel="noopener">Buy me a coffee</a>

<a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=enhancement" target="_blank" rel="noopener">Request a feature</a> · <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=bug" target="_blank" rel="noopener">Report a bug</a> · <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=question" target="_blank" rel="noopener">Ask for help</a>

