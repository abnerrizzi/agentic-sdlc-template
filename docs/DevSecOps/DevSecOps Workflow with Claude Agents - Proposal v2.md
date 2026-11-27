# DevSecOps Workflow with Claude Agents - Proposal v2

Version 2.1 · updated Nov 27, 2026 · @Abner Rizzi · superseded by Proposal v3

## What changed from v1

v2 keeps the git-first workflow and adds two things: agents that improve themselves against verifiers, and one company knowledge repo every person edits locally in free Obsidian.

- **Self-improving agents.** Principles taken from Stanford's CS329A seminar: verifiers, a written constitution, test-time compute, memory and agent evals. Agents check and fix their own work before a human sees it.
- **Company knowledge repo.** One main repo on Gitea or GitLab. Each person clones it, edits in Obsidian on their own machine, and proposes changes to main through a branch and an MR. No paid Sync, no shared online vault.
- **Free online read-only site.** CI builds main into an internal website, so people without Obsidian can still read everything.
- **Glossary.** "Vault" means three different things in this stack; v2 names which one is which.

## Easy start: the smallest version that works

Everything below this section is the target. Start with three things, one person and a few days: one Gitea, two repos, one `CLAUDE.md`. Add the rest only when the simple version starts to hurt.

| Phase | Set up | Effort | Deliberately skipped |
| --- | --- | --- | --- |
| **0. Day 1** | One Gitea container. Two repos: `company-kb` and `project-template`. Issues + labels (`type/`, `status/`) + milestones as epics. Protected main. | \~half a day | GitLab, epics features, boards, bot accounts |
| **0. Day 1** | `company-kb`: 5 folders, 1 note template, `CODEOWNERS` with just you. Obsidian + obsidian-git (pull on open). Wikilinks off, so links render in Gitea too. | \~1 hour | Read-only website: Gitea already renders the Markdown in the browser |
| **0. Day 1** | One CI job on both repos: gitleaks. | \~1 hour | Semgrep, Trivy, SBOM, signing |
| **1. Week 1** | `CLAUDE.md` with: stack, how to run checks (`make check`), "run `make check` and fix until green before saying done", "review your own diff against these rules", 5 dos and don'ts. | \~2 hours | Separate agents, best-of-N, evals |
| **1. Week 1** | Model defaults: Sonnet 5.5 high for everything; Opus 5.5 for plans, threat models and security review. | 0 | Per-task effort table, Haiku chores |
| **1. Week 1** | Pilot one small epic end to end with you running Claude Code locally. Write one learnings entry at the end. | the epic | Retro agent, promotion ladder |
| **2. When it hurts** | Add from the full proposal: Semgrep and Trivy (warn first), bot account + deny list, verifier path rule, read-only site, Passbolt, eval set. | per item | - |

**Why this is enough to start:** the verify loop and self-critique are just two lines in `CLAUDE.md` plus a `make check` target, so the core CS329A idea works on day one with no extra tooling. Non-git colleagues can skip local Obsidian entirely and use Gitea's web editor, which can commit to a new branch and open the pull request in one step.

## Principles

Two sets. Workflow rules keep the process safe and traceable; agent rules, drawn from CS329A, make the agents get better over time without getting less safe.

**Workflow rules (from v1)**

1. **Git is the source of truth.** If it is not in a repo or the tracker, it did not happen.
2. **Plain text, versioned.** Markdown with frontmatter. Accepted ADRs are superseded, never edited.
3. **Agents propose, humans decide.** No agent merges, approves its own MR, or holds prod credentials.
4. **Small batches.** One story, one branch, one MR, reviewable in 15 minutes.
5. **Read-only first.** Diagnose and `plan` before `apply`; every risky MR carries rollback steps.
6. **Security is enforced, not requested.** Scans run in CI and block on criticals.
7. **Least privilege for agents.** Bot account per role, scoped tokens, no prod secrets in context.
8. **Everything as code.** Infra, pipelines, policies and agent instructions go through MRs.

**Agent rules (from CS329A)**

