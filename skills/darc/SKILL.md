---
name: darc
version: 1.0.0
description: Deep Adversarial Review for Claude Code CLI — iterative adversarial review using Claude self-review and OpenAI GPT-5.6 cross-model verification. Use when reviewing plans, specs, designs, or code changes for flaws before implementation. Accepts /DARc and /DARc:<rounds>. Requires OPENAI_API_KEY in environment.
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
argument-hint: "[<rounds>] [<target-file>]"
---

# DARc — Deep Adversarial Review CLI

Iterative adversarial review: alternating Claude self-review and OpenAI GPT-5.6 cross-model
review, with synthesis at the end of every round and after all rounds complete.

## Routing

Parse `$ARGUMENTS`:

| Argument | Action |
|----------|--------|
| (empty) or `<target-file>` | Run full review with default 3 rounds |
| `<number>` | Run `<number>` rounds. 0 = unbounded with cap (ask at 20). 00 = no cap, runs until goal |
| `help`, `--help`, `-h` | Show help |
| `doctor`, `--doctor`, `check` | Run doctor |
| `version`, `--version`, `-v` | Print version |

**Argument parsing:** If `$ARGUMENTS` starts with a digit, that's the round count.
`00` is a special case — it means no cap (unbounded until goal met), distinct from `0` (cap at 20 with human continue).
All other args are treated as the target file path.

## Privacy Warning

**OpenAI rounds upload the target file content to OpenAI's API.** Do not use this skill
on files containing secrets, credentials, PII, or proprietary data you cannot share
with a third-party API. Content is transmitted over HTTPS and processed by OpenAI
under their data usage policy: https://openai.com/policies/api-data-usage-policies

## Target File

The target file is the artifact to review. If none provided, ask the user to specify one.

## Round Count

- **No argument**: 3 rounds (self + OpenAI + synthesis, alternating)
- **/DARc:N** (1-9): N rounds of (self + OpenAI) with per-round synthesis + final synthesis
- **/DARc:0**: Unbounded with safety cap at 20 rounds. After 20 rounds, use AskUserQuestion to ask the user whether to continue. Do not silently stop. Invoke the `/goal` skill at start.
- **/DARc:00**: Unbounded with no cap. Runs until zero CRITICAL/HIGH/MEDIUM findings. Invoke the `/goal` skill at start. No upper limit.

## Process

### Resolve round count

```bash
ROUNDS=3
# /DARc:00 is no-cap unbounded; /DARc:0 is capped unbounded
if [[ "$ARGUMENTS" =~ ^(00)(\ .*|$) ]]; then
  UNBOUNDED=true; NO_CAP=true; ROUNDS=0
elif [[ "$ARGUMENTS" =~ ^([0-9]+) ]]; then
  ROUNDS="${BASH_REMATCH[1]}"
fi
if [ "$ROUNDS" -eq 0 ] && [ "${NO_CAP:-false}" != "true" ]; then UNBOUNDED=true; NO_CAP=false; fi
```

### Each round

For each round R (1..N, or unbounded):

**Claude self-review:** Read the target file. Adopt a deeply adversarial stance. Find: missing edge cases,
contradictions, unstated assumptions, implementation gaps, ordering problems, security issues,
race conditions, backward compatibility breaks. Document every finding with severity
(CRITICAL/HIGH/MEDIUM/LOW), concrete evidence, and recommended fix. Write under
`## Adversarial Review — Round R (Self)`.

**OpenAI GPT-5.6 cross-model review:** Run the deterministic script:

```bash
bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/drvc/references/openai-review.sh" <target-file>
```

If the script exits 0: its stdout is the OpenAI findings. Write them to the target
file under `## Adversarial Review — Round R (OpenAI GPT-5.6)`. If the script exits non-zero:
note the skip, continue with self-review findings only.

**Round synthesis:** After each round, read both findings for that round. Synthesise:
identify root causes, resolve contradictions, update the target with fixes. Write under
`## Round R — Synthesis`.

**For /DARc:0 (unbounded with cap):** Before starting, invoke the `/goal` skill to set the quality
target: "Eliminate all CRITICAL, HIGH, and MEDIUM findings via adversarial review." Then run rounds.
After each round synthesis, count CRITICAL, HIGH, and MEDIUM findings. If ALL are resolved (zero
CRITICAL/HIGH/MEDIUM), stop and proceed to final synthesis. List any remaining LOW findings.
If findings remain, continue to the next round. At round 20, if findings still remain:
1. Report: rounds completed, findings remaining by severity, progress against the goal
2. Use AskUserQuestion: "20 rounds completed. [N] findings remain. Continue?"
3. If user says yes — continue one more round, then ask again each subsequent round
4. If user says no — stop and proceed to final synthesis
Do NOT silently halt at 20 rounds.

