---
name: DAR
description: Deep Adversarial Reviews (DAR) — iterative adversarial review using Claude self-review and OpenAI GPT-5.6 cross-model verification. Use when reviewing plans, specs, designs, or code changes for flaws before implementation. Accepts /DAR:<rounds> where <rounds> is 0-9. Default is 3 rounds. /DAR:0 loops until zero CRITICAL/HIGH/MEDIUM findings. Requires OPENAI_API_KEY in environment. Use whenever the user asks for a review, audit, adversarial check, adversarial review, or DAR of any document or code.
---

# DAR — Deep Adversarial Reviews

Iterative adversarial review: alternating Claude self-review and OpenAI GPT-5.6 cross-model
review, with synthesis at the end of every round and after all rounds complete.

## Privacy Warning

**OpenAI rounds upload the target file content to OpenAI's API.** Do not use this skill
on files containing secrets, credentials, PII, or proprietary data you cannot share
with a third-party API. The content is transmitted over HTTPS and processed by OpenAI
under their data usage policy: https://openai.com/policies/api-data-usage-policies

## Target File

The target file is the artifact to review — a plan document, specification, design doc,
or code file. The skill reads it, runs the adversarial review, and writes findings back
to the target file.

## Arguments

- **`/DAR`** (no argument): 3 rounds — self → OpenAI → synthesis (classic 3-cycle).
- **`/DAR:N`** where N is 1-9: N rounds of (self + OpenAI), each round followed by synthesis, then a final synthesis after all rounds. /DAR:1 = one self round + one OpenAI round + synthesis. /DAR:5 = 5 self + 5 OpenAI + synthesis.
- **`/DAR:0`**: Unbounded — repeats self + OpenAI until zero CRITICAL, HIGH, or MEDIUM findings remain, then synthesis. Low findings are listed but do not prevent completion.

## Installation

1. Unzip `DAR.zip` into `~/.claude/skills/DAR/`
2. Make the script executable: `chmod +x ~/.claude/skills/DAR/references/openai-review.sh`
3. Verify: `~/.claude/skills/DAR/references/openai-review.sh` exists and is executable
4. Restart Claude Desktop
5. Verify installation: ask Claude "run DAR doctor"

## Doctor

To verify the skill is functional, ask Claude: "run DAR doctor". Claude will:
1. Check `references/openai-review.sh` exists and is executable
2. Check `curl`, `jq`, `file`, `iconv`, and `seq` are installed
3. Check `$OPENAI_API_KEY` is set
4. Verify API connectivity: `printf 'Authorization: Bearer %s\n' "$OPENAI_API_KEY" > /tmp/dar-doctor-header && curl -sS https://api.openai.com/v1/models -H @/tmp/dar-doctor-header | jq -e '.data' && rm /tmp/dar-doctor-header`
5. Report PASS or FAIL for each check

## Process

### Resolve round count

Parse the user's request. If they specified `/DAR:<N>`:
- N=0: unbounded — continue until zero CRITICAL/HIGH/MEDIUM findings
- N=1-9: run N rounds
- No N specified: default to 3 rounds

### Each round

For each round R (1..N, or unbounded):

**Claude self-review:** Read the target file (plus any updates from previous rounds).
Adopt a sceptic stance. Find: missing edge cases, contradictions, unstated assumptions,
implementation gaps, ordering problems, security issues, race conditions, backward
compatibility breaks. Document every finding with severity (CRITICAL/HIGH/MEDIUM/LOW),
concrete evidence, and recommended fix. Write under `## Adversarial Review — Round R (Self)`.

**OpenAI GPT-5.6 cross-model review:** Run the deterministic script:

```bash
bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/DAR/references/openai-review.sh" <target-file>
```

If the script exits 0: its stdout is the OpenAI findings. Write them to the target
file under `## Adversarial Review — Round R (OpenAI GPT-5.6)`. Reformat if needed
to match the self-review style (severity + evidence + fix). If the script exits non-zero
(API failure): note the skip, continue with self-review findings only.

**Round synthesis:** After each round, read both the self and OpenAI findings for that
round. Synthesise: identify root causes, resolve contradictions, update the target
with fixes. Write under `## Round R — Synthesis`.

**For /DAR:0 (unbounded):** After each round synthesis, count CRITICAL, HIGH, and MEDIUM
findings. If ALL are resolved (zero CRITICAL/HIGH/MEDIUM), stop and proceed to final
synthesis. List any remaining LOW findings. If findings remain, continue to the next round.
Maximum 20 rounds as a safety cap — after 20 rounds, stop and report remaining findings.

**For /DAR:N (bounded):** After N rounds complete, proceed to final synthesis.

### Final synthesis

After all rounds complete, write under `## Adversarial Review — Final Synthesis`:

1. Summary statistics across all rounds
2. Root cause(s) identified
3. Contradictions between rounds resolved
4. Updated target with cumulative fixes
5. Any unresolved items requiring user input

## Output format

For 3 rounds default:
```
## Adversarial Review — Round 1 (Self)
## Adversarial Review — Round 1 (OpenAI GPT-5.6)
## Round 1 — Synthesis
## Adversarial Review — Round 2 (Self)
## Adversarial Review — Round 2 (OpenAI GPT-5.6)
## Round 2 — Synthesis
## Adversarial Review — Round 3 (Self)
## Adversarial Review — Round 3 (OpenAI GPT-5.6)
## Round 3 — Synthesis
## Adversarial Review — Final Synthesis
```

## Rules

- **Never rubber-stamp.** Real adversarial review finds real problems.
- **OpenAI gets the SAME target file.** The script sends the exact file content.
- **Document every finding.** Severity + evidence + fix.
- **Synthesis IS the value.** Do not just list — connect, resolve, update.
- **The target file IS the output.** Append review sections; do not create separate report files.
- **/DAR:0 safety cap.** Maximum 20 rounds. Notify user if cap is reached.
- **OpenAI failures are non-fatal.** If the script fails, skip that round's OpenAI review and continue with self-review only.
