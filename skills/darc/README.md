# DARc — Deep Adversarial Review CLI

Claude Code CLI skill. Iterative adversarial review using Claude self-review and OpenAI GPT-5.6 cross-model verification.

## Usage

```
/DARc plan.md          # 3 rounds on plan.md
/DARc 5 design.md      # 5 rounds on design.md
/DARc 0 spec.md        # Unbounded until zero CRITICAL/HIGH/MEDIUM
```

## Installation

Run `bash install.sh`. The script installs the skill to `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`.

**Command scoping caveat (fixed in install.sh v1.0.1):** On machines where `CLAUDE_CONFIG_DIR` points to a non-home path (e.g. `/workspace/.claude`, per the global `CLAUDE.md` rule), the router file `darc.md` was written only to the project-scoped commands directory — `/workspace/.claude/commands/`. Claude Code loads project-scoped commands only when the working directory is under that tree, so `/darc` was unavailable outside `/workspace/`. The user-scoped directory `~/.claude/commands/` loads everywhere; DARc had no entry there. The install script now always symlinks into `~/.claude/commands/` — using `CLAUDE_CONFIG_DIR` when set, otherwise `$HOME/.claude` — so `/darc` is globally available on the machine regardless of the config directory.

## Requirements

- `OPENAI_API_KEY` in environment
- `curl`, `jq`, `file`, `iconv`, `seq`

## Version

1.0.1
