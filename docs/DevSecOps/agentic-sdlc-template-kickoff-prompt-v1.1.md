# Kickoff: build `agentic-sdlc-template` from an empty folder

Version: 1.1 | Updated: 2026-11-27

| Version | Date | Change |
| --- | --- | --- |
| 1.0 | 2026-11-27 | First kickoff prompt |
| 1.1 | 2026-11-27 | Version header and changelog added |

You are starting a new public, open-source repository called `agentic-sdlc-template` in the current, empty folder. Read this whole brief before doing anything.

## 1. What we are building

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

## 2. How you will work (non-negotiable)

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

## 3. Decisions already made

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

## 4. Content specification

### 4.1 Top level

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

### 4.2 Verifiers: `Makefile` and `scripts/`

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

### 4.3 CI wrappers (thin)

- `.github/workflows/check.yml` and `.gitlab-ci.yml`. Gitea Actions reads the GitHub syntax; document this and any known differences.
- Each only installs pinned tools and runs `make check`.
- Supply-chain hygiene:
  - Pin GitHub Actions by full commit SHA, with the version in a comment.
  - Pin container images by digest where practical.
  - Use only releases that are at least 14 days old.
  - Least-privilege `permissions:` in GitHub Actions.
- No secrets required to run the checks.

### 4.4 Platform templates

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

### 4.5 Claude Code configuration: `.claude/`

Verify the current formats in the official Claude Code docs first.

- `settings.json`: a permissions deny list covering at least `terraform apply`, `kubectl delete`, any prod kube context, `rm -rf`, reading `.env*`, reading secret token files, and `git push`. Add an allow list for the read-only and check commands the workflow needs.
- Subagents, each with a model and effort set in frontmatter if the docs support it, and each with a clear, short system prompt:
  - `planner`: Opus, high. Reads the knowledge repo and ADRs first, outputs an epic and a draft ADR.
  - `breakdown`: Sonnet, medium. Epic to stories with acceptance criteria and security notes.
  - `reviewer`: Sonnet, high. Fresh-context review against `CLAUDE.md`, never edits verifiers.
  - `security-reviewer`: Opus, xhigh. For `sec/*` changes.
  - `retro`: Sonnet, medium. Groups `docs/learnings/inbox/` by tag, proposes promotions using the ladder, drafts the learnings file.
- Slash commands or skills (whichever the current docs recommend): `/plan`, `/breakdown`, `/review`, `/retro`, `/capture` (turns notes into idea issues as Markdown drafts; no API calls).

### 4.6 Docs: `docs/`

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

### 4.7 Examples: `examples/`

- `examples/company-kb/`: the skeleton of a knowledge repo for adopters to copy.
  - `README.md`, `00-start-here.md`, `runbooks/`, `howto/`, `patterns/`, `architecture/`, `glossary/`, `templates/` (one note template with owner and review-by frontmatter)
  - `.gitignore` with `_local/`, `CODEOWNERS`, a short `CLAUDE.md` for agents working in a vault
  - Document recommended Obsidian settings in the README. Do not commit `.obsidian/` JSON unless you verified the format.
- `examples/learnings-entry.md`: one realistic filled-in inbox entry.
- `evals/README.md`: what an agent eval case is (task, expected outcome, grader), why it matters (CS329A: measure, don't guess), and the "later" status. Include one example case file. No runner yet.

## 5. Quality bar (your self-critique checklist)

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

## 6. Phases (after plan approval)

| Phase | Scope | Done when |
| --- | --- | --- |
| 1. Skeleton and governance | `git init -b main`, README skeleton, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, CODEOWNERS, `.gitignore`, `.editorconfig`, first `CLAUDE.md` | Files exist, committed |
| 2. Verifiers | Makefile, `make check`, `make doctor`, scripts, lint and gitleaks configs, tool pins | `make check` green locally |
| 3. CI and templates | Both CI wrappers, issue and MR/PR templates for both platforms, template-sync check, `docs/labels.md` | `make check` green, YAML valid |
| 4. Docs and ADRs | Everything in 4.6 | Links valid, diagrams render as Mermaid |
| 5. Claude Code config | Everything in 4.5, formats verified against the docs | Config files cite sources |
| 6. Examples and evals | Everything in 4.7 | `make check` green |
| 7. Self-review and release prep | Full self-critique against section 5, final README polish, the first real learnings entry about this bootstrap if anything caused friction, CHANGELOG entry for `0.1.0`, local tag `v0.1.0` (no push) | Checklist all ticked, final report |

## 7. What your plan must contain

1. Your understanding of the goal in 3 to 5 sentences.
2. The full file tree you intend to create.
3. Tool choices with versions and why (gitleaks, markdownlint-cli2, lychee or alternative, yamllint, shellcheck), and how CI installs them.
4. Any deviation from this brief, and why.
5. Risks and unknowns, including anything you need to verify in the docs.
6. Your questions for me (5 at most).
7. A time and size estimate per phase.

Then stop and wait for my approval.
