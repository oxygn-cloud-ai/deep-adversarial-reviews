# DARc — ProductHunt Description

You ask Claude to review your code. It finds things. You ask ChatGPT. It finds different things. Neither catches everything the other sees. Single-model reviews share blind spots — same training data, same assumptions, same gaps.

DARc runs both. Fable (Anthropic) reviews your file first with a deeply adversarial stance. Then GPT-5.6 (OpenAI) reviews the same file independently — different model family, different training data, different blind spots. Both sets of findings are synthesised, contradictions are surfaced, and root causes are identified. Then it does it again. `/darc:1` for one round. `/darc:5` for five. `/darc:00` keeps going until nothing of substance remains — or tells you the remaining issues are structural and offers alternative perspectives.

**What makes it different:** Most review tools tell you what's wrong. DARc tells you what both models agree on, what they disagree on, and what neither can resolve. When a finding is structural — a spec contradiction, an architectural trade-off, an ambiguous requirement — DARc says so rather than pretending code can fix it.

**Works on anything:** Code, specs, design docs, Jira tickets, architecture decisions, meeting minutes, policy documents. The README has two embedded demos: a Gilded Rose refactoring kata (code) and the Agile Manifesto (non-code).

**Open source. MIT licensed.** `git clone` + `install.sh` + `/darc <blank or topic or file>`.
