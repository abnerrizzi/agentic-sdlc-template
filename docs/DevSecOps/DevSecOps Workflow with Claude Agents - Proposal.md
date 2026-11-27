# DevSecOps Workflow with Claude Agents - Proposal

Version 1.1 · updated Nov 27, 2026 · @Abner Rizzi · superseded by Proposal v3

## Context and goals

A git-first workflow where Claude agents plan, build and review, but every thought, decision, task and learning lands in the repo as reviewable text, and humans approve every merge. It targets Gitea or GitLab self-hosted on the k3s platform, and fits the 8 web apps rebuild as the first pilot.

What it must deliver:

- **Traceability** - every commit traces to a story, every story to an epic, every non-obvious choice to an ADR.
- **Security by default** - checks run in the pipeline and block merges; nothing depends on someone remembering.
- **Compounding knowledge** - each finished epic leaves behind dos and don'ts that the agents read next time.
- **Portability** - same conventions on Gitea and GitLab, open-source tooling, no lock-in to a paid tier.

## Foundation principles

Ten rules that every repo, agent and person follows. When in doubt, these win over convenience.

1. **Git is the source of truth.** If it is not in the repo or the tracker, it did not happen. Chat history is not a record.
2. **Plain text, versioned.** Markdown with YAML frontmatter for ADRs, learnings and threat models. Accepted ADRs are never edited, only superseded.
3. **Agents propose, humans decide.** No agent merges to main, approves its own MR, or holds production credentials.
4. **Small batches.** One story = one branch = one MR. Aim for diffs a human can review in 15 minutes.
5. **Read-only first.** Diagnose and `plan` before `apply`. Every risky MR carries explicit rollback steps.
6. **Security is enforced, not requested.** Secrets, SAST, dependency, IaC and image scans run in CI and block on criticals.
7. **Least privilege for agents.** Separate bot account per role, scoped tokens, protected branches, no prod secrets in agent context.
8. **Everything as code.** Infra (Terraform, Ansible), pipelines, policies and agent instructions (`CLAUDE.md`) all live in git and go through MRs.
9. **Right model for the job.** Cheapest model that does the task reliably; escalate after two failed attempts.
10. **Every cycle teaches.** An epic is not closed until its retro is merged as a change to a file agents read.

## Lifecycle: plan to learn

Six stages, each with one gate. Nothing moves forward until its gate passes, and two loops send work back: review rework, and learnings feeding the next plan.

&#91;embedded content: lifecycle · 7 stages, 2 feedback loops\]

Review sends work back to Build until it passes; Learn feeds the next Plan, so each epic starts smarter than the last.

| Stage | Input | Output | Gate (to move on) | Who does it |
| --- | --- | --- | --- | --- |
| 0. Capture | A thought, request or alert | Issue labelled `type/idea` | Weekly triage: promote to epic or close | Anyone |
| 1. Plan | Idea, business need | Epic (outcome, scope, non-goals, metric) + draft ADR if a choice is made | Human approves epic, ADR moves to `accepted` | Planner agent + you |
| 2. Breakdown | Approved epic | Stories with acceptance criteria, task checklist, security notes, estimates | Definition of Ready: testable criteria, threat notes, no open questions | Breakdown agent + you |
| 3. Build | Ready story | Branch, code, tests, draft MR with rollback steps | CI green: tests + all security scans | Builder agent (Claude Code) |
| 4. Review | Draft MR | Review comments, fixes, approvals | AI review in a fresh session + human approval via CODEOWNERS, zero open criticals | Reviewer agent + human |
| 5. Release | Merged MR | Tag, image, deploy dev > qa > prod via GitOps | Manual approval for prod, rollback tested in qa | Pipeline + you |
| 6. Learn | Closed epic or incident | Learnings entry, updated `CLAUDE.md`, new CI rule or ADR | Retro MR merged, then epic closes | Retro agent + you |

## Tracking: thoughts, decisions, epics, stories, tasks

Work items live in the tracker (issues), knowledge lives in the repo (files). Issues are for things that get done and closed; files are for things that stay true and get read by agents.

