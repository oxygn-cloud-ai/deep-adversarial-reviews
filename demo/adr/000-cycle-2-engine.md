# ADR 000 — Cycle 2 Engine Provider Selection

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** James Shanahan

## Context

DARc needs a Cycle 2 cross-model review engine. The requirements:
1. Deterministic — no AI guesswork in the API call itself.
2. Different model family from Fable (Cycle 1) — cross-model blind-spot coverage.
3. Outputs severity-tagged findings with evidence and fixes.
4. Runs unattended in shell scripts (no browser, no OAuth flow).
5. API key must never appear in process listings (ps output).

## Options Considered

### Option A: OpenAI GPT-5.6
- Bash script. curl + jq. API key in temp file (0600), curl -H @file.
- 32K output tokens. Retry with exponential backoff. Head+tail splice for >80KB files.
- Requires OPENAI_API_KEY env var. Key validated at script start.
- Proven: called hundreds of times during development.

### Option B: Anthropic Claude API
- Same provider as Cycle 1. Violates cross-model requirement.
- Eliminates the adversarial value proposition.

### Option C: Codex (GPT-5.6 via Codex API)
- Same model family as Option A. Different auth model.
- Requires CODEX_API_KEY. Adds infrastructure complexity.
- Lower priority than getting OpenAI path stable first.

## Decision

**Option A — OpenAI GPT-5.6 via deterministic bash script.**

Rationale:
1. Cross-model: Anthropic vs OpenAI are different model families.
2. Deterministic: the script is 118 lines of bash, no LLM calls in the engine itself.
3. Security: API key in temp file (chmod 0600), never in argv. `trap` ensures cleanup.
4. Proven: in active use. Temperature bug found and fixed during development.

## Consequences

- Users must have an OpenAI API key. Documented in README and Privacy section.
- Engine is single-provider. `/darc:config` plans Codex and Claude providers for future.
- GPT-5.6 model variants (sol, terra, luna) are configurable via `/darc:config model`.
