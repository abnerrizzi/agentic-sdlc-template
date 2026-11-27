# DevSecOps Workflow with Claude Agents - Full Conversation Export

Version: 1.2
Updated: 2026-11-27
Owner: Abner

| Version | Date | Change |
| --- | --- | --- |
| 1.0 | 2026-11-27 | First export: artifacts, decisions, full v3 proposal, research notes, chat answers, v1/v2 appendices |
| 1.1 | 2026-11-27 | Added sections 8 to 12: repo names, kickoff prompt, SDLC, GitHub setup, raw chat export |
| 1.2 | 2026-11-27 | Version header and changelog added; dates corrected to 2026-11-27; artifact versions bumped (docs v1.1, v2.1, v3.1; dashboards v1.1, v2.1; kickoff prompt v1.1) |

This file collects everything produced in the conversation: the artifacts, the decisions, the current proposal (v3) in full, the research notes, the chat answers, and the parts of v1 and v2 that are not repeated in v3.

---

## 0. Artifacts

| Artifact | Link | Status |
| --- | --- | --- |
| Proposal v1.1 (doc) | https://claude.ai/artifact/T2TXXB8snskNYmTBf5yWJY | Superseded |
| Dashboard v1.1 (HTML) | https://claude.ai/artifact/Mzhah8xmBn1BaFEJA3KC7r | Superseded |
| Proposal v2.1 (doc) | https://claude.ai/artifact/9b2sEXLXd5nNPi25xPECtF | Superseded |
| Dashboard v2.1 (HTML) | https://claude.ai/artifact/Vje2d4vKeNPwrs9Cxq9Bt1 | Superseded |
| Proposal v3.1 (doc) | https://claude.ai/artifact/KS2g67skTjJ7xdt5ji3J4r | **Current** |
| Dashboard v3 (HTML) | Not built yet | Pending |
| Claude Code kickoff prompt v1.1 | `agentic-sdlc-template-kickoff-prompt-v1.1.md` (also embedded in section 9) | Ready to use |

---

## 1. Timeline and decisions

