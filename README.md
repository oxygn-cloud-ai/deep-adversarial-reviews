# DARc — Deep Adversarial Review for Claude

**Deep adversarial review — Fable vs GPT-5.6, round after round.** Two AI models,
one target, zero blind spots. Each finds what the other misses, synthesised after
every round. A deeply sceptical adversary.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Desktop](https://img.shields.io/badge/Platform-Claude_Desktop-d97706)](https://claude.ai/download)
[![Claude Code CLI](https://img.shields.io/badge/Platform-Claude_Code_CLI-2563eb)](https://docs.anthropic.com/en/docs/claude-code/overview)

**New in v1.1:** Fable vs GPT-5.6 on the Gilded Rose kata — two models tear through the most famous refactoring exercise in software. Structural escalation. `N=00` no-cap mode. `/goal` skill integration.

---

## Why DARc?

Single-model reviews share blind spots — same training data, same assumptions, same
gaps. **DARc crosses model families.** Fable (Anthropic) performs self-review with a
deeply adversarial stance. GPT-5.6 (OpenAI) provides an independent adversarial
perspective. Findings from both are synthesised after every round. Rounds repeat until
your quality bar is met — or until DARc tells you the remaining issues are structural
and offers alternative perspectives.

**The result:** deeper coverage, fewer false negatives, and review quality that
scales with the number of rounds you choose.

### Beyond code

DARc reviews anything you can put in a file. Every example below benefits from
a deeply sceptical adversary checking your work before it meets the real world:

- **Pull request descriptions** — does the PR body actually match the diff? Are
  breaking changes documented? Do the acceptance criteria cover the edge cases?
- **Architecture decision records** — have you considered the counter-argument?
  Does the decision hold under the stated constraints five minutes, five months,
  and five years from now?
- **Jira tickets** — are the acceptance criteria unambiguous? Can two different
  implementers read them and build the same thing? Does the ticket contradict
  the epic?
- **Meeting minutes** — did you actually capture all decisions? Are action items
  assigned to people who were in the room?
- **Policy documents** — does section 3.2 contradict section 7.4? Is every
  "must" enforceable? Are edge cases silently unaddressed?
- **The AI Manifesto** — five principles for responsible AI use, 87 signatories.
  8 findings across both models — enforcement vacuum, principle contradiction,
  data-safeguard gap. [View the demo →](demo/ai-manifesto/)

---

## Demos

- **Gilded Rose kata** — 47-line refactoring classic. 9 findings (1 CRITICAL, 2 HIGH, 4 MEDIUM, 2 LOW). [View the demo →](demo/gilded-rose/)
- **AI Manifesto** — Document about responsible AI, adversarially reviewed by AI. [View the demo →](demo/ai-manifesto/)

**Cycle 1 (self-review) works offline with no API key.** Install DARc, skip `OPENAI_API_KEY`, and run `/DARc my-file.md` for a full Claude self-review. Add the key when you want GPT-5.6 cross-model verification.

---

## Which One Should I Use?

| You use… | Install this | Because |
|-----------|-------------|---------|
| **Claude Desktop** (the app) | `/DARc` — download `DARc.zip` | Desktop skills are .zip files |
| **Claude Code CLI** (the terminal) | `/DARc` — clone + `install.sh` | CLI skills use the router system |

Both do exactly the same thing. Same engine, same rounds, same output.

---

## Quick Start

### Claude Desktop

1. Download `DARc.zip` from the <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/releases" target="_blank" rel="noopener">latest release</a>
2. Unzip into `~/.claude/skills/DARc/`
3. `chmod +x ~/.claude/skills/DARc/references/openai-review.sh`
4. (Optional) Set `OPENAI_API_KEY` for cross-model review. Skip for self-review only.
5. Restart Claude Desktop
6. Type: "run DARc on my design doc"

### Claude Code CLI

```bash
git clone https://github.com/oxygn-cloud-ai/deep-adversarial-reviews.git
cd deep-adversarial-reviews/skills/darc && bash install.sh
# Optional: export OPENAI_API_KEY="sk-..." for cross-model review
/DARc
```

**Important:** The install script writes the `/darc` command to `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/commands/`. If `CLAUDE_CONFIG_DIR` is set to a non-home path (e.g. `/workspace/.claude`), the command is only available within that project scope. The installer (v1.0.1+) now automatically symlinks into `~/.claude/commands/` so `/darc` is available machine-wide regardless of `CLAUDE_CONFIG_DIR`.

---

## Usage

| Command | Rounds | Behaviour |
|---------|--------|-----------|
| `/DARc` | 3 | Classic 3-cycle: self → OpenAI → synthesis |
| `/DARc 5` | 5 | Five rounds, each: self → OpenAI → round synthesis. Final synthesis after all rounds |
| `/DARc 1` | 1 | One self round + one OpenAI round + synthesis |
| `/DARc 0` | Unbounded | Repeats until zero CRITICAL/HIGH/MEDIUM findings. Safety cap at 20 rounds — asks user whether to continue |
| `/DARc 00` | No cap | Repeats until zero CRITICAL/HIGH/MEDIUM findings with `/goal` tracking. No upper limit. Structural escalation prevents infinite loops |
| `/DARc config` | — | Show or change adversarial model configuration (provider + model) |

DARc asks for a file if none is provided. Or just say "use /darc to review the spec" — the context tells DARc what to look at.

---

## How It Works

### Each Round

1. **Fable Self-Review (Cycle 1)** — Fable reads the target, adopts a deeply adversarial stance, documents every finding with severity (CRITICAL/HIGH/MEDIUM/LOW), concrete evidence, and a recommended fix.

2. **GPT-5.6 Cross-Model Review (Cycle 2)** — A deterministic script (`references/openai-review.sh`) sends the target to GPT-5.6 with an adversarial system prompt. Different model family, different training data — different blind spots.

3. **Round Synthesis** — Both sets of findings are compared. Contradictions are resolved. Root causes are identified. The target is updated with cumulative fixes.

### After All Rounds

**Final Synthesis** — summary statistics across all rounds, root causes, resolution of any remaining contradictions, and a list of unresolved items requiring human input.

### Unbounded Mode (N=0 and N=00)

**N=0** — Rounds repeat until zero CRITICAL, HIGH, or MEDIUM findings remain. Safety cap at 20 rounds, after which DARc asks whether to continue (one round at a time). Invokes the `/goal` skill to track progress toward the quality target.

**N=00** — No safety cap. Runs until zero CRITICAL, HIGH, or MEDIUM findings remain, tracking progress via the `/goal` skill. No upper limit — runs until the goal is met.

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
- **Claude Desktop** (for `/DARc`) or **Claude Code CLI** (for `/DARc`)

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

**Why two skills?** Desktop and CLI have different skill systems. Both use `/DARc` — Desktop via `.zip` install, CLI via clone + `install.sh`.

**Why GPT-5.6?** Different model family, different training data, different blind spots. Fable and GPT-5.6 catch things neither would find alone.

**Different model?** Edit `model: "gpt-5.6"` in `references/openai-review.sh`.

**API fails?** Non-fatal. Round skipped, synthesis continues with self-review only.

**Offline?** Cycle 1 works offline. Cycle 2 needs internet.

---

## License

<a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener">MIT</a>.

---

## Support

DARc is built by one person who pays the GPT-5.6 bills. If a round of Fable vs GPT-5.6 saves you from shipping a flaw, a coffee keeps both models in the ring. ☕

<a href="https://donate.stripe.com/aFa14n9dq6cy78lcq30ZW00" target="_blank" rel="noopener">Buy me a coffee</a>

<a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=enhancement" target="_blank" rel="noopener">Request a feature</a> · <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=bug" target="_blank" rel="noopener">Report a bug</a> · <a href="https://github.com/oxygn-cloud-ai/deep-adversarial-reviews/issues/new?labels=question" target="_blank" rel="noopener">Ask for help</a>

