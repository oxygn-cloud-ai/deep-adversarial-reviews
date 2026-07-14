# DARc — Deep Adversarial Review CLI

Claude Code CLI skill. Iterative adversarial review using Claude self-review and OpenAI GPT-5.6 cross-model verification.

## Usage

```
/DARc plan.md          # 3 rounds on plan.md
/DARc 5 design.md      # 5 rounds on design.md
/DARc 0 spec.md        # Unbounded until zero CRITICAL/HIGH/MEDIUM
```

## Requirements

- `OPENAI_API_KEY` in environment
- `curl`, `jq`, `file`, `iconv`, `seq`

## Version

1.0.0