| Item | Lives in | Format | States | Linked from |
| --- | --- | --- | --- | --- |
| Thought / idea | Issue, `type/idea` | Free text, 3-5 lines | open > promoted or closed | Epic that adopts it |
| Decision (ADR) | `docs/adr/0007-use-k3s.md` | MADR template | proposed > accepted > superseded | Epics, stories, MRs, code comments |
| Epic | GitLab Epic (paid tier) or parent issue `type/epic` + milestone | Outcome, scope, non-goals, success metric, child story list | open > in progress > retro > closed | Stories, ADRs, learnings |
| Story | Issue `type/story` | User story, acceptance criteria, security notes, task checklist | ready > doing > review > done | Branch name, MR (`Closes #123`) |
| Task | Checklist `- [ ]` inside the story (or GitLab task) | One line each | open > ticked | Commits |
| Bug / incident | Issue `type/bug` or `type/incident` | Repro or timeline | open > fixed > postmortem | Postmortem in `docs/postmortems/` |
| Threat model | `docs/threat-models/<component>.md` | STRIDE-lite table | living doc, updated via MR | Stories touching that component |
| Learning | `docs/learnings/2026-11-epic-12.md` | Learned / Do / Don't / Evidence | append-only | `CLAUDE.md`, CI rules, ADRs |
| Agent run | MR description section | Model, task, what it changed, what it skipped | per MR | The MR itself |

**Traceability chain:** commit `feat(api): rate-limit login (#123)` > MR `Closes #123` > story #123 > epic &12 > ADR-0007. Any line of code can be walked back to why it exists.

**Story template** (the shape agents fill during breakdown):

```markdown
## Story
As a <role>, I want <capability>, so that <outcome>.

## Acceptance criteria
- [ ] Given ..., when ..., then ...

## Security notes
Data touched, auth impact, new secrets, new external calls, STRIDE items.

## Tasks
- [ ] ...

## Links
Epic: &12 | ADR: 0007 | Threat model: auth-api
```

## Repo layout and conventions

One template repo that every new project is cloned from, so agents and humans always find things in the same place.

```text
repo/
  CLAUDE.md                   # agent rules: stack, commands, dos and don'ts (keep under ~150 lines)
  .claude/
    agents/                   # subagents: planner, breakdown, reviewer, security-reviewer
    commands/                 # slash commands: /plan /breakdown /review /retro
    settings.json             # tool permissions: allow/deny lists
  docs/
    adr/                      # 0001-adopt-this-workflow.md, 0002-...
    threat-models/
    learnings/
    postmortems/
  .gitlab/                    # GitLab: issue_templates/, merge_request_templates/
  .gitea/                     # Gitea: ISSUE_TEMPLATE/, PULL_REQUEST_TEMPLATE.md, workflows/
  .gitlab-ci.yml              # or .gitea/workflows/*.yml
  CODEOWNERS
  infra/                      # terraform/, ansible/, k8s manifests
  src/
```

| Convention | Rule | Example |
| --- | --- | --- |
| Branch | `<type>/<issue>-<slug>` from main, deleted after merge | `feat/123-login-rate-limit` |
| Commit | Conventional Commits + issue ref | `fix(auth): expire refresh tokens (#123)` |
| MR title | Same as the story title | `Rate-limit login endpoint` |
| Labels | Prefixed groups: `type/`, `status/`, `prio/`, `sec/`, `agent/` | `type/story`, `sec/auth`, `agent/authored` |
| Protected main | No direct push, squash merge, linear history, signed commits for humans | - |
| Tags | SemVer, created by the pipeline only | `v1.4.0` |

**MR template sections:** Summary · Story link (`Closes #`) · ADR link · Test evidence · Security checklist (new secrets? new endpoints? data touched?) · **Rollback steps** · Agent disclosure (model used, what was generated, human reviewer).

## Agent model: which Claude for which task

Default to Sonnet 5.5 at high effort for building, Opus 5.5 at high or xhigh for thinking and security, Haiku 5.5 for high-volume chores. Fable 5.2 is reserved for the hardest cross-system problems.

