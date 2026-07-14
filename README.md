# DAR — Deep Adversarial Reviews

Iterative adversarial review using Claude self-review and OpenAI GPT-5.6 cross-model verification.

## Skills

| Skill | Platform | Command | Rounds |
|-------|----------|---------|--------|
| **DAR** | Claude Desktop | `/DAR`, `/DAR:N` | 3 default, 1-9, 0=unbounded |
| **DARc** | Claude Code CLI | `/DARc`, `/DARc:N` | 3 default, 1-9, 0=unbounded |

## Shared Engine

Both skills use `references/openai-review.sh` — a deterministic script that calls
OpenAI GPT-5.6 with an adversarial review prompt. 32K output tokens, retry with
exponential backoff, temp-file API key handling.

## Requirements

- `OPENAI_API_KEY` in environment
- `curl`, `jq`, `file`, `iconv`, `seq`

## Privacy

OpenAI rounds upload target file content to OpenAI's API.
Do not use on files containing secrets, credentials, or PII.

## Structure

```
references/openai-review.sh           — Shared Cycle 2 engine
skills/dar/SKILL.md                   — Claude Desktop skill
skills/dar/references/ -> ../../references/  — Symlink
skills/darc/SKILL.md                  — Claude Code CLI skill
skills/darc/references/ -> ../../references/ — Symlink
skills/darc/install.sh                — CLI installer
skills/darc/CHANGELOG.md              — Version history
```
