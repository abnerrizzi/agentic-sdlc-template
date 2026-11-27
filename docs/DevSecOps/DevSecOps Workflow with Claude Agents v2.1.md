# DevSecOps workflow with Claude agents

Proposal v2.1, updated 2026-11-27. Superseded by v3.

## Agents check their own work, humans decide, every cycle teaches

v2 keeps the git-first workflow and adds agents that verify and fix their own work before review, plus one company knowledge repo everyone edits locally in free Obsidian. Pick a stage to see what it needs and which model runs it.

## Principles

Workflow rules keep the process safe and traceable. Agent rules, drawn from Stanford’s CS329A seminar on self-improving agents, make agents better over time without making them less safe.

### Workflow rules

### Agent rules (CS329A)

## Self-improving agents in practice

Each CS329A technique becomes something concrete in the pipeline, and each comes with a guardrail.

| Technique | What it means here | Where | Guardrail |
| --- | --- | --- | --- |

**Verifiers can be fooled.** An agent told to “make CI green” can get there by deleting a test. Agents never edit tests, CI config, rules or thresholds in the same MR as the code they check, and a human always gives the final approval.

## Which model, at what effort

Sonnet 5.5 at high builds, Opus 5.5 at high or xhigh thinks and guards security, Haiku 5.5 does chores. Best-of-N multiplies cost, so it is opt-in per story via the `agent/hard` label.

| Stage | Task | Model | Effort | Best-of-N | Escalate to |
| --- | --- | --- | --- | --- | --- |

Effort: low · medium · high (API default) · xhigh · max. Use max only after xhigh has failed. Haiku rows run at the default: the effort docs don’t list Haiku as supported.

## Where each thing lives

Work items live in the tracker and get closed. Knowledge lives in files and gets read. v2 adds the company knowledge repo for anything that outlives one project.

| Item | Lives in | Format |
| --- | --- | --- |

### MR template, two new sections

**Verify loop:** which checks the agent ran and how many loops it took. **Self-critique:** which constitution items it checked its diff against.

## Security gates

The same open-source scanners as v1, now also on the knowledge repo, plus rules that protect the verifiers themselves.

| Where | Check | Tool | Blocks merge |
| --- | --- | --- | --- |

### Agent guardrails

## Company knowledge repo

One main repo on Gitea or GitLab. Everyone clones it, edits in free Obsidian on their own machine, and reaches main only through a branch and a reviewed MR. Obsidian is the editor; git does the sharing.

1. **Clone or fork**Staff clone; contractors and clients fork
2. **Edit locally**Free Obsidian; drafts stay in `_local/`
3. **Branch and push**`kb/name/topic`, lives a day or two
4. **Merge request**CI: gitleaks, lint, links, frontmatter
5. **Owner review**CODEOWNERS per folder approve and merge
6. **Main updated**Read-only site rebuilds; agents read it

### Who contributes how

| Who | How | Can merge |
| --- | --- | --- |

### Rules

## Three things called “vault”

They are unrelated. Only the last two hold secrets, and secrets never go in the first.

### Obsidian vault

A local folder of notes

Holds

Runbooks, how-tos, patterns

Used by

Everyone, as a clone of `company-kb`

Cost

Free

### Passbolt

Team password manager

Holds

Human passwords: consoles, SaaS logins, shared accounts

Used by

People, via browser extension

Cost

Community Edition is free, open source and self-hosted; SSO and LDAP need a paid edition. Keeper is paid.

### OpenBao / HashiCorp Vault

Secrets engine for machines

Holds

App and pipeline secrets, DB credentials, certificates

Used by

CI and k3s workloads, injected at runtime

Cost

OpenBao is the free open-source fork

A note says *where* a secret lives, for example “the Supabase service key is in OpenBao at `kv/comurg/api`”, never the secret itself. gitleaks blocks it in CI anyway.

## Learnings that change behaviour

A learning counts only when it changes something an agent, a pipeline or a colleague reads. Each item goes to the strongest place that can hold it.

1. **1. CI rule**A check that enforces it. A Semgrep rule banning raw SQL strings.
2. **2. CLAUDE.md**Judgement for this project’s agents.
3. **3. ADR**When the learning changes a decision.
4. **4. Knowledge repo v2**Applies beyond this project: a pattern, runbook or how-to, proposed by MR to `company-kb/patterns/`.
5. **5. Learnings log**Context worth keeping that isn’t a rule.

When an agent got something wrong and a human fixed it, that task becomes a new eval case, so the mistake is tested for from then on.

## Rollout

Nine steps from template repos to blocking gates. Tick them off as you go; progress stays in this browser.

### Open questions

- One repo per app plus a shared `platform` repo, or a monorepo?
- Who is the second human reviewer for `sec/*` changes on a one-person team?
- Passbolt Community Edition (free, no SSO/LDAP) or a paid edition, given the plan for a unified LDAP-type directory?
- Read-only site: Quartz (closest to Obsidian, keeps backlinks) or MkDocs (simpler, very common)?

### Sources

- [CS329A Self-Improving AI Agents, Stanford](https://cs329a.stanford.edu/)
- [When does verification pay off? (verifier limits)](https://arxiv.org/pdf/2512.02304)
- [Claude effort parameter](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Obsidian is free for work](https://obsidian.md/blog/free-for-work/)
- [Passbolt Community Edition overview](https://itsfoss.com/passbolt-review.md)