1. **v1 asked for:** a DevSecOps workflow for working with Claude agents. It had to cover how to track thoughts, decisions, tasks, epics and stories; an agent model table; foundation principles; plan > breakdown > build > review > learnings (dos and don'ts); mainly git/Gitea/GitLab.
2. **Model and effort per task** were added to the lifecycle. Effort ladder: low, medium, high (API default), xhigh, max.
3. **Obsidian as a second brain:** worth it as an editor over Markdown in git, not as a system of record.
4. **The dashboard format chosen** was an HTML one-pager, not slides.
5. **CS329A (Stanford, Self-Improving AI Agents)** was added as a source of agent principles.
6. **Obsidian decision:** use the **free version, locally per user**. One main company repo is cloned (staff) or forked (externals), and changes go through branches and MR/PR to main. No paid Sync, no shared online vault.
7. **"Vault" confusion resolved:** an Obsidian vault is just a notes folder. Passbolt and Keeper are password managers, and OpenBao or HashiCorp Vault is a machine secrets engine.
8. **"Easy implementation" requested:** day one is two repos, one CI job, one `CLAUDE.md`, plus Obsidian locally.
9. **Platform decision:** ignore Gitea-first. Use **GitLab and GitHub, sometimes Gitea**, so everything must be **platform-agnostic**.
10. **Inbox design requested:** where the Obsidian folders live, and what, when and why for the capture, build failure, review failure and learnings inboxes.
11. **v3 proposal created**, platform-agnostic, with inboxes and Obsidian placement. The v3 dashboard is still to do.
12. **Full export** of the conversation to Markdown requested and produced.
13. **Public repo naming:** 57 name options proposed; **`agentic-sdlc-template` chosen**.
14. **Kickoff prompt** written for Claude Code to build the repo from an empty folder; model and effort chosen: `opusplan` at high, then a fresh Opus xhigh session for the final review.
15. **SDLC** explained: Software Development Life Cycle.
16. **GitHub repo creation** fields and post-creation settings defined.

---

## 2. Proposal v3.1 (current, full text)

### What's new in v3

v3 works the same on GitLab, GitHub and Gitea. It also defines exactly where Obsidian folders live and how capture, build failures, review findings and learnings flow through inboxes.

- **Platform-agnostic.** All logic lives in files and in `make check`; the CI files for each platform are thin wrappers. "MR/PR" means a merge request on GitLab or a pull request on GitHub and Gitea.
- **Easy start first.** A day-one version with two repos, one CI job and one `CLAUDE.md`. Everything else is added when the simple version starts to hurt.
- **Inboxes.** Capture is private and local. Build failures, review findings and incidents are team signals, written as files inside the MR/PR that fixes them, and processed in batches at retro.
- **Obsidian placement.** Two vaults per laptop, used at the two ends of the cycle: thinking before, learning after. Tracking stays on the platform.
- **Kept from v2.** CS329A agent principles, the model and effort table, security gates and the company knowledge repo.

### Easy start

Day one is two repos, one CI job, one `CLAUDE.md` and Obsidian on your laptop, on whichever platform the project already uses. The rest of this doc is the target, added piece by piece when the simple version hurts.

| Phase | Set up | Effort | Skipped for now |
| --- | --- | --- | --- |
| **Day 1** | Two repos on the project's platform: `company-kb` and `project-template`. Issues + labels (`type/`, `status/`) + milestones as epics. Protected main. | ~2 hours | Paid epics, boards, bot accounts |
| **Day 1** | Clone `company-kb` and open it in Obsidian with obsidian-git (pull on open). Create `_local/inbox/`. Wikilinks off, so links render on every platform. | ~1 hour | Read-only website: GitLab, GitHub and Gitea all render Markdown in the browser |
| **Day 1** | `Makefile` with `make check` (gitleaks to start). Thin CI files that only call it: `.gitlab-ci.yml` and `.github/workflows/check.yml` (Gitea Actions reads the GitHub syntax). | ~1 hour | Semgrep, Trivy, SBOM, signing |
| **Week 1** | `CLAUDE.md`: stack, "run `make check` and fix until green, max 5 loops", "review your diff against these rules", "log friction in `docs/learnings/inbox/`", 5 dos and don'ts. | ~2 hours | Separate agents, best-of-N, evals |
| **Week 1** | Model defaults: Sonnet 5.5 high for everything; Opus 5.5 for plans, threat models and security review. | 0 | Per-task effort table |
| **Week 1** | Pilot one small epic with Claude Code run locally. One retro at the end that processes the inbox. | the epic | Retro agent, eval set |
| **When it hurts** | Add from below: more scanners (warn first), bot account + deny list, verifier path rule, Passbolt, eval set, read-only site. | per item | - |

### Principles

Workflow rules keep the process safe and traceable on any platform. Agent rules, drawn from Stanford's CS329A seminar on self-improving agents, make agents better over time without making them less safe.

**Workflow rules**

1. **Git is the source of truth.** If it is not in a repo or the platform's tracker, it did not happen.
2. **Platform-agnostic by default.** Logic lives in files and `make check`; platform features are conveniences, never dependencies.
3. **Agents propose, humans decide.** No agent merges, approves its own MR/PR, or holds prod credentials.
4. **Small batches.** One story, one branch, one MR/PR, reviewable in 15 minutes.
5. **Read-only first.** Diagnose and `plan` before `apply`; every risky MR/PR carries rollback steps.
6. **Security is enforced, not requested.** Checks run in CI and block on criticals.
7. **Capture fast, decide later.** Signals go to an inbox without judgement and are processed in batches.
8. **Everything as code.** Infra, pipelines, policies and agent instructions go through MR/PR.

**Agent rules (CS329A)**

9. **Verify before you ask.** The agent loops generate, verify, fix against `make check` until green, max 5 loops, then opens the MR/PR.
10. **A written constitution.** `CLAUDE.md` and these principles are the rubric the agent critiques its own diff against.
11. **Spend compute where it pays.** Low effort for chores, high for building, xhigh and best-of-N only for hard or risky work.
12. **Memory is curated.** Agents read the knowledge repo and project learnings; only merged text becomes memory.
13. **Measure, don't guess.** A regression set of past tasks runs before any prompt, `CLAUDE.md` or model change merges.
14. **Verifiers are protected.** An agent never weakens a test, rule or threshold to make its own work pass.
15. **Every cycle teaches.** An epic closes only when its inbox is processed and its retro merged.

### Lifecycle v3

Seven stages, each with one gate. Inside Build the agent runs `make check` and fixes its own work up to 5 times. Friction from Build and Review is written to the project inbox, and the retro turns repeated signals into rules.

Flow (the diagram in the doc, as text):

```text
0. Capture -> 1. Plan -> 2. Breakdown -> 3. Build (verify, fix, max 5 loops)
                                              |  ^
                                    draft MR/PR  |  rework
                                              v  |
6. Learn  <-  5. Release  <-  4. Review
   ^   |
   |   +-> feeds the next Plan
   |
   +-- processed at retro -- docs/learnings/inbox  <-- build failures (from Build)
                                                   <-- review findings (from Review)
```

| Stage | Output | Gate to move on |
| --- | --- | --- |
| 0. Capture | Note in `_local/inbox/`, later an issue | Weekly triage |
| 1. Plan | Epic (milestone + parent issue) and draft ADR, after reading `company-kb` | Epic approved, ADR accepted |
| 2. Breakdown | Stories with criteria, tasks, security notes | Definition of Ready |
| 3. Build | Code, tests, MR/PR with Verify loop and Self-critique sections; inbox entry if friction | `make check` green, self-critique done |
| 4. Review | Fresh-session AI review + human review; inbox entry for findings a rule could catch | Approvals, zero open criticals |
| 5. Release | Tag, image, deploy dev, qa, prod | Prod approval, rollback tested in qa |
| 6. Learn | Retro file, promotions, `company-kb` MR/PR | Inbox processed, retro merged |

### Where the folders live

Each laptop has two kinds of folder: the company knowledge repo clone (with a private, never-pushed corner), and the project repos (whose `docs/` holds the team's inboxes and learnings). Obsidian opens two vaults: `company-kb`, and the `docs/` folder of the project you're on.

```text
~/vaults/company-kb/            # clone of the shared KB repo, any remote (GitLab, GitHub, Gitea)
  _local/                       # gitignored: private, never pushed
    inbox/                      # raw capture: ideas, links, questions
    drafts/                     # notes being shaped before an MR/PR
  runbooks/  howto/  patterns/  architecture/  glossary/
  templates/                    # note and inbox-entry templates
  CLAUDE.md  CODEOWNERS

~/code/<project>/               # each project repo
  CLAUDE.md  Makefile           # make check = every verifier
  .gitlab-ci.yml                # thin: calls make check
  .github/workflows/check.yml   # thin: calls make check (Gitea Actions reads it too)
  CODEOWNERS
  docs/                         # open THIS folder as a vault, never the whole repo
    adr/
    learnings/
      inbox/                    # team signals: build failures, review findings, incidents
      2026-11-epic-12.md        # retro output
  evals/                        # agent eval cases, added later
```

**Why two places:** your private capture must never leak into a repo, and team signals must never stay on one laptop. `_local/` is gitignored, so only your normal laptop backup covers it. Make it its own private repo if you want history.

### Inboxes: capture, failures, learns

Inboxes separate capturing a signal (fast, no decisions) from acting on it (judgement, in batches). Without them, signals get lost, or one-off noise goes straight into `CLAUDE.md` and makes agents worse.

| Signal | Inbox | Who writes it | Create an entry when | Processed |
| --- | --- | --- | --- | --- |
| Capture: ideas, questions, "we should" | `company-kb/_local/inbox/` (private) | You | Anytime, no judgement | Weekly, 15 min: delete, open an issue, or move to `drafts/` |
| Build failure | `<project>/docs/learnings/inbox/` | The agent, inside its fix MR/PR | Verify loop hit 5, same check failed in 2+ MR/PRs, a human had to step in, or the fix took over 30 min | At epic retro |
| Review finding | `<project>/docs/learnings/inbox/` | The agent addressing the review | A rule could have caught it, any `sec/*` finding, or the same comment in 2+ MR/PRs | At epic retro |
| Incident | `<project>/docs/learnings/inbox/` | Whoever runs the RCA | Always | Postmortem, then retro |
| Learn | `<project>/docs/learnings/<epic>.md` | Retro agent drafts, you approve | Epic or incident closes | Promoted (ladder below) |

**Not every red build is a signal.** Red then green inside the verify loop is the loop working. Only friction that repeats or needs a human gets an entry.

**Entry format:** one small file per event, written in the same MR/PR as the fix, so it works on any platform with no API calls.

```markdown
---
type: build-failure        # build-failure | review-finding | incident
date: 2026-11-27
ref: "!45 or #45"          # the MR/PR
story: "#123"
check: semgrep
tags: [sql, api]
---
What failed:
Root cause:
Fix:
Could a rule catch this earlier? yes/no + how
```

**At retro**, the agent groups inbox entries by `tags`. Anything seen twice or more is promoted to the strongest place that can hold it, then the processed files are deleted (git keeps the history):

1. **CI rule** in `make check` (strongest)
2. **`CLAUDE.md`** dos and don'ts
3. **ADR**, if it changed a decision
4. **`company-kb/patterns/`**, if it applies beyond this project (via MR/PR)
5. **Learnings log** only, if it is context rather than a rule

Once the eval set exists, any agent mistake that a human fixed also becomes a new eval case.

### Obsidian in the workflow

Obsidian is worth it as the editor for Markdown that already lives in git. It is free, takes about an hour to set up, and is strongest at the two ends of the cycle. Tracking, builds and reviews stay on the platform and in the IDE.

| Stage | Obsidian's role | Result ends up in |
| --- | --- | --- |
| 0. Capture | Quick notes in `_local/inbox/` | An issue on the platform, link pasted back into the note |
| 1. Plan | Draft the ADR next to related notes and runbooks | `docs/adr/` via MR/PR |
| 2. Breakdown | None | Issues |
| 3. Build | Read runbooks and patterns | Code in the IDE + Claude Code; failure entries written by the agent |
| 4. Review | None | MR/PR; review-finding entries written by the agent |
| 5. Release | Follow and update the runbook | `company-kb/runbooks/` via MR/PR |
| 6. Learn | Read the inbox, edit the retro, promote patterns | `docs/learnings/`, `company-kb/patterns/` |

**Setup:** two vaults (`company-kb`, and the project's `docs/`). Plugins: obsidian-git (pull on open) and core Templates, nothing else at first. Turn wikilinks off so links render on GitLab, GitHub and Gitea.

**The integration that pays off:** a vault is a folder, so Claude Code runs in it directly, with no plugin or MCP server. Useful asks: "turn this week's `_local/inbox/` into issues and drafts", "group `docs/learnings/inbox/` by tag and propose promotions", "list runbooks past their review-by date". The output is a branch and an MR/PR, like any other agent work.

**Not worth it for:**
- Tasks or boards: that splits the source of truth from the platform.
- Forcing it on occasional contributors: the platform's web editor is enough.
- Real-time co-editing: use Claude Docs for drafts with non-git people.

### Company knowledge repo

One `company-kb` repo lives on whichever platform the company standardises on. Staff clone it and push short-lived branches; contractors, clients and anyone outside the team fork it. Everything reaches main through a reviewed MR/PR.

Flow (the diagram in the doc, as text):

```text
company-kb (main, any platform) -> Clone or fork (staff clone, externals fork)
  -> Local Obsidian (free app, capture in _local/) -> Branch and push (kb/name/topic)
  -> MR / PR (CI: make check, gitleaks, links) -> Owner review (CODEOWNERS per folder)
  -> merge into main -> Browser view (platform renders the Markdown, free)
                     -> Agents (read main only, as curated memory)
```

| Who | How they contribute | Can merge |
| --- | --- | --- |
| Staff comfortable with git | Clone, branch `kb/<name>/<topic>`, push, MR/PR | Only folders they own (CODEOWNERS) |
| Occasional contributors | The platform's web editor: edit, commit to a new branch, open the MR/PR | No |
| Contractors and externals | Fork, branch, MR/PR from the fork | No |
| Agents | Branch `agent/kb-<topic>`, MR/PR with sources cited | No, human approval |
| Folder owners | Review and merge for their folder | Yes |

**Rules:**
- Pull before you write; branches live a day or two.
- One repo per confidentiality boundary: no client secrets in `company-kb`.
- `.obsidian/` commits only the approved plugin set.
- CI runs gitleaks and a link check.
- Agents read main only, never branches or `_local/`.

**Three things called "vault", unrelated:**

| Name | What it is | Holds |
| --- | --- | --- |
| Obsidian vault | A local folder of notes, here a clone of `company-kb` | Knowledge. Never secrets. |
| Passbolt | Team password manager; Community Edition is free and self-hosted (SSO/LDAP need a paid edition) | Human passwords |
| OpenBao / HashiCorp Vault | Secrets engine for machines; OpenBao is the open-source fork | App and pipeline secrets, injected at runtime |

A note says *where* a secret lives ("Supabase service key: OpenBao `kv/comurg/api`"), never the secret itself. gitleaks blocks it anyway.

### Self-improving agents (CS329A) in practice

CS329A covers agents that improve through interaction with themselves and their environment. Each technique below becomes something concrete, and none needs a specific platform.

| Technique | What it means here | Day 1? | Guardrail |
| --- | --- | --- | --- |
| Verifiers | Everything in `make check`: tests, linters, gitleaks, later Semgrep, Trivy, policies | Yes | Verifier files owned by humans via CODEOWNERS |
| Learning from tool feedback | Agent runs `make check`, reads errors, fixes, repeats | Yes | Max 5 loops, then stop and log an inbox entry |
| Constitutional self-critique | Agent checks its diff against `CLAUDE.md` before the MR/PR and lists what it checked | Yes | Checklist goes in the MR/PR description |
| Memory | `company-kb` main and project learnings, read at task start | Yes | Only merged, reviewed text |
| Planning | Plan approved before code; long tasks split into checkpoints | Yes | One story per MR/PR |
| Test-time compute | Effort level per task; best-of-N with tests picking the winner | Later | Best-of-N only on `agent/hard` stories |
| Agent evaluation | 20 to 30 past tasks with known-good outcomes, re-run on prompt, `CLAUDE.md` or model changes | Later | Merge blocked if the pass rate drops |

**Verifiers can be fooled:** an agent told to make CI green can do it by deleting a test. Agents never edit tests, CI files, rules or thresholds in the same MR/PR as the code they check.

### Model and effort per task

Day 1 uses two defaults: Sonnet 5.5 at high for everything, and Opus 5.5 for plans, threat models and security review. The full table below is the target once the pilot shows where it matters. Effort ladder: `low` > `medium` > `high` (API default) > `xhigh` > `max`. Use `max` only after `xhigh` has failed.

| Stage | Task | Model | Effort | Best-of-N | Escalate to |
| --- | --- | --- | --- | --- | --- |
| 0. Capture | Triage `_local/inbox/`, label, spot duplicates | Haiku 5.5 | default | No | Sonnet 5.5 `low` |
| 1. Plan | Architecture options, ADR draft (reads `company-kb` first) | Opus 5.5 | high | 2 drafts, you pick | Fable 5.2 `high` |
| 1. Plan | Threat model per component | Opus 5.5 | xhigh | No | Human security review |
| 2. Breakdown | Epic > stories, criteria, tasks | Sonnet 5.5 | medium | No | Opus 5.5 `high` |
| 3. Build | Feature code, IaC, verify loop, self-critique | Sonnet 5.5 | high | Only `agent/hard` | Sonnet `xhigh`, then Opus 5.5 |
| 3. Build | Large refactor or migration | Opus 5.5 | xhigh | 2-3 attempts, tests pick | Fable 5.2 `xhigh` |
| 3. Build | Write a build-failure inbox entry | Same as builder | same | No | - |
| 3. Build | Tests scaffold, docs, commit messages, CI log triage | Haiku 5.5 | default | No | Sonnet 5.5 `low` |
| 4. Review | First-pass review, fresh session | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| 4. Review | Security review (`sec/*`) | Opus 5.5 | xhigh | No | Human approval always |
| 5. Release | Check plan/diff and rollback steps | Sonnet 5.5 | high | No | Opus 5.5 `high` |
| Any | Incident RCA, postmortem draft | Opus 5.5 | xhigh | No | Fable 5.2 `xhigh` |
| 6. Learn | Group inbox by tag, propose promotions | Sonnet 5.5 | medium | No | Opus 5.5 `high` |
| 6. Learn | Turn a learning into a check in `make check` | Sonnet 5.5 | high | No | Opus 5.5 `high` |

The Haiku rows say "default" because the effort docs don't list Haiku as supported. Fable 5.2 carries extra cybersecurity safeguards, so keep it on design work, not attack-style testing.

### Security gates and guardrails

Every check is a target in `make check`, so it runs the same locally, in the agent's verify loop, and in GitLab CI, GitHub Actions or Gitea Actions. Start with gitleaks. Add the rest warn-only, then make criticals blocking.

| When added | Check | Tool | Blocks on |
| --- | --- | --- | --- |
| Day 1 | Secrets (code and `company-kb`) | gitleaks | Any finding |
| After pilot | SAST | Semgrep | Critical / high |
| After pilot | Dependencies, IaC, container image | Trivy (fs, config, image) | Critical |
| After pilot | Verifier integrity: code and its tests, CI files or rules in one MR/PR | CI path rule + CODEOWNERS | Human owner approval |
| Later | SBOM + signing | Syft + Cosign | Must exist |
| Later | Agent eval set | Eval job | Pass rate drops |
| Always | Prod deploy | Protected environment + rollback plan in MR/PR | Manual approval |

**Agent guardrails:**
- A bot account per role once you have more than one agent. Tokens can push branches and open MR/PRs, but never merge.
- A Claude Code deny list for `terraform apply`, `kubectl delete`, the prod context, `rm -rf` and reading `.env`.
- The verify loop is capped at 5.
- Agents never edit verifiers alongside the code they check.
- Text from outside the team (issues, comments, forks) is untrusted input.

### Platform mapping

The template repo ships both a `.gitlab/` and a `.github/` folder. Gitea reads most `.github/` files, so two folders cover three platforms. Use only what is in the "agnostic choice" column; paid-tier extras are optional.

| Need | GitLab | GitHub | Gitea | Agnostic choice |
| --- | --- | --- | --- | --- |
| Change request | Merge request | Pull request | Pull request | Call it MR/PR in docs and `CLAUDE.md` |
| CI | `.gitlab-ci.yml` | `.github/workflows/` | Gitea Actions, GitHub syntax | Thin files that call `make check` |
| Epics | Epics (paid tier) | Milestones, parent issues | Milestones | Milestone + parent issue with a task list |
| Labels | Yes | Yes | Yes | `type/`, `status/`, `prio/`, `sec/`, `agent/` |
| Issue / MR-PR templates | `.gitlab/` | `.github/` | `.gitea/` or `.github/` | Ship `.gitlab/` and `.github/` |
| Code owners | `CODEOWNERS` | `CODEOWNERS` | `CODEOWNERS` | One file at repo root; enforcement may need a paid tier on private repos |
| Protected main | Yes | Yes | Yes | No direct push, review required |
| Browser editing | Web editor | Web editor | Web editor | Occasional contributors use it, branch + MR/PR in one step |
| Markdown view | Rendered | Rendered | Rendered | The free read-only view of `company-kb` |

The table reflects common defaults, not a guarantee for every version. Check each platform's docs for the current file locations before writing the template.

### Rollout, open questions, sources

**Rollout**

- [ ] Create `company-kb` and `project-template` on the platform of the first project
- [ ] Template: `CLAUDE.md`, `Makefile` (`make check` = gitleaks), thin `.gitlab-ci.yml` and `.github/workflows/check.yml`, `.gitlab/` and `.github/` templates, `CODEOWNERS`, `docs/learnings/inbox/`
- [ ] Clone `company-kb`, set up the two Obsidian vaults and `_local/inbox/`
- [ ] Pilot one small epic with Claude Code locally: verify loop, self-critique, inbox entries
- [ ] First retro: process the inbox, promote what repeats, write the learnings file
- [ ] Add Semgrep and Trivy warn-only, the verifier path rule and the deny list
- [ ] Build the first 10 eval cases from the pilot; switch criticals to blocking
- [ ] Copy the template to the other projects and platforms

**Open questions**

- Which platform hosts `company-kb` when projects live on GitLab, GitHub and Gitea at once?
- One repo per app plus a shared `platform` repo, or a monorepo?
- Who is the second human reviewer for `sec/*` on a one-person team?
- Passbolt Community Edition (free, no SSO/LDAP) or a paid edition?

**Sources**

- CS329A Self-Improving AI Agents, Stanford: https://cs329a.stanford.edu/
- CS329A course description, Stanford Bulletin: https://bulletin.stanford.edu/courses/2263721
- When does verification pay off? (verifier limits): https://arxiv.org/pdf/2512.02304
- Claude effort parameter: https://platform.claude.com/docs/en/build-with-claude/effort
- Obsidian is free for work: https://obsidian.md/blog/free-for-work/
- Passbolt Community Edition overview: https://itsfoss.com/passbolt-review.md

---

## 3. Research notes

**CS329A (Stanford, Self-Improving AI Agents)**
- A graduate seminar on agents that improve through self-interaction and their environment.
- Topics: constitutional AI, verifiers, scaling test-time compute, search combined with LLMs, RL training, tool use, code, memory, orchestration, multi-step planning, and evaluation of agentic systems.
- Key caution from related research: LLM verifiers can produce false positives and fail to pick the right solution. Hence the "verifiers are protected" rule and human final approval.

**Obsidian**
- The commercial license became optional: Obsidian is free for work.
- Obsidian Sync shared vaults (considered, then rejected in favour of free local + git):
  - About $4/user/month billed annually.
  - Collaborators get the owner's permissions, with no granular roles.
  - Up to about 20 collaborators per shared vault.
  - Edits merge on sync, with no live co-editing.
- Other options considered: a git-backed vault (chosen), or self-hosted sync through a community plugin (more plugin supply-chain risk).
- There is no free hosted Obsidian; Publish and Sync are paid. The free read-only view comes from the platform rendering Markdown, or later a static site (Quartz or MkDocs) built by CI.

**Passbolt / Keeper**
- Passbolt Community Edition: free, open source, self-hosted. SSO, account recovery and LDAP/AD come with paid editions.
- Keeper is a paid commercial product.

**Claude effort parameter**
- Levels: low, medium, high (default), xhigh, max.
- Step down for routine work. Use xhigh for the hardest coding, agentic and security tasks, and max only when xhigh has already failed.
- Haiku is not listed as supported for effort in the docs, so it runs at the default.

**Claude models referenced:** Haiku 5.5, Sonnet 5.5, Opus 5.5, Fable 5.2. Fable 5.2 is Mythos-class, with extra biology and cybersecurity safeguards.

---

## 4. Chat answers (not fully in the docs)

### 4.1 Obsidian as a second brain: worth it? (EN)

Worth it, if you treat it as a viewer and scratchpad over Markdown files in git, not as another system of record.

- **Why it helps:**
  - Thinking before an idea is ready for the repo.
  - Cross-client memory: lessons repeat across clients.
  - Better agent context, because Claude Code reads Markdown natively.
  - A nice front end for a repo's `docs/`, with graph view, backlinks and search.
- **When it's worth it:** you juggle 3 or more projects or clients and keep re-researching the same things, and you want a knowledge base that outlives any job or repo.
- **When it isn't:** a single project, where the repo's `docs/` is enough. It is also never the team's source of truth.
- **How:**
  - Two layers: a private vault, and the repos as the record.
  - A promotion rule: notes that become decisions, tasks or learnings move to the repo.
  - Separate vaults per confidentiality boundary.
  - A `CLAUDE.md` at the vault root.
- **Where each tool fits:** Obsidian for private thinking, Claude Docs for shared drafts with non-git people, git for the record.

### 4.2 Mesma resposta em portugues (PT-BR)

Vale a pena, se voce tratar como um visualizador e rascunho sobre arquivos Markdown no git, e nao como mais um sistema de registro.

- **Por que ajuda:**
  - Pensar antes de estar pronto pro repo.
  - Memoria entre clientes.
  - Contexto melhor pros agentes, ja que o Claude Code le Markdown nativamente.
  - Uma boa interface pro `docs/`, com graph view, backlinks e busca.
- **Quando vale:** 3 ou mais projetos ou clientes, pesquisando as mesmas coisas de novo, e voce quer uma base de conhecimento de longo prazo.
- **Quando nao vale:** um projeto so, onde o `docs/` basta. E nunca como fonte da verdade do time.
- **Como montar:**
  - Duas camadas: vault pessoal e repos como registro.
  - Regra de promocao: notas que viram decisao, tarefa ou learning vao pro repo.
  - Vaults separados por fronteira de confidencialidade.
  - Um `CLAUDE.md` na raiz do vault.

### 4.3 How to integrate Obsidian, and is it worth it

- **Yes**, but only as the editor for Markdown that already lives in git. Obsidian never holds tasks or decisions that exist only there.
- **It lives at the two ends of the cycle:** thinking before (Capture, Plan) and learning after (Release runbooks, Learn). The middle stays in the platform and the IDE.
- **The real integration** is running Claude Code inside the vault folder, with no plugin or MCP server needed.
- **Not worth it for:** tasks or boards (Tasks/Kanban plugins split the source of truth), forcing it on colleagues, or real-time co-editing.

### 4.4 Easy implementation (first cut, before platform-agnostic)

- One platform instance and two repos (`company-kb`, `project-template`). Issues + labels + milestones cover epics and stories.
- Obsidian + obsidian-git with wikilinks off. The platform renders Markdown, so that is the free read-only view.
- Non-git colleagues use the platform's web editor, which commits to a new branch and opens the MR/PR in one step.
- One CI job: gitleaks.
- One `CLAUDE.md`: run `make check` and fix until green, then review your own diff against the rules. That gives the core CS329A idea with zero extra tooling.
- Two model defaults: Sonnet 5.5 high for everything, Opus 5.5 for plans and security reviews.
- Everything else is added "when it hurts".

---

## 5. Appendix A: v1 content not repeated in v3

### v1 lifecycle with "who does it"

| Stage | Input | Output | Gate | Who |
| --- | --- | --- | --- | --- |
| 0. Capture | A thought, request or alert | Issue labelled `type/idea` | Weekly triage: promote to epic or close | Anyone |
| 1. Plan | Idea, business need | Epic (outcome, scope, non-goals, metric) + draft ADR | Human approves epic, ADR accepted | Planner agent + you |
| 2. Breakdown | Approved epic | Stories with acceptance criteria, task checklist, security notes, estimates | Definition of Ready | Breakdown agent + you |
| 3. Build | Ready story | Branch, code, tests, draft MR/PR with rollback steps | CI green: tests + security scans | Builder agent (Claude Code) |
| 4. Review | Draft MR/PR | Review comments, fixes, approvals | AI review in fresh session + human approval via CODEOWNERS, zero open criticals | Reviewer agent + human |
| 5. Release | Merged MR/PR | Tag, image, deploy dev > qa > prod via GitOps | Manual approval for prod, rollback tested in qa | Pipeline + you |
| 6. Learn | Closed epic or incident | Learnings entry, updated `CLAUDE.md`, new CI rule or ADR | Retro merged, then epic closes | Retro agent + you |

### Tracking model (v1 detail)

| Item | Lives in | Format | States |
| --- | --- | --- | --- |
| Thought / idea | Issue `type/idea` | Free text, 3-5 lines | open > promoted or closed |
| Decision (ADR) | `docs/adr/0007-use-k3s.md` | MADR template | proposed > accepted > superseded |
| Epic | Paid epics, or parent issue `type/epic` + milestone | Outcome, scope, non-goals, success metric, child stories | open > in progress > retro > closed |
| Story | Issue `type/story` | User story, acceptance criteria, security notes, tasks | ready > doing > review > done |
| Task | Checklist inside the story | One line each | open > ticked |
| Bug / incident | Issue `type/bug` / `type/incident` | Repro or timeline | open > fixed > postmortem |
| Threat model | `docs/threat-models/<component>.md` | STRIDE-lite table | living doc |
| Learning | `docs/learnings/` | Learned / Do / Don't / Evidence | append-only |
| Agent run | MR/PR description | Model, task, what changed, what was skipped | per MR/PR |

Traceability chain: commit `feat(api): rate-limit login (#123)` > MR/PR `Closes #123` > story #123 > epic > ADR-0007.

### Story template

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

### Project repo layout with Claude Code folders

```text
repo/
  CLAUDE.md                   # agent rules: stack, commands, dos and don'ts (keep under ~150 lines)
  .claude/
    agents/                   # subagents: planner, breakdown, reviewer, security-reviewer
    commands/                 # slash commands: /plan /breakdown /review /retro
    settings.json             # tool permissions: allow/deny lists
  docs/
    adr/  threat-models/  learnings/  postmortems/
  .gitlab/  .github/          # issue and MR/PR templates
  CODEOWNERS
  infra/                      # terraform/, ansible/, k8s manifests
  src/
```

### Conventions

| Convention | Rule | Example |
| --- | --- | --- |
| Branch | `<type>/<issue>-<slug>` from main, deleted after merge | `feat/123-login-rate-limit` |
| Commit | Conventional Commits + issue ref | `fix(auth): expire refresh tokens (#123)` |
| MR/PR title | Same as the story title | `Rate-limit login endpoint` |
| Labels | `type/`, `status/`, `prio/`, `sec/`, `agent/` | `type/story`, `sec/auth`, `agent/authored`, `agent/hard` |
| Protected main | No direct push, squash merge, linear history | - |
| Tags | SemVer, created by the pipeline only | `v1.4.0` |

MR/PR template sections:
- Summary
- Story link (`Closes #`)
- ADR link
- Test evidence
- Security checklist
- Rollback steps
- Agent disclosure (model, what was generated, human reviewer)
- Verify loop (v2)
- Self-critique (v2)

### Learnings entry example (v1)

```markdown
## 2026-11 - Epic &12 Auth API
**Learned:** Supabase RLS policies were the only auth layer; API had none.
**Do:** Enforce authz in the API layer and test it per endpoint.
**Don't:** Ship anon keys in frontend bundles.
**Evidence:** !45, #50, pipeline 1932
**Promoted to:** CI rule (gitleaks custom pattern), CLAUDE.md
```

Prune `CLAUDE.md` each quarter: merge duplicates, drop rules now enforced by CI, and keep it short.

### Where Claude Docs fits versus git

| Use Claude Docs for | Use git and the tracker for |
| --- | --- |
| Early thinking and options before a decision | Accepted decisions (ADRs) |
| Proposals for clients or non-git people | Epics, stories, tasks and status |
| Meeting notes and workshop output | Anything an agent or pipeline reads |
| Drafts needing comments from non-technical reviewers | Learnings, threat models, postmortems |

Hand-off rule: when a doc is agreed, put the decision in `docs/adr/` or an epic, link it at the top of the doc, and stop editing the doc.

### Full deploy-side security (target)

- Kyverno in k3s: signed images only, policy checks.
- Vault / OpenBao: secrets injected at runtime, never in the repo.

---

## 6. Appendix B: v2 content not repeated in v3

- **company-kb folders (v2):**
  - `00-start-here.md`, `runbooks/`, `howto/`, `patterns/`, `architecture/`, `glossary/`, `templates/` (frontmatter with owner and review-by date)
  - `_local/` (gitignored), `.obsidian/` (shared settings + plugin allowlist; workspace files gitignored)
  - `CLAUDE.md`, `CODEOWNERS`
- **Agent eval set:** lives in `evals/` in a platform repo: task + expected outcome + grader. Haiku can grade; a human looks at failures.
- **Read-only site option:** Quartz (closest to Obsidian, keeps backlinks) or MkDocs (simpler, very common), built by CI on merge and served internally behind SSO. In v3 this is postponed, because the platform's Markdown rendering is enough to start.

---

## 7. Next steps (see also sections 8 to 12)

- [ ] Build the v3 dashboard (HTML one-pager matching the v3 doc).
- [ ] Generate the starter kit:
  - `company-kb` skeleton (folders, templates, `CODEOWNERS`, `CLAUDE.md`)
  - `project-template` (`CLAUDE.md`, `Makefile` with `make check`, thin `.gitlab-ci.yml` + `.github/workflows/check.yml`, `.gitlab/` + `.github/` templates, `docs/learnings/inbox/` with the entry template)
- [ ] Answer the open questions listed in the v3 rollout section.
- [ ] Create the GitHub repo (section 11) and run the kickoff prompt (section 9).


---

## 8. Public repo naming (57 options)

Collision risk is a rough read on how crowded the name already is. Check GitHub, npm and PyPI before committing.

| # | Name | Style | Why it fits | Collision risk |
| --- | --- | --- | --- | --- |
| 1 | `agentic-devsecops` | Descriptive | Says exactly what it is | Medium |
| 2 | `git-first-agents` | Descriptive | Core principle: git is the source of truth | Low |
| 3 | `verify-loop` | Descriptive | The CS329A core idea | Low |
| 4 | `agent-workflow-kit` | Descriptive | Starter kit framing | Medium |
| 5 | `devsecops-agent-playbook` | Descriptive | Playbook = principles + steps | Low |
| 6 | `propose-verify-merge` | Descriptive | The whole flow in three verbs | Low |
| 7 | `agents-propose-humans-decide` | Descriptive | The main rule as the name | Low |
| 8 | `secure-agent-sdlc` | Descriptive | Security-first SDLC for agents | Low |
| 9 | `agentic-sdlc-template` | Descriptive | Easy to find in search (**chosen**) | Low |
| 10 | `platform-agnostic-agents` | Descriptive | GitLab, GitHub, Gitea | Low |
| 11 | `ratchet-ops` | Metaphor | Each cycle only tightens, never loosens | Low |
| 12 | `whetstone` | Metaphor | Every retro sharpens the agents | Medium |
| 13 | `forge-and-gate` | Metaphor | Build, then pass the gate | Low |
| 14 | `tollgate` | Metaphor | Nothing passes without its gate | Medium |
| 15 | `keel` | Metaphor | Keeps agents steady and on course | High |
| 16 | `lodestar` | Metaphor | Principles as the guiding star | Medium |
| 17 | `anvil` | Metaphor | Where work gets shaped and tested | High |
| 18 | `loom` | Metaphor | Weaves issues, code and learnings | High |
| 19 | `sediment` | Metaphor | Knowledge settles layer by layer | Low |
| 20 | `compound` | Metaphor | Learnings compound over time | High |
| 21 | `flywheel-ops` | Metaphor | Each cycle speeds up the next | Medium |
| 22 | `gatekeeper` | Metaphor | Gates decide | High (OPA Gatekeeper) |
| 23 | `lighthouse` | Metaphor | Guidance | High (Google Lighthouse) |
| 24 | `checkpoint` | Metaphor | Gates per stage | High |
| 25 | `learn-loop` | Knowledge | The retro loop | Low |
| 26 | `retro-ratchet` | Knowledge | Retros that lock in progress | Low |
| 27 | `signal-inbox` | Knowledge | Capture fast, decide later | Low |
| 28 | `lessons-as-code` | Knowledge | Learnings become CI rules | Low |
| 29 | `kb-as-code` | Knowledge | Knowledge repo under MR/PR | Low |
| 30 | `commonplace` | Knowledge | A commonplace book, the original second brain | Medium |
| 31 | `field-notes` | Knowledge | Notes from real work | Medium |
| 32 | `logbook` | Knowledge | The captain's log of every cycle | High |
| 33 | `waypoint` | Knowledge | Markers along the journey | High (HashiCorp) |
| 34 | `second-brain-ops` | Knowledge | Obsidian + git angle | Low |
| 35 | `vergate` | Brandable | Verify + gate | Low |
| 36 | `agentry` | Brandable | Agents + craft | Medium |
| 37 | `trustloop` | Brandable | Trust earned through the loop | Medium |
| 38 | `proofloop` | Brandable | Proof before merge | Low |
| 39 | `shipwright` | Brandable | A builder who ships safely | Medium |
| 40 | `greenlight` | Brandable | Only green gets through | High |
| 41 | `guardrail-kit` | Brandable | Guardrails out of the box | Medium |
| 42 | `gitwise` | Brandable | Git-first wisdom | Medium |
| 43 | `make-check` | Brandable | The single command behind everything | Medium |
| 44 | `red-to-green` | Brandable | The verify loop in three words | Low |
| 45 | `measure-twice` | Playful | Measure twice, merge once | Low |
| 46 | `trust-but-verify` | Playful | Exactly the agent rule | Medium |
| 47 | `dont-delete-the-test` | Playful | The reward-hacking guardrail | Low |
| 48 | `no-yolo-merge` | Playful | Humans approve every merge | Low |
| 49 | `agents-with-manners` | Playful | Agents that follow the constitution | Low |
| 50 | `robots-propose` | Playful | Short version of the main rule | Low |
| 51 | `slow-is-smooth` | Playful | "Slow is smooth, smooth is fast" | Low |
| 52 | `small-batches` | Playful | One story, one MR/PR | Medium |
| 53 | `mutirao` | Portuguese | Collective work effort, everyone contributes | Low |
| 54 | `oficina` | Portuguese | Workshop where things get built and fixed | Medium |
| 55 | `alicerce` | Portuguese | Foundation, the principles layer | Low |
| 56 | `bussola` | Portuguese | Compass, the guiding direction | Low |
| 57 | `caderno` | Portuguese | Notebook, the second-brain angle | Low |

- **Top picks given:**
  - `ratchet-ops`: memorable, every cycle locks in learning.
  - `verify-loop`: clear to agent people.
  - `agentic-sdlc-template`: the most findable.
- **Decision:** `agentic-sdlc-template`.
- **Naming note:** avoid "Claude" as the lead word of the name, since it's Anthropic's trademark. Say "works with Claude Code" in the README instead.

---

## 9. Claude Code kickoff: model, effort and prompt

### 9.1 Model and effort

- Start with **`opusplan` at high effort**. It uses Opus in plan mode and switches to Sonnet for execution, which matches the workflow's own table (Opus plans, Sonnet builds).
- Commands:

```bash
mkdir agentic-sdlc-template && cd agentic-sdlc-template
claude --model opusplan --effort high
```

- Inside Claude Code: run `/plan`, paste the prompt, review and approve the plan. Sonnet then builds phase by phase, stopping after each phase.
- Phase 7 (final review): start a **fresh session** with `claude --model opus --effort xhigh` and review against the prompt's quality bar and `CLAUDE.md`.
- Skip `max` (only after xhigh fails) and Fable (overkill for a docs and config repo).
- Gotcha: the `CLAUDE_CODE_EFFORT_LEVEL` environment variable overrides `--effort` and `/effort`. Check it with `echo $CLAUDE_CODE_EFFORT_LEVEL` if high doesn't stick.
- Sources:
  - https://code.claude.com/docs/en/model-config
  - https://code.claude.com/docs/en/commands.md
  - https://code.claude.com/docs/en/env-vars.md
  - https://claude.com/blog/claude-model-and-effort-level-in-claude-code
- Pre-set in the prompt (change before pasting if needed): license Apache-2.0, CODEOWNERS placeholder `@OWNER`.

### 9.2 The full kickoff prompt

### Kickoff: build `agentic-sdlc-template` from an empty folder

You are starting a new public, open-source repository called `agentic-sdlc-template` in the current, empty folder. Read this whole brief before doing anything.

#### 1. What we are building

A platform-agnostic template for running a DevSecOps software lifecycle with AI coding agents (Claude Code first), where:

- **Agents propose, humans decide.** Agents plan, build and review; humans approve every merge.
- **Git is the source of truth.** Every thought, decision, task, failure and learning ends up as reviewable text in a repo or the platform's tracker.
- **Agents verify their own work.** Based on Stanford CS329A (Self-Improving AI Agents): verifier loops, constitutional self-critique, curated memory, test-time compute, agent evals.
- **Every cycle teaches.** Build failures and review findings go to an inbox. A retro promotes repeated signals into CI rules, `CLAUDE.md` rules, ADRs or knowledge notes.
- **It works the same on GitLab, GitHub and Gitea.** All logic lives in files and in `make check`; the CI files are thin wrappers.

The repo has two jobs:

1. **It is a template.** People copy it to start their own projects.
2. **It dogfoods itself.** The repo is built and maintained with its own workflow, so its own `CLAUDE.md`, verifiers, inbox and ADRs are real, working examples.

Target audience: SREs, platform engineers and small teams who want agent-assisted delivery without losing traceability or security. Assume readers know git and CI, but not CS329A.

#### 2. How you will work (non-negotiable)

1. **Plan first.** You are in plan mode. Produce the plan described in section 7 and stop. Do not create files until I approve the plan.
2. **Ask before assuming.** If anything in this brief is ambiguous or conflicts, ask me. Batch your questions, at most 5, in the plan.
3. **Work in phases.** After approval, execute one phase at a time (section 6). At the end of each phase:
   - run `make check` (once it exists) and fix until green, with a maximum of 5 fix loops;
   - critique your own diff against `CLAUDE.md` and section 5 of this brief, and fix what fails;
   - commit with a Conventional Commit message;
   - stop and give me a short phase report: what changed, what you checked, what you skipped and why, and any open questions. Wait for my "go" before the next phase.
4. **Read-only before risky.** Never run destructive commands. Never push, never add a git remote, never publish anything. Never install anything globally or with sudo without asking. If a tool is missing, say so and give the install command.
5. **Verify facts you are unsure of.** For Claude Code configuration formats (subagents, slash commands or skills, `settings.json` permissions, model and effort frontmatter), GitLab CI, GitHub Actions and Gitea Actions syntax, read the current official docs before writing the file. Note the source URL in a comment or in the related doc. If you cannot verify something, mark it with `TODO(verify):` instead of guessing.
6. **Never weaken a verifier to get green.** If a check fails, fix the content, not the check. If you believe a check is wrong, stop and tell me.
7. **Log friction.** If you hit the 5-loop cap, a check fails for a non-obvious reason, or you had to work around a tool, write an entry in `docs/learnings/inbox/` using the template (section 4.6). This is the repo dogfooding itself.

#### 3. Decisions already made

- Name: `agentic-sdlc-template`
- License: Apache-2.0 (ask me if you think MIT fits better, and say why)
- Platforms: GitLab, GitHub, Gitea. Use the neutral term "MR/PR" everywhere.
- Default branch: `main`, with protected-branch guidance documented (not enforced locally).
- Owner placeholder: `@OWNER` in `CODEOWNERS` and docs. I will replace it.
- Language: English, plain and concise. No corporate prose, no marketing fluff.
- Typography: never use the em dash character; use a hyphen or rewrite the sentence.
- Diagrams: Mermaid in Markdown (renders on GitHub, GitLab and Gitea). No images.
- Obsidian: free and local only. The knowledge repo is cloned (staff) or forked (externals), and changes go through MR/PR. Wikilinks off, so links render on every platform.
- No paid platform features are required. Paid-tier features may be mentioned as optional.

#### 4. Content specification

##### 4.1 Top level

| File | Purpose |
| --- | --- |
| `README.md` | What it is, who it is for, the 30-second pitch, quick start (copy the template, 5 steps), the lifecycle Mermaid diagram, a principles summary, repo map, "works with" (GitLab, GitHub, Gitea, Claude Code), links to docs. Keep it scannable. |
| `CLAUDE.md` | The constitution for agents working on this repo and the example adopters copy. Sections: project summary, how to run checks, the verify loop rule (max 5), the self-critique rule, the inbox rule, dos and don'ts (start with 5 to 8), what agents must never do, the definition of done. Under 150 lines. |
| `LICENSE` | Apache-2.0 full text. |
| `SECURITY.md` | How to report vulnerabilities privately; supported versions; scope. |
| `CONTRIBUTING.md` | The workflow in short: issue, branch naming, Conventional Commits, MR/PR template, `make check`, review, how agent-authored MR/PRs are labelled and reviewed. |
| `CODE_OF_CONDUCT.md` | Link to and adopt the Contributor Covenant by reference with a short summary; do not paste long third-party text. |
| `CHANGELOG.md` | Keep a Changelog format, starting at Unreleased. |
| `CODEOWNERS` | Root file. `@OWNER` owns everything; verifier paths (`Makefile`, `scripts/`, CI files, lint and gitleaks configs, `.claude/settings.json`) are listed explicitly so they always need the owner. |
| `.gitignore`, `.editorconfig` | Sensible defaults, plus `_local/` ignored everywhere. |

##### 4.2 Verifiers: `Makefile` and `scripts/`

- `make check` runs every verifier and fails on any error. It must give the same result locally, in the agent's verify loop, and in CI.
- `make doctor` lists the required tools, their detected versions and install hints. It never installs anything.
- Day-1 verifiers for this repo:
  - secrets: gitleaks, with a repo `.gitleaks.toml` containing one example custom rule. Call it a "learning turned into a rule" and explain it in a comment.
  - Markdown lint: markdownlint-cli2 with a `.markdownlint-cli2.yaml`.
  - internal link check, offline only: lychee `--offline`, or an equivalent you justify.
  - YAML lint: yamllint for the CI and config files.
  - template sync: `scripts/check-template-sync.sh` fails if the GitHub and GitLab issue and MR/PR templates have drifted (same content, different folders).
  - verifier guard: `scripts/verifier-guard.sh` compares the branch against the merge base with `main`. It fails if the same change touches both verifier paths and non-verifier paths, and prints why. An explicit, documented override exists for the human owner. Agents must never use it.
- Scripts: POSIX `sh` or bash with `set -euo pipefail`, shellcheck-clean (add shellcheck to `make check`), and no network calls.
- Pin tool versions in one place (for example `tools.versions`) and document them.

##### 4.3 CI wrappers (thin)

- `.github/workflows/check.yml` and `.gitlab-ci.yml`. Gitea Actions reads the GitHub syntax; document this and any known differences.
- Each only installs pinned tools and runs `make check`.
- Supply-chain hygiene:
  - Pin GitHub Actions by full commit SHA, with the version in a comment.
  - Pin container images by digest where practical.
  - Use only releases that are at least 14 days old.
  - Least-privilege `permissions:` in GitHub Actions.
- No secrets required to run the checks.

##### 4.4 Platform templates

- GitHub (`.github/`) and GitLab (`.gitlab/`) issue templates: `idea`, `epic`, `story`, `bug`, `incident`.
- MR/PR template with these sections:
  - Summary
  - Story link
  - ADR link
  - Test evidence
  - Security checklist
  - Rollback steps
  - **Verify loop** (checks run, number of loops)
  - **Self-critique** (constitution items checked)
  - Agent disclosure (model, effort, what was generated, human reviewer)
- The story template has a user story, acceptance criteria (Given/When/Then), security notes, a task checklist, and links (epic, ADR, threat model).
- Labels are documented in `docs/labels.md` (no API calls): `type/`, `status/`, `prio/`, `sec/`, `agent/authored`, `agent/hard`.

##### 4.5 Claude Code configuration: `.claude/`

Verify the current formats in the official Claude Code docs first.

- `settings.json`: a permissions deny list covering at least `terraform apply`, `kubectl delete`, any prod kube context, `rm -rf`, reading `.env*`, reading secret token files, and `git push`. Add an allow list for the read-only and check commands the workflow needs.
- Subagents, each with a model and effort set in frontmatter if the docs support it, and each with a clear, short system prompt:
  - `planner`: Opus, high. Reads the knowledge repo and ADRs first, outputs an epic and a draft ADR.
  - `breakdown`: Sonnet, medium. Epic to stories with acceptance criteria and security notes.
  - `reviewer`: Sonnet, high. Fresh-context review against `CLAUDE.md`, never edits verifiers.
  - `security-reviewer`: Opus, xhigh. For `sec/*` changes.
  - `retro`: Sonnet, medium. Groups `docs/learnings/inbox/` by tag, proposes promotions using the ladder, drafts the learnings file.
- Slash commands or skills (whichever the current docs recommend): `/plan`, `/breakdown`, `/review`, `/retro`, `/capture` (turns notes into idea issues as Markdown drafts; no API calls).

##### 4.6 Docs: `docs/`

Every doc should be short and practical, with one Mermaid diagram where a flow exists, and should link back to the README.

| File | Content |
| --- | --- |
| `principles.md` | 15 principles in two groups. Workflow: git is the source of truth, platform-agnostic, agents propose humans decide, small batches, read-only first, security enforced not requested, capture fast decide later, everything as code. Agent rules from CS329A: verify before you ask, a written constitution, spend compute where it pays, curated memory, measure don't guess, verifiers are protected, every cycle teaches. One or two sentences each. |
| `lifecycle.md` | 7 stages: Capture, Plan, Breakdown, Build, Review, Release, Learn. Inputs, outputs, gate, who does it. A Mermaid flow including the verify loop inside Build, rework from Review, failure signals into the inbox, and Learn feeding Plan. |
| `inboxes.md` | Private capture (`company-kb/_local/inbox/`) vs team signals (`docs/learnings/inbox/`). A table of signal, inbox, who writes it, when to create an entry, and when it is processed. Thresholds: verify loop hit 5, the same check failed in 2+ MR/PRs, a human had to step in, or the fix took over 30 minutes. Review findings a rule could have caught, any `sec/*` finding, or the same comment twice. Incidents always. "Not every red build is a signal." The promotion ladder: CI rule > `CLAUDE.md` > ADR > knowledge repo pattern > learnings log. |
| `models-and-effort.md` | Day-1 defaults: Sonnet high for everything, Opus for plans, threat models and security review. The full table of stage, task, model, effort, best-of-N and escalation. The effort ladder (low, medium, high, xhigh, max; max only after xhigh fails). How to set the model and effort in Claude Code, with links to the official docs. State that model names change, and keep model names in one place. |
| `security-gates.md` | Gates by phase (day 1: gitleaks; after the pilot: Semgrep and Trivy warn-only, then blocking; later: SBOM, signing, eval gate), agent guardrails, the verifier guard, and untrusted input (issues, comments, forks). |
| `knowledge-repo.md` | The company knowledge repo pattern: one `company-kb` repo, staff clone, externals fork, branch `kb/<name>/<topic>`, MR/PR, CODEOWNERS per folder; agents read `main` only. Obsidian setup: two vaults (the `company-kb` clone and the project's `docs/`), obsidian-git with pull on open, core Templates, wikilinks off. Where Obsidian helps per stage and where it does not (no tasks or boards). Running Claude Code inside a vault. A Mermaid flow. |
| `platform-mapping.md` | GitLab vs GitHub vs Gitea for each need (change request, CI, epics, labels, templates, code owners, protected main, web editor, Markdown view), with an "agnostic choice" column. Add a note to check each platform's current docs. |
| `glossary.md` | Includes the three meanings of "vault": an Obsidian vault (notes folder), Passbolt (human passwords; Community Edition is free and self-hosted), and OpenBao or HashiCorp Vault (machine secrets). Never put secrets in notes. |
| `labels.md` | Label set and meaning. |
| `adr/` | MADR-style ADRs: `0001-record-architecture-decisions.md`, `0002-platform-agnostic-make-check.md`, `0003-verify-loop-and-self-critique.md`, `0004-learnings-inbox.md`, `0005-local-obsidian-knowledge-repo.md`. Status: accepted. Short. |
| `learnings/README.md` | How the inbox and retros work for this repo. |
| `learnings/inbox/_template.md` | Frontmatter: type (build-failure, review-finding or incident), date, ref, story, check, tags. Body: what failed, root cause, fix, "could a rule catch this earlier?". |
| `learnings/inbox/.gitkeep` | Keeps the folder. |

##### 4.7 Examples: `examples/`

- `examples/company-kb/`: the skeleton of a knowledge repo for adopters to copy.
  - `README.md`, `00-start-here.md`, `runbooks/`, `howto/`, `patterns/`, `architecture/`, `glossary/`, `templates/` (one note template with owner and review-by frontmatter)
  - `.gitignore` with `_local/`, `CODEOWNERS`, a short `CLAUDE.md` for agents working in a vault
  - Document recommended Obsidian settings in the README. Do not commit `.obsidian/` JSON unless you verified the format.
- `examples/learnings-entry.md`: one realistic filled-in inbox entry.
- `evals/README.md`: what an agent eval case is (task, expected outcome, grader), why it matters (CS329A: measure, don't guess), and the "later" status. Include one example case file. No runner yet.

#### 5. Quality bar (your self-critique checklist)

- [ ] `make check` passes from a fresh clone with the documented tools installed.
- [ ] No secrets, tokens, real hostnames, real company names or personal data anywhere.
- [ ] No em dash characters anywhere.
- [ ] Every doc is reachable from the README in two clicks or fewer, and no internal links are broken.
- [ ] GitHub and GitLab templates are identical in content.
- [ ] Verifier files are listed in `CODEOWNERS`.
- [ ] Every Claude Code config file cites the doc page its format came from, or carries `TODO(verify):`.
- [ ] Plain language: a new engineer understands the README in 5 minutes.
- [ ] Nothing requires a paid platform tier.
- [ ] Each commit is one phase, with a Conventional Commit message.

#### 6. Phases (after plan approval)

| Phase | Scope | Done when |
| --- | --- | --- |
| 1. Skeleton and governance | `git init -b main`, README skeleton, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, CODEOWNERS, `.gitignore`, `.editorconfig`, first `CLAUDE.md` | Files exist, committed |
| 2. Verifiers | Makefile, `make check`, `make doctor`, scripts, lint and gitleaks configs, tool pins | `make check` green locally |
| 3. CI and templates | Both CI wrappers, issue and MR/PR templates for both platforms, template-sync check, `docs/labels.md` | `make check` green, YAML valid |
| 4. Docs and ADRs | Everything in 4.6 | Links valid, diagrams render as Mermaid |
| 5. Claude Code config | Everything in 4.5, formats verified against the docs | Config files cite sources |
| 6. Examples and evals | Everything in 4.7 | `make check` green |
| 7. Self-review and release prep | Full self-critique against section 5, final README polish, the first real learnings entry about this bootstrap if anything caused friction, CHANGELOG entry for `0.1.0`, local tag `v0.1.0` (no push) | Checklist all ticked, final report |

#### 7. What your plan must contain

1. Your understanding of the goal in 3 to 5 sentences.
2. The full file tree you intend to create.
3. Tool choices with versions and why (gitleaks, markdownlint-cli2, lychee or alternative, yamllint, shellcheck), and how CI installs them.
4. Any deviation from this brief, and why.
5. Risks and unknowns, including anything you need to verify in the docs.
6. Your questions for me (5 at most).
7. A time and size estimate per phase.

Then stop and wait for my approval.

---

## 10. What "SDLC" means

- **SDLC = Software Development Life Cycle.** It's the full path software takes: plan, design, build, test, release, operate, improve.
- **The name `agentic-sdlc-template` reads as:**
  - agentic: AI agents do real work, humans approve.
  - sdlc: the whole cycle, not just coding (Capture, Plan, Breakdown, Build, Review, Release, Learn).
  - template: people copy it to start their own projects.
- **Why it fits:** "SDLC" is the term security and compliance people use (secure SDLC, SSDLC, NIST SSDF), so it signals the DevSecOps angle.
- **Downside:** SDLC is jargon. Explain it in the README's first line, for example: "A template for running the software development life cycle (SDLC) with AI agents, where agents propose and humans decide."

---

## 11. GitHub "Create a new repository" form

| Field | Value |
| --- | --- |
| Template | No template |
| Owner | Your user (or an org later) |
| Repository name | `agentic-sdlc-template` |
| Description | see below |
| Visibility | Public |
| Add README | Off |
| Add .gitignore | None |
| Add license | None |

Leave README, .gitignore and license off. Claude Code creates them locally, and GitHub-created copies would conflict with the first push.

**Description options:**

1. `A platform-agnostic template for running the software development life cycle (SDLC) with AI agents: agents propose, humans decide, every cycle teaches.` (recommended)
2. `DevSecOps template for agent-assisted delivery on GitLab, GitHub and Gitea. Verify loops, learnings inbox, security gates, Claude Code ready.`
3. `Run your SDLC with AI coding agents without losing traceability or security. Git-first, platform-agnostic, works with Claude Code.`

**After creating it:**

1. **Topics:** `sdlc`, `devsecops`, `ai-agents`, `agentic-ai`, `claude-code`, `template`, `gitlab`, `github-actions`, `gitea`, `obsidian`, `security`, `developer-workflow`
2. **Settings > General:** tick Template repository.
3. **Settings > Rules (rulesets):** protect `main`. Require a PR, require the `check` status (after the first CI run), block force pushes.
4. **Settings > Security:** private vulnerability reporting, Dependabot alerts, secret scanning, push protection.
5. **Push it yourself.** The prompt tells Claude Code never to push. Push after phase 3 so CI runs early:

```bash
git remote add origin git@github.com:<your-user>/agentic-sdlc-template.git
git push -u origin main --tags
```

---

## 12. Exporting the raw chat from Claude

This file is a curated export. For the raw transcript of all your chats:

1. Use Settings > Privacy > **Export data** on the Claude web app or Claude Desktop. It doesn't work from iOS or Android.
2. Download from the link Claude sends. You must be signed in, the link expires after 24 hours, and you can request a new one if it does.
3. The export covers all your chats, not just this one, and doesn't include files you uploaded.
4. On a Team or Enterprise plan, an owner has to allow member exports first.

Source: https://support.claude.com/en/articles/9450526
