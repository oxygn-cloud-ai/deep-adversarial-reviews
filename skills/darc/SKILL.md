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
| `<number>` | Run `<number>` rounds. 0 = unbounded until zero CRITICAL/HIGH/MEDIUM |
| `help`, `--help`, `-h` | Show help |
| `doctor`, `--doctor`, `check` | Run doctor |
| `version`, `--version`, `-v` | Print version |

**Argument parsing:** If `$ARGUMENTS` starts with a digit, that's the round count.
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
- **/DARc:0**: Unbounded — repeats until zero CRITICAL/HIGH/MEDIUM findings. Safety cap at 20 rounds.

## Process

### Resolve round count

```bash
ROUNDS=3
if [[ "$ARGUMENTS" =~ ^([0-9]+) ]]; then ROUNDS="${BASH_REMATCH[1]}"; fi
if [ "$ROUNDS" -eq 0 ]; then UNBOUNDED=true; else UNBOUNDED=false; fi
```

### Each round

For each round R (1..N, or unbounded):

**Claude self-review:** Read the target file. Adopt a sceptic stance. Find: missing edge cases,
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

**For /DARc:0 (unbounded):** After each round synthesis, count CRITICAL, HIGH, and MEDIUM
findings. If ALL are resolved (zero CRITICAL/HIGH/MEDIUM), stop and proceed to final
synthesis. List any remaining LOW findings. If findings remain, continue. Maximum 20 rounds.

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
- **/DARc:0 safety cap.** Maximum 20 rounds. Notify user if cap is reached.
- **OpenAI failures are non-fatal.** If the script fails, skip that round and continue.

### help

```
DARc v1.0.0 — Deep Adversarial Review CLI

/DARc <target>          Run full review (3 rounds) on <target>
/DARc <N> <target>      Run N rounds (0-9). 0 = unbounded.
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
