# ProductHunt First Comment — DARc

Hey ProductHunt. I built DARc because I was tired of asking one AI to review my work and wondering what it missed.

**The problem:** every engineer knows the feeling of shipping code and thinking "if only someone else had looked at this." AI review helps — but single-model review has a fundamental blind spot. The same training data, the same assumptions, the same gaps. Ask Claude to review your PR. Then ask ChatGPT. They find different things. Neither catches everything the other sees.

**What DARc does:** it pits two models from different families against the same file. Fable (Anthropic) goes first with a deeply adversarial stance. GPT-5.6 (OpenAI) follows independently. Both sets of findings are synthesised after every round — contradictions between reviewers are surfaced, not hidden. Then it repeats. One round, five rounds, or unbounded until nothing of substance remains.

**What happened when I tested it:** I ran DARc on the Gilded Rose refactoring kata — the most famous code kata in software. Fifteen findings across the two models. Fable caught the missing Conjured item handling and the `x - x = 0` code smell. GPT-5.6 caught the missing constructor validation and the mutable-field risks. Neither model found everything alone. After refactoring to a strategy pattern, DARc confirmed zero remaining findings. The asciicast is in the README.

Then I ran it on the AI Manifesto — five principles for responsible AI use, 87 signatories. A document about AI, adversarially reviewed by AI. DARc surfaced the enforcement gap (five "Never let an LLM..." statements, zero consequences), the self-referential irony (a document about AI that reads like it was written with AI), and the tension between "own the strategy" and "never let an LLM replace your curiosity." If the manifesto is right, DARc's findings are worth considering. If it is flawed, DARc found the flaws. Either outcome validates the premise of adversarial review.

**DARc is not a code fixer.** It is a reviewer. It finds flaws, documents them with severity and evidence, and recommends fixes. It tells you when something cannot be resolved by editing the target alone. The human decides what to implement.

**Works on anything you can put in a file.** Code, design docs, Jira tickets, architecture decisions, meeting minutes, policy documents. If you can save it, DARc will review it.

**Open source, MIT licensed.** Two asciicast demos embedded in the README. Docker-reproducible. `/darc <blank or topic or file>` and you are off.

I would love feedback from anyone who tries it on something real — especially non-code artefacts. The cross-model synthesis is what makes this different from single-model review, and I want to hear where it surprises you and where it falls short.

Thanks for reading.

[GitHub](https://github.com/oxygn-cloud-ai/deep-adversarial-reviews)
