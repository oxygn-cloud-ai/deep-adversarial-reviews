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
- **`/DAR:0`**: Unbounded — repeats self + OpenAI until zero CRITICAL, HIGH, or MEDIUM findings remain, then synthesis. Low findings are listed but do not prevent completion. Safety cap at 20 rounds — after 20 rounds, you MUST ask the user whether to continue (do not silently stop). If the user says yes, continue one round at a time, asking again each round. If the user says no, stop and proceed to final synthesis. Invoke the `/goal` skill at the start to set and track the quality target: "Eliminate all CRITICAL, HIGH, and MEDIUM findings."
- **`/DAR:00`**: No cap — zero upper limit. Repeats self + OpenAI until zero CRITICAL, HIGH, or MEDIUM findings remain. Invoke the `/goal` skill at the start to track progress. Runs indefinitely until the goal is met. No safety cap. Report progress against the goal after each round synthesis.
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
- N=0: unbounded with cap — continue until zero CRITICAL/HIGH/MEDIUM findings, but at 20 rounds ask the user whether to continue (do not silently stop)
- N=00: unbounded with no cap — continue until zero CRITICAL/HIGH/MEDIUM findings, no upper limit
- N=1-9: run N rounds
- No N specified: default to 3 rounds

### Each round

For each round R (1..N, or unbounded):

**Claude self-review:** Read the target file (plus any updates from previous rounds).
Adopt a deeply adversarial stance. Find: missing edge cases, contradictions, unstated assumptions,
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

**For /DAR:0 (unbounded with cap):** Before starting, invoke the `/goal` skill to set the quality
target: "Eliminate all CRITICAL, HIGH, and MEDIUM findings via adversarial review." Then run rounds.
After each round synthesis, count CRITICAL, HIGH, and MEDIUM findings. If ALL are resolved (zero
CRITICAL/HIGH/MEDIUM), stop and proceed to final synthesis. List any remaining LOW findings.
If findings remain, continue to the next round. At round 20, if findings still remain:
1. Report: rounds completed, findings remaining by severity, and progress against the goal
2. Explicitly ask the user: "20 rounds completed. [N] findings remain. Continue?"
3. If user says yes — continue one more round, then ask again each subsequent round
4. If user says no — stop and proceed to final synthesis
Do NOT silently halt at 20 rounds. The user must decide.

**For /DAR:00 (no cap):** Before starting, invoke the `/goal` skill to set the quality
target: "Eliminate all CRITICAL, HIGH, and MEDIUM findings via adversarial review." Then run rounds
without any upper limit. Report progress against the goal after each round synthesis. Continue until
zero CRITICAL, HIGH, and MEDIUM findings remain, or structural escalation triggers. No safety cap.

**Structural-level escalation:** If after 3+ consecutive rounds the remaining CRITICAL/HIGH/MEDIUM
findings are *structural* — meaning they cannot be resolved by editing the target artefact alone — do
NOT loop indefinitely. A finding is structural if its root cause cannot be resolved by editing the target
artefact alone — regardless of whether the artefact is code, a Jira ticket, a plan,
a document, or anything else. The canonical example: the Gilded Rose spec says Sulfuras
quality is both "always 80" and "never changes" — two rules that contradict for non-80
input. No code change can resolve this; the spec itself must be clarified. The trigger
is the same for any domain: the finding points outside the target.

When structural findings are detected:
1. Classify each remaining MEDIUM+ finding as: **target-level** (fixable in the artefact) or **structural**
   (requires a decision beyond the artefact)
2. For each structural finding, propose a **resolution document** under
   `## Structural Resolution`. The resolution must state: what the original issue is, why the
   artefact alone cannot resolve it, the proposed path forward (e.g., revised spec, architectural
   decision, API contract clarification), and the preconditions for re-review.
3. **Alternative perspectives:** For each structural finding, gently suggest 1-3 different
   perspectives the user might consider. These are not directives — they are invitations
   to reframe the problem. Example for the Gilded Rose Sulfuras contradiction:
   - "Perhaps 'never changes' was written for the common case and 'always 80' is the
     authoritative rule — what if quality 80 is a precondition, not a runtime correction?"
   - "One perspective: the system's job is to model inventory faithfully. If a Sulfuras
     enters with quality 79, perhaps the real-world answer is 'that cannot happen' rather
     than 'the code should handle it.'"
   Tone: polite, gentle, speculative. Use "perhaps," "consider whether," "one perspective."
   Never "you should" or "the correct view is."
4. Ask the user: "[N] findings are structural — cannot be resolved within the target alone.
   I have suggested some alternative perspectives. Accept proposed resolutions and re-review?"
5. If user accepts — apply the resolutions (update specs, document decisions, etc.),
   then re-run review against the updated context
6. If user declines — stop and proceed to final synthesis, listing structural findings
   as "Deferred — human decision required"

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
- **/DAR:0 safety cap.** Maximum 20 rounds. After 20 rounds, ask the user whether to continue. Do not silently stop. Use AskUserQuestion or an explicit conversational prompt — the user must decide.
- **/DAR:00 has no cap.** Runs until zero CRITICAL/HIGH/MEDIUM findings. Invoke the `/goal` skill at the start to set and track the quality target. Report progress against the goal after each round.
- **/goal skill.** For both /DAR:0 and /DAR:00, invoke the `/goal` skill before the first round to establish the quality target. Use goal progress reporting after each round synthesis.
- **OpenAI failures are non-fatal.** If the script fails, skip that round's OpenAI review and continue with self-review only.
