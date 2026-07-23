# DARc Demo — Gilded Rose Refactoring Kata

## Product

DARc (Deep Adversarial Review for Claude) — iterative adversarial review using Fable self-review and GPT-5.6 cross-model verification. Finds flaws before they become bugs. Not a fixer — a reviewer.

## Demo Pattern

`/darc 1 original.py` (one round) → review findings → human applies fixes → `/darc 1 original.py` again.

DARc reviews. The human decides what to implement. This is by design.

## Setup

```bash
cd demo/gilded-rose
```

## Round 1: DARc reviews the original

```bash
/darc 1 original.py
```

**Findings:**
- Self-review: 6 findings — CRITICAL (missing Conjured), HIGH (magic strings, obscure quality reset)
- OpenAI cross-model: 9 findings — HIGH (Conjured missing, no quality validation), MEDIUM (fragile names, deep nesting, mutable fields)

**Cross-model agreement:** Both found missing Conjured, magic strings, fragile string matching, deep nesting.
**Cross-model complement:** Self-review caught the `x - x` code smell. OpenAI caught no-constructor-validation and mutable-field risks. Neither model found everything alone.

"DAR found 15 issues across two model families. Cross-model review caught things neither model would have found on its own."

## Fix: strategy pattern refactoring

47 lines → 118 lines. Named constants, quality helpers, predicate functions, strategy dispatch. Conjured handled.

## Round 2: DARc reviews the refactored code

```bash
/darc 1 original.py
```

**Result: 0 findings.**

"No findings. Checked: sell-in boundaries, quality caps, Sulfuras enforcement, Conjured detection, strategy precedence, expired-item behaviour. All correct."

## Docker (test isolation)

```bash
docker build -t gilded-rose-demo .
docker run --rm gilded-rose-demo
# OK
```