9. **Verify before you ask.** Every agent task has a machine check (tests, linters, scanners, policy). The agent loops generate > verify > fix until it passes, then opens the MR.
10. **A written constitution.** `CLAUDE.md` and these principles are the rubric. Before opening an MR, the agent critiques its own diff against them and fixes what fails.
11. **Spend compute where it pays.** Low effort for chores, high for building, xhigh and best-of-N only for hard or high-risk tasks.
12. **Memory is curated, not accumulated.** Agents read the company knowledge repo and project learnings; only reviewed, merged text becomes memory.
13. **Measure, don't guess.** A regression set of past tasks runs before any change to `CLAUDE.md`, prompts or model choice is merged.
14. **Verifiers are protected.** An agent never weakens a test, rule or threshold to make its own work pass. Changes to verifiers need a human-owned MR.
15. **Every cycle teaches.** An epic closes only when its retro is merged as a change agents read.

## Lifecycle v2

Same seven stages as v1, with one change that matters: inside Build, the agent runs every check itself and fixes its own work, up to 5 loops, before a human is asked to look.

&#91;embedded content: lifecycle v2 · 7 stages, verify loop, 2 feedback loops\]

| Stage | Output | Gate to move on |
| --- | --- | --- |
| 0. Capture | Issue `type/idea` or a local note | Weekly triage |
| 1. Plan | Epic + draft ADR, after searching the knowledge repo | Epic approved, ADR accepted |
| 2. Breakdown | Stories with criteria, tasks, security notes | Definition of Ready |
| 3. Build | Code + tests + draft MR with Verify loop and Self-critique sections | All checks green, self-critique done |
| 4. Review | Fresh-session AI review + human review | Approvals, zero open criticals |
| 5. Release | Tag, image, GitOps deploy dev > qa > prod | Prod approval, rollback tested in qa |
| 6. Learn | Learnings, `CLAUDE.md` update, knowledge repo MR, new eval cases | Retro merged, eval pass rate holds |

## Self-improving agents in practice

CS329A covers how agents improve through interaction with themselves and their environment: verifiers, constitutional AI, test-time compute, search, tools, memory and agent evaluation. Each technique below maps to something concrete in this workflow.

| Technique (CS329A) | What it means here | Where in the lifecycle | Guardrail |
| --- | --- | --- | --- |
| Verifiers | Tests, type checks, linters, Semgrep, Trivy, OPA/Kyverno policies, `terraform plan` diff checks | Build, Review, Release | Verifier files are owned by humans via CODEOWNERS |
| Learning from tool and code feedback | Agent runs the tests and scanners itself, reads the errors, fixes, repeats | Build | Max 5 loops, then stop and report |
| Constitutional self-critique | Agent reviews its own diff against `CLAUDE.md` and the principles before opening the MR, and lists what it checked | Build > Review | The checklist is part of the MR description |
| Test-time compute | Effort level per task; best-of-N (2-3 parallel attempts, tests pick the winner) for hard or high-risk tasks | Plan, Build | Best-of-N only on tasks labelled `agent/hard` |
| Search and research | Agent searches docs, the knowledge repo and past MRs before proposing a design | Plan, Breakdown | Cites sources in the ADR or story |
| Memory | Company knowledge repo + project learnings, read at the start of each task | All stages | Only merged, reviewed text counts as memory |
| Planning | Plan written and approved before code; long tasks split into checkpoints | Plan, Breakdown | One story per MR |
| Agent evaluation | Regression set of 20-30 past tasks with known-good outcomes, re-run on any change to prompts, `CLAUDE.md` or model | Learn | Merge blocked if pass rate drops |

**Why the guardrails matter:** verifiers can be fooled. Research covered in the course shows they can produce false positives or pick the wrong solution, and an agent optimising to "make CI green" can do it by deleting a test. So agents never edit verifiers in the same MR as the code they verify, and humans keep the final approval.

## Agent model and effort per task

Sonnet 5.5 at high builds, Opus 5.5 at high or xhigh thinks and guards security, Haiku 5.5 does chores. Fable 5.2 is kept for the hardest cross-system problems. Effort ladder: `low` > `medium` > `high` (API default) > `xhigh` > `max`; use `max` only after `xhigh` has failed.