**Effort ladder:** `low` > `medium` > `high` (API default) > `xhigh` > `max`. Step down for routine, well-scoped work; step up to `xhigh` only for the hardest coding, agentic and security tasks; use `max` only when `xhigh` has already failed. Set it per agent in CI jobs via the API `effort` parameter, or with the effort setting in Claude Code. ([source](https://platform.claude.com/docs/en/build-with-claude/effort))

| Stage | Task | Model | Effort | Why | Escalate to |
| --- | --- | --- | --- | --- | --- |
| 0. Capture | Triage ideas, label, spot duplicates | Haiku 5.5 | default | Short, high volume, low stakes | Sonnet 5.5 `low` |
| 1. Plan | Architecture options, trade-offs, ADR draft | Opus 5.5 | high | Long reasoning, second-order effects | Fable 5.2 `high` for multi-system designs |
| 1. Plan | Threat model per component (STRIDE) | Opus 5.5 | xhigh | A missed attack path is expensive later | Human security review |
| 2. Breakdown | Epic > stories, acceptance criteria, tasks | Sonnet 5.5 | medium | Structured and template-driven | Opus 5.5 `high` if the epic is vague or large |
| 2. Breakdown | Security notes per story | Sonnet 5.5 | high | Needs care, but scoped to one story | Opus 5.5 `high` |
| 3. Build | Feature code, IaC (Terraform, Ansible, k8s) | Sonnet 5.5 | high | Best speed/quality balance for agentic coding | Sonnet `xhigh`, then Opus 5.5 after 2 failed attempts |
| 3. Build | Large refactor or migration (e.g. Supabase exit) | Opus 5.5 | xhigh | Many files, ordering of changes matters | Fable 5.2 `xhigh` |
| 3. Build | Tests scaffold, docs, commit messages | Haiku 5.5 | default | Well-defined text, cheap and fast | Sonnet 5.5 `low` |
| 3. Build | CI log triage, failing pipeline summary | Haiku 5.5 | default | Short context, repetitive | Sonnet 5.5 `medium` if root cause is unclear |
| 4. Review | First-pass code review, fresh session | Sonnet 5.5 | high | Different session from the builder | Opus 5.5 `high` |
| 4. Review | Security review (`sec/*`: auth, crypto, secrets, input) | Opus 5.5 | xhigh | Subtle bugs, high stakes | Human approval always |
| 5. Release | Check `terraform plan` / deploy diff and rollback steps | Sonnet 5.5 | high | Must catch destructive changes before apply | Opus 5.5 `high` for prod data changes |
| 5. Release | Changelog, release notes, MR summary | Haiku 5.5 | default | Summarising merged work | Sonnet 5.5 `low` |
| Any (incident) | RCA and postmortem draft | Opus 5.5 | xhigh | Correlates logs, timeline and code | Fable 5.2 `xhigh` |
| 6. Learn | Distil learnings into dos and don'ts | Sonnet 5.5 | medium | Summary plus judgement on what generalises | Opus 5.5 `high` for big epics |
| 6. Learn | Turn a learning into a CI rule (Semgrep, gitleaks pattern) | Sonnet 5.5 | high | It becomes code that blocks merges | Opus 5.5 `high` |

Haiku rows say "default": the effort docs do not list Haiku as supported, so leave it unset there.

**Rules of thumb**

- Reviewer model is equal to or stronger than the builder model, and never the same session.
- Fable 5.2 carries extra cybersecurity safeguards, so keep it on design work, not attack-style testing.
- Model choice per agent is set in `.claude/agents/*.md`, so it is versioned and reviewed like any other change.

## Security gates and agent guardrails

All scanners are open source and run identically on GitLab CI and Gitea Actions. Start them as warnings during the pilot, then make criticals blocking.

| Where | Check | Tool | Blocks merge? |
| --- | --- | --- | --- |
| Pre-commit (local) | Secrets, lint, format | gitleaks, pre-commit hooks | Yes, locally |
| CI | Secret detection on full diff | gitleaks | Yes |
| CI | SAST | Semgrep | Critical/high |
| CI | Dependencies and licences | Trivy fs or OSV-Scanner | Critical |
| CI | IaC misconfig (Terraform, k8s, Dockerfile) | Trivy config or Checkov | High |
| CI | Container image vulnerabilities | Trivy image | Critical |
| CI | SBOM + signing | Syft + Cosign | Must exist |
| Deploy | Signed images only, policy checks | Kyverno in k3s | Yes |
| Deploy | Secrets injected at runtime, never in repo | Vault | - |
| Prod | Manual approval + rollback plan in MR | Protected environment | Yes |

**Agent guardrails**

- One bot account per agent role, with a token that can push branches and open MRs but cannot merge or touch protected branches.
- Claude Code `settings.json` deny list: `terraform apply`, `kubectl delete`, `kubectl` against the prod context, `rm -rf`, reading `.env` or Vault tokens.
- Agents may run `terraform plan` and read-only diagnostics; `apply` runs only in the pipeline after approval.
- MRs labelled `agent/authored` need one human approval; `sec/*` needs a second reviewer.
- Issue and MR text from outside the team is untrusted input: agents must not follow instructions found inside it.

## Learnings loop: learns, dos and don'ts

A learning only counts when it changes something an agent or pipeline reads. A wiki page nobody opens is not a learning.

After each epic or incident, the retro agent reads the closed stories, MR comments, failed pipelines and review findings, then drafts one learnings entry. You edit and merge it. Each item is then promoted to the strongest place that can hold it:

1. **CI rule** (strongest) - if a check can enforce it, write the check. Example: a Semgrep rule banning raw SQL strings.
2. **`CLAUDE.md` dos and don'ts** - if it is judgement, not mechanics. Example: "Don't add a new service without a health endpoint."
3. **ADR** - if it changed a decision.
4. **Learnings log only** - if it is context, not a rule.

```markdown
## 2026-11 - Epic &12 Auth API
**Learned:** Supabase RLS policies were the only auth layer; API had none.
**Do:** Enforce authz in the API layer and test it per endpoint.
**Don't:** Ship anon keys in frontend bundles.
**Evidence:** !45, #50, pipeline 1932
**Promoted to:** CI rule (gitleaks custom pattern), CLAUDE.md
```

Prune `CLAUDE.md` each quarter: merge duplicates, drop rules now enforced by CI, keep it short enough that agents actually follow it.

## Where Claude Docs fits versus git

Claude Docs is for drafting and discussing; git is for the record. A doc that reaches a decision becomes an ADR or an epic in the repo, and the doc links to it.

| Use Claude Docs for | Use git and the tracker for |
| --- | --- |
| Early thinking and options before anything is decided | Accepted decisions (ADRs) |
| Proposals for clients or people who don't use git (e.g. Comurg) | Epics, stories, tasks and their status |
| Meeting notes and workshop output | Anything an agent or pipeline must read |
| Drafts that need inline comments from non-technical reviewers | Learnings, threat models, postmortems |
| This proposal | `ADR-0001: adopt this workflow`, once agreed |

**Hand-off rule:** when a doc is agreed, export the decision to `docs/adr/` (or open the epic), paste the link at the top of the doc, and stop editing the doc.

## Second brain (Obsidian)

Worth it as a viewer and scratchpad over Markdown in git, never as a system of record. Obsidian is just a folder of `.md` files, so it fits the git-first model.

| Layer | Tool | Holds | Who reads it |
| --- | --- | --- | --- |
| Private thinking | Obsidian vault (own private git repo) | Half-formed ideas, research, call notes, cross-client patterns, runbooks | You, and agents you point at it |
| Shared drafts | Claude Docs | Proposals, meeting notes, docs for non-git reviewers | You + clients and colleagues |
| Record | Project repos + tracker | ADRs, epics, stories, learnings, threat models | Everyone, CI, agents |

**When it pays off:** 3+ projects or clients at once (Coremont, Comurg, the foundation client) where the same research keeps repeating, and you want knowledge that outlives any one repo. For a single project, open the repo's `docs/` folder as a vault instead of adding a new system.

**Setup rules**

1. Personal vault in its own private git repo, synced with the obsidian-git plugin.
2. Promotion rule: a note that becomes a decision, task or learning moves to the repo (ADR, issue, learnings entry) and the note links to it.
3. One vault per confidentiality boundary: Coremont material never shares a vault with Comurg or personal notes, and client secrets never land in a vault an agent reads broadly.
4. A `CLAUDE.md` at the vault root describing the folder layout and what is off-limits to agents.

## Gitea vs GitLab, and rollout

The workflow works on both. Gitea is the lighter fit for a 3-node k3s cluster and a small team; GitLab wins if native epics, approval rules and security dashboards matter more than resources.

| Need | GitLab (CE / Free) | Gitea |
| --- | --- | --- |
| Epics | Native epics are a paid-tier feature; on Free use a parent issue + milestone | Parent issue with task list + milestone |
| Boards | Issue boards | Project boards |
| Exclusive labels | Scoped labels `a::b` (paid tier); prefix convention on Free | Exclusive labels `a/b` |
| CI | GitLab CI, runner with Kubernetes executor | Gitea Actions (GitHub Actions syntax), act\_runner in k3s |
| Templates | `.gitlab/issue_templates/`, `merge_request_templates/` | `.gitea/ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md` |
| Code owners | `CODEOWNERS` (required approvals on paid tier) | `CODEOWNERS` (review requests) |
| Security scans | Built-in templates (depth varies by tier) + the open-source set above | Open-source set above |
| Footprint | Heavy, several GB of RAM for one instance | Light, a single small container |

**Rollout plan**

- [ ] Write `ADR-0001: adopt this workflow` and `ADR-0002: Gitea or GitLab`
- [ ] Build the template repo: `CLAUDE.md`, `.claude/agents/`, issue and MR templates, labels, `CODEOWNERS`
- [ ] Add the CI security baseline in warn-only mode
- [ ] Create bot accounts, scoped tokens, protected branches and the Claude Code deny list
- [ ] Pilot one epic end to end (suggested: the Supabase key exposure fix), including its retro
- [ ] Review the pilot retro, switch criticals to blocking, roll out to the other repos

**Open questions**

- One repo per app plus a shared `platform` repo for cross-cutting ADRs, or a monorepo?
- Who is the second human reviewer for `sec/*` changes on a one-person team?
