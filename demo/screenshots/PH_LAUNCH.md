# DARc — ProductHunt Launch Checklist

**Target:** Tuesday–Thursday launch window
**Goal:** Top 5 of the day, 100+ upvotes, 50+ installs

## Assets (all ready)

| Asset | File | Status |
|-------|------|--------|
| Logo (200×200) | `demo/screenshots/darc-logo-200.png` | ✅ |
| Tagline | "Two models. One review. Zero blind spots." (42 chars) | ✅ |
| Screenshot 1 | `screenshot-01-findings.png` — findings on Gilded Rose kata | ✅ |
| Screenshot 2 | `screenshot-02-synthesis.png` — cross-model synthesis | ✅ |
| Screenshot 3 | `screenshot-03-structural.png` — Agile Manifesto escalation | ✅ |
| Screenshot 4 | `screenshot-04-readme.png` — value proposition + features | ✅ |
| Screenshot 5 | `screenshot-05-terminal.png` — terminal demo frame | ✅ |
| Demo GIF | `darc-demo.gif` — 27s real terminal recording | ✅ |
| Description | `ph-description.md` | ✅ |
| First comment | `ph-first-comment.md` — maker story | ✅ |

## Gallery Upload Order

1. **GIF first** — the demo GIF shows the product in action, strongest hook
2. **screenshot-01-findings.png** — what DARc actually finds
3. **screenshot-02-synthesis.png** — cross-model value proposition
4. **screenshot-03-structural.png** — works on non-code, knows its limits
5. **screenshot-04-readme.png** — features and install overview

## Listing Details

### Name
DARc — Deep Adversarial Review for Claude

### Tagline
Two models. One review. Zero blind spots.

### Description
(From `ph-description.md` — the full description text)

### Topics / Tags
`developer-tools`, `code-review`, `artificial-intelligence`, `open-source`, `cli`

### Links
- GitHub: https://github.com/oxygn-cloud-ai/deep-adversarial-reviews
- Confluence: https://oxygn.atlassian.net/wiki/spaces/Tools/pages/38469638/DAR+Technical+Reference

## Launch Day Checklist

### Day Before
- [ ] Verify GitHub Pages loads correctly
- [ ] Verify Stripe payment link works
- [ ] Verify README renders all badges and screenshots
- [ ] Verify `/DARc doctor` passes on a clean install
- [ ] Prepare reply templates for common questions

### Launch Morning (US morning, ~9am ET)
- [ ] Post to ProductHunt
- [ ] Immediately post first comment (maker story)
- [ ] Notify Claude Discord (showcase channel)
- [ ] Notify Anthropic developer forum
- [ ] Monitor comments — respond within 2 hours

### Launch Day
- [ ] Respond to every PH comment
- [ ] Share PH link on personal social
- [ ] Thank upvoters in comments

### Day After
- [ ] Post r/ClaudeAI show & tell (if 48h has passed)
- [ ] Share launch numbers internally
- [ ] Log lessons for next launch

## Common Reply Templates

### "Just a wrapper around two API calls"
> Fair question. What makes DARc different from a raw API call is the adversarial protocol: each model reviews independently with a sceptical stance, the engine synthesises findings after every round, contradictions between reviewers are surfaced rather than hidden, and structural findings (issues that cannot be resolved by editing the target alone) are escalated rather than papered over. The head+tail splice handles files beyond token limits. The API key lives in a temp file with 0600 permissions, not in process argv. Those details are where the value is.

### "Why would I pay for two AI subscriptions?"
> Cycle 1 (Fable self-review) works without any API key — you get adversarial review out of the box. The OpenAI key is optional for cross-model verification. And if you are already paying for both Claude and ChatGPT, DARc uses what you already have.

### "Does it work on [language/framework]?"
> DARc works on any text file. The engine reviewers are language-agnostic. The only requirement is that your target fits in a file. Code, specs, design docs, Jira tickets — all work.

### "How is this different from GitHub Copilot code review?"
> Copilot review works inside GitHub's ecosystem and focuses on code. DARc is model-agnostic, works on any text artefact, and the adversarial stance means it does not assume your code is correct — it assumes it has flaws and tries to find them. It also tells you when a finding is structural and cannot be fixed by editing the target alone.

## Success Metrics

| Metric | Target |
|--------|--------|
| PH upvotes | 100+ |
| PH comments | 20+ |
| GitHub stars gained | 30+ |
| GitHub clones | 50+ |
| Stripe clicks | 10+ |
| Coffee purchases | 1+ |

## Post-Launch

- [ ] Add "Featured on ProductHunt" badge to README
- [ ] Write launch retrospective
- [ ] Plan Week 3 content (r/programming post, blog post)