| Stage | Task | Model | Effort | Best-of-N | Escalate to |
| --- | --- | --- | --- | --- | --- |
| 0. Capture | Triage ideas, label, spot duplicates | Haiku 5.5 | default | No | Sonnet 5.5 `low` |
| 1. Plan | Architecture options, ADR draft (searches knowledge repo first) | Opus 5.5 | high | 2 drafts, you pick | Fable 5.2 `high` |
| 1. Plan | Threat model per component | Opus 5.5 | xhigh | No | Human security review |
| 2. Breakdown | Epic > stories, criteria, tasks | Sonnet 5.5 | medium | No | Opus 5.5 `high` |
| 2. Breakdown | Security notes per story | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| 3. Build | Feature code, IaC, with verify loop | Sonnet 5.5 | high | Only if `agent/hard` | Sonnet `xhigh`, then Opus 5.5 |
| 3. Build | Large refactor or migration | Opus 5.5 | xhigh | 2-3 attempts, tests pick | Fable 5.2 `xhigh` |
| 3. Build | Constitutional self-critique of own diff | Same as builder | same | No | - |
| 3. Build | Tests scaffold, docs, commit messages | Haiku 5.5 | default | No | Sonnet 5.5 `low` |
| 3. Build | CI log triage | Haiku 5.5 | default | No | Sonnet 5.5 `medium` |
| 4. Review | First-pass review, fresh session | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| 4. Review | Security review (`sec/*`) | Opus 5.5 | xhigh | No | Human approval always |
| 5. Release | Check plan/diff and rollback steps | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| 5. Release | Changelog, release notes | Haiku 5.5 | default | No | Sonnet 5.5 `low` |
| Any | Incident RCA, postmortem draft | Opus 5.5 | xhigh | No | Fable 5.2 `xhigh` |
| 6. Learn | Distil learnings, propose knowledge repo notes | Sonnet 5.5 | medium | No | Opus 5.5 `high` |
| 6. Learn | Turn a learning into a CI rule | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| 6. Learn | Run the agent eval set | Haiku 5.5 grader + task models | default | - | Human looks at failures |

Haiku rows say "default" because the effort docs don't list Haiku as supported. Best-of-N multiplies cost by N, so it is opt-in per story via the `agent/hard` label.

## Tracking and repo conventions

Unchanged from v1: work items live in the tracker and get closed; knowledge lives in files and gets read. v2 adds one destination, the company knowledge repo, for knowledge that outlives a single project.

| Item | Lives in | Format |
| --- | --- | --- |
| Thought / idea | Issue `type/idea`, or a local note in Obsidian | Free text |
| Decision (ADR) | `docs/adr/` in the project repo | MADR template |
| Epic / story / task | Tracker issues (`type/epic`, `type/story`), tasks as checklists | Story template with acceptance criteria and security notes |
| Learning (project) | `docs/learnings/` in the project repo | Learned / Do / Don't / Evidence |
| Knowledge (company-wide) | Company knowledge repo | Runbooks, patterns, how-tos, glossary |
| Agent eval set | `evals/` in the platform repo | Task + expected outcome + grader |

**Conventions:** branch `<type>/<issue>-<slug>`; Conventional Commits with issue ref; MR closes its story; labels `type/`, `status/`, `prio/`, `sec/`, `agent/` (`agent/authored`, `agent/hard`); protected main with squash merge. The MR template adds two v2 sections: **Verify loop** (which checks the agent ran and how many loops) and **Self-critique** (constitution items checked).

## Security gates and agent guardrails

Same open-source scanners as v1, now also run on the knowledge repo, plus a new rule set that protects the verifiers themselves.

