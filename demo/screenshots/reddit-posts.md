# Reddit Post Drafts — DARc

---

## r/ClaudeAI — "I built a DARc skill that makes Fable and GPT-5.6 adversarially review your work"

**Type:** Show & Tell
**Timing:** US morning, 48h after PH launch

I got tired of asking Claude to review my code and wondering what it missed. So I built a skill that pits Fable against GPT-5.6 on the same file — two model families, one target. Each finds what the other misses. Findings are synthesised after every round.

It works. I ran it on the Gilded Rose kata: 14 findings across both models. Fable found 4 (CRITICAL, HIGH, MEDIUM) — missing Conjured handling, the `x - x = 0` code smell, magic string anti-pattern. GPT-5.6 found 10 — no constructor validation, fragile string-based dispatch, mutable-field risks, partial-update hazards. Neither model found everything alone.

Then I ran it on the AI Manifesto — five principles for responsible AI use. A document about AI, adversarially reviewed by AI. Fable caught the missing data safeguards — the manifesto says nothing about what data may be submitted to AI services. GPT-5.6 returned 24 findings, including the contradiction between "never let an LLM speak for you" and "AI should reduce barriers," and a CRITICAL about zero enforcement mechanisms for any of the five principles.

The skill is called DARc. It is open source, MIT licensed. `/darc:1 my-file.md` and you are off. Works on code, specs, Jira tickets, design docs, meeting minutes — anything you can save as a file.

Two demos embedded in the README with real API output, no scripted findings. Docker-reproducible.

Would love feedback from anyone who tries it on something real.

[GitHub](https://github.com/oxygn-cloud-ai/deep-adversarial-reviews)

---

## r/OpenAI — "Cross-model adversarial review: what happens when you pit GPT-5.6 against Fable on the same file"

**Type:** Discussion
**Timing:** US morning, 48h after r/ClaudeAI post

I have been experimenting with cross-model adversarial review — running two models from different families against the same target and synthesising their findings.

The setup: Fable (Anthropic) reviews first with a deeply adversarial stance. Then GPT-5.6 (OpenAI) reviews the same file independently. Different training data, different assumptions, different blind spots. Both sets of findings are compared, contradictions surfaced, and root causes identified.

Some things I have learned:
- Neither model finds everything alone. On the Gilded Rose kata, Fable caught the code smells; GPT-5.6 caught the architecture-level gaps (no constructor validation, mutable public fields).
- Cross-model disagreement is as valuable as agreement. When both models flag the same issue, you know it is real. When they disagree, you have found a structural ambiguity.
- GPT-5.6 is brutally honest on non-code artefacts. On the AI Manifesto, it returned 24 findings — including pointing out that a document about responsible AI use contains zero guidance on what data may be submitted to AI services.

I wrapped this into a Claude Code CLI skill called DARc. Open source. The README has two asciicast demos with real API output — nothing is scripted.

Curious what others think about cross-model review as a concept. Is this a useful pattern, or just doubling your API bill?

[GitHub](https://github.com/oxygn-cloud-ai/deep-adversarial-reviews)

---

## r/programming — "Adversarial code review with two AI models: what cross-model verification catches that single-model misses"

**Type:** Article/Show
**Timing:** Week 3-4, after launch week

Single-model AI review has a blind spot: the same training data, the same assumptions, the same gaps. Ask Claude to review your PR. Then ask ChatGPT. They will find different things. Neither catches everything the other sees.

I quantified this with DARc, an open-source adversarial review tool that runs two models across different families against the same target and synthesises the results. Here is what I found.

**On code (Gilded Rose kata):** 14 findings total — 4 from Fable, 10 from GPT-5.6. The findings overlapped on structural issues (missing features, deep nesting) but diverged on approach: Fable caught code-level smells; GPT-5.6 caught architecture-level gaps (no constructor validation, fragile string-based dispatch, partial-update risks). Neither model found everything alone.

**On a real architecture decision record:** 17 findings from GPT-5.6 alone, including a CRITICAL that the selected design "directly contradicts the determinism requirement." I wrote the ADR. I missed this. The cross-model review caught it.

**On the AI Manifesto:** 24 findings. GPT-5.6 identified that a document about responsible AI use has zero guidance on data safeguards, that its principles contradict each other, and that five "Never" statements have zero enforcement mechanisms.

The tool is open source, MIT licensed. The README has two asciicast demos with real API output generated live during recording — no scripted findings. Docker-reproducible.

The cross-model pattern is not magic. It costs more (two API calls per round). But the coverage difference — the things one model catches that the other misses — is real and measurable. For artefacts where correctness matters (security-sensitive code, regulatory docs, architecture decisions), the second perspective earns its cost.

[GitHub](https://github.com/oxygn-cloud-ai/deep-adversarial-reviews)