**For /DARc:00 (no cap):** Before starting, invoke the `/goal` skill to set the quality
target: "Eliminate all CRITICAL, HIGH, and MEDIUM findings via adversarial review." Then run rounds
without any upper limit. Report progress against the goal after each round synthesis. Continue until
zero CRITICAL, HIGH, and MEDIUM findings remain, or structural escalation triggers. No safety cap.

**Structural-level escalation:** If after 3+ consecutive rounds the remaining CRITICAL/HIGH/MEDIUM
findings are *structural* — meaning they cannot be resolved by editing the target file alone — do
NOT loop indefinitely. A finding is structural if its root cause cannot be resolved by editing the target
artefact alone — regardless of whether the artefact is code, a Jira ticket, a plan,
a document, or anything else. The canonical example: the Gilded Rose spec says Sulfuras
quality is both "always 80" and "never changes" — two rules that contradict for non-80
input. No code change can resolve this; the spec itself must be clarified. The trigger
is the same for any domain: the finding points outside the target.

When structural findings are detected:
1. Classify each remaining MEDIUM+ finding as: **target-level** (fixable in the artefact) or **structural**
   (requires a decision beyond the target)
2. For each structural finding, propose a **resolution document** under
   `## Structural Resolution`. The resolution must state: what the original issue is, why the
   artefact alone cannot resolve it, the proposed path forward (e.g., revised spec, architectural
   decision, API contract clarification), and the preconditions for re-review.
3. **Alternative perspectives:** For each structural finding, gently suggest 1-3 different
   perspectives the user might consider. These are not directives — they are invitations
   to reframe the problem. Example for the Gilded Rose Sulfuras contradiction:
   - "Perhaps 'never changes' was written for the common case and 'always 80' is the
     authoritative rule — what if quality 80 is a precondition, not a runtime correction?"
   - "Consider whether the contradiction exists because Sulfuras was added to the spec
     after the other rules were written, and the two statements were never reconciled."
   - "One perspective: the system's job is to model inventory faithfully. If a Sulfuras
     enters with quality 79, perhaps the real-world answer is 'that cannot happen' rather
     than 'the code should handle it.'"
   Tone: polite, gentle, speculative. Use "perhaps," "consider whether," "one perspective."
   Never "you should" or "the correct view is."
4. Use AskUserQuestion: "[N] findings are structural — they cannot be resolved within the
   target alone. I have suggested some alternative perspectives. Accept proposed resolutions
   and re-review?"
5. If user accepts — apply the resolutions (update specs, document decisions, etc.),
   then re-run review against the updated context
6. If user declines — stop and proceed to final synthesis, listing structural findings
   as "Deferred — human decision required"

**For /DARc:N (bounded):** After N rounds complete, proceed to final synthesis.

### Final synthesis

Write under `## Adversarial Review — Final Synthesis`:
1. Summary statistics across all rounds
2. Root cause(s) identified
3. Contradictions between rounds resolved
4. Updated target with cumulative fixes
5. Any unresolved items requiring user input

## Rules

- **Never rubber-stamp.** Real adversarial review finds real problems.
- **OpenAI gets the SAME target file.** The script sends the exact file content.
- **Document every finding.** Severity + evidence + fix.
- **Synthesis IS the value.** Do not just list — connect, resolve, update.
- **The target file IS the output.** Append review sections; do not create separate report files.
- **/DARc:0 safety cap.** Maximum 20 rounds. After 20 rounds, use AskUserQuestion to ask the user whether to continue. Do not silently stop.
- **/DARc:00 has no cap.** Runs until zero CRITICAL/HIGH/MEDIUM findings. Invoke the `/goal` skill at the start to set and track the quality target. Report progress against the goal after each round.
- **/goal skill.** For both /DARc:0 and /DARc:00, invoke the `/goal` skill before the first round to establish the quality target. Use goal progress reporting after each round synthesis.
- **OpenAI failures are non-fatal.** If the script fails, skip that round and continue.

### help

```
DARc v1.0.0 — Deep Adversarial Review CLI

/DARc <target>          Run full review (3 rounds) on <target>
/DARc <N> <target>      Run N rounds (0-9). 0 = unbounded (cap 20, asks to continue). 00 = no cap.
/DARc help              Display this guide
/DARc doctor            Check environment health
/DARc version           Show installed version

Each round: Claude self-review → OpenAI GPT-5.6 → round synthesis.
Final synthesis after all rounds. Requires OPENAI_API_KEY.
```

### doctor

```
DARc doctor — Environment Health Check

Checks:
  1. references/openai-review.sh exists and is executable
  2. curl, jq, file, iconv, seq are installed
  3. OPENAI_API_KEY is set
  4. OpenAI API connectivity verified
```

Run each check and report PASS or FAIL.

### version

```
DARc v1.0.0 — choc-skills family
```