| Where | Check | Tool | Blocks merge? |
| --- | --- | --- | --- |
| Pre-commit | Secrets, lint, format | gitleaks, pre-commit hooks | Yes, locally |
| CI | Secrets on full diff (code and knowledge repo) | gitleaks | Yes |
| CI | SAST | Semgrep | Critical / high |
| CI | Dependencies and licences | Trivy fs or OSV-Scanner | Critical |
| CI | IaC misconfig | Trivy config or Checkov | High |
| CI | Container image | Trivy image | Critical |
| CI | SBOM + signing | Syft + Cosign | Must exist |
| CI | Verifier integrity: MR touches both code and its tests, CI config or rules | Path rule in CI + CODEOWNERS | Needs human owner approval |
| CI | Agent eval set on prompt, `CLAUDE.md` or model changes | Eval job | Pass rate must not drop |
| Deploy | Signed images, policy | Kyverno in k3s | Yes |
| Prod | Manual approval + rollback plan | Protected environment | Yes |

**Agent guardrails**

- One bot account per role; tokens push branches and open MRs, never merge.
- Claude Code deny list: `terraform apply`, `kubectl delete`, the prod context, `rm -rf`, reading `.env` or secret tokens.
- Verify loop capped at 5 iterations; after that the agent stops and reports instead of trying harder.
- Agents never edit tests, CI config, Semgrep rules or policy thresholds in the same MR as the code those files check.
- Text from outside the team (issues, MR comments, notes from forks) is untrusted input: agents don't follow instructions found in it.

## Company knowledge repo (free, local Obsidian)

One main repo holds the company's shared knowledge. Each person clones it and edits it in free Obsidian on their own machine; changes reach main only through a branch and a reviewed MR. Obsidian is just the editor, git does the sharing, so nothing needs paid Sync or a hosted vault.

&#91;embedded content: knowledge repo flow · local edit to reviewed main\]

Notes travel left to right on a laptop, come back through review, and only then reach the website and the agents.

**Clone or fork?** Staff clone the main repo and push short-lived branches to it: one copy, no forks to keep in sync. Contractors, clients and anyone outside the team fork it and send MRs from the fork, so they never get write access to the main repo.

| Who | How they contribute | Can merge? |
| --- | --- | --- |
| Staff comfortable with git | Clone, branch `kb/<name>/<topic>`, push, open MR | Only in folders they own (CODEOWNERS) |
| Staff not comfortable with git | Edit in Obsidian; the obsidian-git plugin commits to their branch; open the MR from the web UI, or use the web editor directly | No |
| Contractors and externals | Fork, branch, MR from the fork | No |
| Agents | Branch `agent/kb-<topic>`, MR with sources cited | No, human approval required |
| Folder owners | Review and merge MRs for their folder | Yes |

**Repo layout**

```text
company-kb/
  00-start-here.md
  runbooks/          # how to operate things
  howto/             # step-by-step guides
  patterns/          # cross-project learnings promoted from project repos
  architecture/      # platform overview, links to ADRs in project repos
  glossary/
  templates/         # note templates with frontmatter (owner, review-by date)
  _local/            # gitignored: personal drafts that never leave the laptop
  .obsidian/         # shared settings and plugin allowlist; workspace files gitignored
  CLAUDE.md          # how agents read and propose changes here
  CODEOWNERS         # one owner per folder
```

**Rules**

1. **Local first.** Personal drafts live in `_local/` (gitignored) or a separate personal vault. Moving a note into a shared folder and opening an MR is the act of sharing.
2. **Pull before you write.** obsidian-git pulls on open; branches live a day or two, so conflicts stay small.
3. **One repo per confidentiality boundary.** `company-kb` holds no client secrets or client-confidential data; client-specific knowledge goes in a separate repo with restricted access.
4. **Plugin allowlist.** Community plugins run code on the laptop, so `.obsidian/` commits only the approved set (core plugins + obsidian-git + templates).
5. **CI on every MR:** gitleaks, markdown lint, broken-link check, frontmatter check (owner and review-by date present).
6. **Free online read-only site.** On merge, CI builds main into a static site with an open-source generator such as Quartz or MkDocs and serves it internally behind SSO. People without Obsidian read it in a browser; nobody edits it there.
7. **Agents read main only.** Branches and `_local/` are never agent memory.

## Glossary: three kinds of "vault"

The word means three unrelated things in this stack. Only the last two hold secrets, and secrets never go in the first.

| Name | What it is | Holds | Who uses it | Cost |
| --- | --- | --- | --- | --- |
| Obsidian vault | Just a local folder of Markdown notes that Obsidian opens; here, a clone of `company-kb` | Knowledge: runbooks, how-tos, patterns | Every person | Free |
| Passbolt (or Keeper) | Team password manager with browser extensions and shared folders | Human passwords: admin consoles, SaaS logins, shared accounts | People | Passbolt Community Edition is free, open source and self-hosted; Keeper is paid |
| HashiCorp Vault / OpenBao | Secrets engine for machines | App and pipeline secrets, dynamic DB credentials, certificates, injected at runtime | CI, k3s workloads | OpenBao is the free open-source fork; Vault is source-available |

**Rules:** no password, token or key ever goes in a note (gitleaks blocks it in CI anyway). A note says *where* a secret lives ("the Supabase service key is in OpenBao at `kv/comurg/api`"), never the secret itself. Passbolt Community Edition has no SSO or LDAP integration; those come with its paid editions, so decide if that matters before choosing it.

## Learnings loop

A learning only counts when it changes something an agent, a pipeline or a colleague reads. After each epic or incident, the retro agent drafts a learnings entry; you edit and merge it, then each item goes to the strongest place that can hold it.

1. **CI rule** (strongest) - a check that enforces it, e.g. a Semgrep rule banning raw SQL.
2. **`CLAUDE.md` dos and don'ts** - judgement for this project's agents.
3. **ADR** - if it changed a decision.
4. **Company knowledge repo** (new in v2) - if it applies beyond this project: a pattern, runbook or how-to, proposed by MR to `company-kb/patterns/`.
5. **Project learnings log** - context worth keeping that isn't a rule.

The agent eval set grows from the same loop: when an agent got something wrong and a human fixed it, that task becomes a new eval case, so the mistake is tested for from then on.

## Platform, rollout and open questions

**Gitea or GitLab:** both work, unchanged from v1. Gitea is the lighter fit for a 3-node k3s cluster; GitLab wins if native epics, approval rules and security dashboards matter more than resources. The knowledge repo, forks and MRs work the same on both.

**Rollout**

- [ ] ADR-0001 adopt this workflow, ADR-0002 Gitea or GitLab, ADR-0003 knowledge repo model (clone for staff, fork for externals)
- [ ] Template project repo: `CLAUDE.md`, `.claude/agents/`, MR template with Verify loop and Self-critique sections, labels, CODEOWNERS
- [ ] CI security baseline in warn-only mode, plus the verifier-integrity path rule
- [ ] Bot accounts, scoped tokens, protected branches, Claude Code deny list
- [ ] Create `company-kb`: layout, templates, `.obsidian/` allowlist, CODEOWNERS, CI (gitleaks, lint, links), read-only site behind SSO
- [ ] Onboard 2-3 people to the clone > branch > MR flow in Obsidian and collect friction
- [ ] Pilot one epic end to end (the Supabase key exposure fix) with verify loop and self-critique on
- [ ] Build the first 10 agent eval cases from the pilot
- [ ] Pilot retro: switch criticals to blocking, roll out to other repos

**Open questions**

- One repo per app plus a shared `platform` repo, or a monorepo?
- Who is the second human reviewer for `sec/*` changes on a one-person team?
- Passbolt Community Edition (free, no SSO/LDAP) or a paid edition, given the plan for a unified LDAP-type user directory?
- Read-only site generator: Quartz (closest to Obsidian, keeps backlinks) or MkDocs (simpler, very common)?

## Sources

- [CS329A Self-Improving AI Agents, Stanford, course site and syllabus](https://cs329a.stanford.edu/)
- [CS329A course description, Stanford Bulletin](https://bulletin.stanford.edu/courses/2263721)
- [When does verification pay off? (verifier limits)](https://arxiv.org/pdf/2512.02304)
- [Claude effort parameter](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Obsidian is now free for work](https://obsidian.md/blog/free-for-work/)
- [Passbolt Community Edition overview](https://itsfoss.com/passbolt-review.md)
