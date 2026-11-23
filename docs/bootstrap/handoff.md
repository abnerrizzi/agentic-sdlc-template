# Bootstrap handoff

Context for whoever continues the bootstrap, human or agent, on another host. Read this, then the [kickoff brief](kickoff-brief.md). This branch is a note, not a phase: do not merge it.

## State on 2026-11-23

| Branch | Base | State |
| --- | --- | --- |
| `bootstrap/01-skeleton` | `main` | Phase 1 done. Not merged into `main` yet. |
| `bootstrap/02-verifiers` | `bootstrap/01-skeleton` | Phase 2 mostly done. Not green yet (see below). |
| `bootstrap/handoff` | `bootstrap/02-verifiers` | This file only. |

Nothing has been pushed. Push these branches from the old host, or copy the repo, before you continue.

Because Phase 1 is not merged, the branches are stacked. Run the guard with `GUARD_BASE=bootstrap/01-skeleton` on the Phase 2 branch until Phase 1 is in `main`.

## Phase 2: what is left

1. Generate `package-lock.json` with Node 24, resolving only versions at least 14 days old, then commit it on `bootstrap/02-verifiers`:

   ```sh
   npm install --package-lock-only --ignore-scripts --before=2026-11-09
   ```

2. Run `make check-docker` (or `scripts/install-tools.sh` then `make check`, on a host with glibc 2.28+ and Python 3.10+). On the Phase 2 branch, set `GUARD_BASE=bootstrap/01-skeleton`.
3. markdownlint and yamllint have never run. Fix what they report in the content, never in the config, unless a rule is wrong (then stop and ask). Markdown fixes go on the Phase 1 branch, not on the verifier branch.
4. Write the Phase 2 report and wait for "go".

Already verified with the real gitleaks, lychee and shellcheck binaries: secrets, text, links, shell, template sync and verifier guard pass. Negative tests (fake kubeconfig key, em dash, wikilink, broken link and anchor, template drift, template on one side only, mixed verifier change, override trailer) all fail as expected.

## Why it stopped on the first host

The first host had glibc 2.17 and Python 3.6, so Node 24 and yamllint could not run. Its Docker daemon could not reach Docker Hub (no daemon proxy, and the registry mirror needs a login). Downloading a portable Node and Python was refused by the agent's permission check.

## Friction to log as learnings (on the Phase 4 content branch)

The guard blocks content files on a verifier branch, so these wait for Phase 4 as `docs/learnings/inbox/` entries:

- lychee 0.24 changed `include_fragments` from a boolean to a mode string. The old form failed to parse.
- shellcheck read a comment starting with "shellcheck," in `tools.versions` as a directive (SC1073).
- `make doctor` reported an old Python as ok because "at least" versions were not compared. Fixed.
- The scripts directory chmod made `lib.sh` executable by accident. It is sourced, so it stays 0644.
- The wikilink check flagged a quoted Obsidian setting name written with double brackets. Write it as "Use Wikilinks" in docs.
- An old build host (glibc 2.17, Docker without registry access) blocked Markdown and YAML lint.

## Working agreements from the session

- Commit after each logical step, Conventional Commits, no AI attribution trailers.
- Stop after each phase with a short report and wait for "go".
- One branch per phase: `bootstrap/NN-<name>`.
- Repo content names Claude Code because it is the subject. Commits and MR/PRs carry no AI attribution.
- Skill names: `/sdlc-plan`, `/sdlc-breakdown`, `/sdlc-review`, `/sdlc-retro`, `/sdlc-capture` (built-in `/plan` and `/review` clash).
- `scripts/install-tools.sh` is the only script with network calls.
- Never commit internal hostnames, mirrors or proxies. `IMAGE_MIRROR` and proxy settings are passed on the command line only.

## Tool pins (all at least 14 days old on 2026-11-23)

gitleaks 8.30.1, lychee 0.24.2 (musl), shellcheck 0.11.0, Node 24.22.2, markdownlint-cli2 0.24.0, yamllint 1.38.0 with pathspec 1.1.1 and PyYAML 6.0.3, base image `python:3.13.17-slim-trixie` by digest. Details and checksums: `tools.versions`.

## The approved plan


### Context

The repo holds only a README and the kickoff brief (`agentic-sdlc-template-kickoff-prompt.md`). We build the full template in 7 phases, one branch and one commit per phase, and stop after each phase for a "go". Brief sections 4 to 6 are the spec. This file records the decisions made so far, the gaps found since the first plan, and how Obsidian is implemented.

### Decisions (confirmed)

| # | Decision |
| --- | --- |
| Q1 | Repo content names Claude Code, because it is the subject. No AI attribution trailers in commits or MR/PRs. "Agent disclosure" stays a template field for adopters. |
| Q2 | `make check-docker` builds `ci/Dockerfile` (digest-pinned base, same `install-tools.sh`) and runs `make check` inside it. This is how checks run on this OL7 host. Native `make check` works for anyone who has the tools. |
| Q3 | One branch per phase, `bootstrap/NN-<name>` off `main`. You merge each one into `main`; I start the next only after your "go". `develop` is ignored. No push, no remote changes. |
| Q4 | Skills are named `/sdlc-plan`, `/sdlc-breakdown`, `/sdlc-review`, `/sdlc-retro` and `/sdlc-capture` (built-in `/plan` and `/review` clash). |
| Q5 | `scripts/install-tools.sh` is the only script with network calls. It checks sha256 sums from `tools.versions` and is never called by `make check`. |
| - | Apache-2.0. `SECURITY.md` uses free private reporting (GitHub advisories, GitLab confidential issues) with `@OWNER` as contact. The kickoff brief moves to `docs/bootstrap/kickoff-brief.md`. The README is rewritten, keeping its 4 principle lines. |
| - | Tool pins (latest release at least 14 days old): gitleaks v8.30.1, markdownlint-cli2 0.24.0, lychee v0.24.2 (musl), yamllint 1.38.0, shellcheck v0.11.0. |

### Gaps found since the first plan (now in scope)

1. **`.gitattributes`** with `* text=auto eol=lf`, so shell scripts and the sync check don't break on Windows clones. (Phase 1)
2. **The verifier guard needs full history in CI.** Use `fetch-depth: 0` on GitHub and `GIT_DEPTH: 0` on GitLab. The guard runs only on MR/PR pipelines and is skipped on `main`. The base ref is configurable through `GUARD_BASE` (default `origin/main`, falling back to `main`). (Phases 2 and 3)
3. **Fork safety.** Use `pull_request` only, never `pull_request_target`. Set `permissions: contents: read` and `persist-credentials: false`. Document this in `security-gates.md`. (Phases 3 and 4)
4. **Container hygiene for `check-docker`.** Mount the repo read-only, run as your UID, set `git config safe.directory` inside the container, use the classic builder (Docker 19.03 has no buildx), and run with no network at check time (`--network none`). That last point proves "no network calls". (Phase 2)
5. **Enforce "agents never edit verifiers"** in `.claude/settings.json` with `Edit`/`Write` deny rules on the verifier paths, not only in the prompt. Side effect: from Phase 5 on, I can't edit verifiers in this repo. Phase 7 verifier fixes would be done by you or under an explicit temporary override, which I would log as a learning. (Phase 5)
6. **Gitignore `.claude/settings.local.json`, `.obsidian/`, `.trash/` and `_local/`.** (Phase 1)
7. **Adopter checklist.** A "After you copy this template" section in the README: replace `@OWNER`, reset `CHANGELOG`, clear the learnings inbox, turn on branch protection, tick "template repository" on GitHub, and optionally delete `examples/`. (Phase 7)
8. **Keeping pins current (optional, later).** Document Renovate with `minimumReleaseAge: "14 days"` as the path to keeping pins fresh. Renovate is free, self-hostable, and works on all 3 platforms. Doc only, no config in 0.1.0. (Phase 4)
9. **`examples/company-kb/` is linted by `make check`** like the rest, so the example stays valid. (Phase 6)

### Obsidian implementation

Obsidian is an optional, local, free editor over plain Markdown folders. The template ships **no plugin code and no Obsidian-only syntax**. It ships conventions plus checks that enforce them, so notes render the same on GitHub, GitLab, Gitea and in Obsidian.

### What the repo contains

| Piece | Where | Purpose |
| --- | --- | --- |
| Settings checklist | `docs/knowledge-repo.md` and `examples/company-kb/README.md` | Settings to apply by hand (below). |
| Note template | `examples/company-kb/templates/note.md` | Frontmatter: `title`, `owner`, `review-by`, `status`, `tags`. Body uses the core Templates placeholders `{{title}}` and `{{date}}`. |
| Folder skeleton | `examples/company-kb/{runbooks,howto,patterns,architecture,glossary}/` | Each folder has a README that says what belongs there. |
| Per-folder owners | `examples/company-kb/CODEOWNERS` | Changes need review from the folder owner. |
| Private capture | `_local/inbox/` (gitignored) | Fast, private notes; never committed. |
| Agent rules for a vault | `examples/company-kb/CLAUDE.md` | Read `main` only, work on `kb/<name>/<topic>` branches, never touch `.obsidian/`, never put secrets in notes. |
| Decision record | `docs/adr/0005-local-obsidian-knowledge-repo.md` | Why local Obsidian with git, and not Obsidian Sync, Publish or a wiki. |

### Settings to apply by hand (documented, not committed)

- **Files and links:**
  - the "Use Wikilinks" setting off.
  - "New link format" set to "Relative path to file".
  - "Automatically update internal links" on.
- **Core Templates plugin:** template folder is `templates`.
- **obsidian-git community plugin:**
  - Pull on startup.
  - Auto pull every 10 minutes.
  - **Auto push off. Never commit to `main`.** Work on a `kb/<name>/<topic>` branch and open an MR/PR. That keeps "humans decide" true for knowledge too.
- **Excluded files:** `_local/` is visible in the vault but gitignored.

We don't commit `.obsidian/` JSON. Its format is not officially documented, and personal UI state would cause churn. If you want shared settings later, a minimal `app.json` can be added behind `TODO(verify):`.

### Two vaults

1. **The `company-kb` clone (staff) or fork (externals):** team knowledge, changed through MR/PR.
2. **The project's `docs/` folder:** ADRs, learnings and lifecycle docs. Opening it as a vault creates `docs/.obsidian/`, which is gitignored.

### How the checks enforce the conventions

- lychee `--offline` fails on wikilinks and on broken relative links. A wrong Obsidian link setting shows up as a red build.
- markdownlint keeps notes valid CommonMark.
- gitleaks scans notes like code. Secrets belong in Passbolt (humans) or OpenBao/Vault (machines), as the glossary explains.

### How agents use the knowledge repo

- The planner reads a **read-only clone of `company-kb` at `main`**. Its path is set once (placeholder `../company-kb`) and granted through `permissions.additionalDirectories` in `.claude/settings.json` (TODO(verify) in Phase 5).
- `/sdlc-capture` reads `_local/inbox/*.md` and writes idea-issue drafts to `_local/issue-drafts/`, using the same body as the `idea` template. A human pastes them into the tracker. No API calls.
- Agents running inside a vault follow `examples/company-kb/CLAUDE.md`.

### Where Obsidian helps, and where it doesn't (goes into `knowledge-repo.md`)

| Stage | Obsidian helps | Use instead |
| --- | --- | --- |
| Capture | Quick notes in `_local/inbox/`, daily notes | - |
| Plan | Reading patterns and ADRs, backlinks, graph view | - |
| Breakdown, Build, Review | Little | Tracker issues, MR/PRs, CI |
| Release | No | Tags, CHANGELOG |
| Learn | Writing retro notes and promoted patterns | MR/PR for the promotion |
| Never | Tasks, boards, approvals, secrets | Platform tracker, MR/PR, Passbolt or OpenBao |

### Phases (unchanged from the brief, now with branches)

| Phase | Branch | Done when |
| --- | --- | --- |
| 1. Skeleton and governance | `bootstrap/01-skeleton` | Files committed |
| 2. Verifiers and `check-docker` | `bootstrap/02-verifiers` | `make check-docker` green |
| 3. CI and templates | `bootstrap/03-ci-templates` | Green, YAML valid, SHAs and digests at least 14 days old |
| 4. Docs and ADRs | `bootstrap/04-docs` | Links valid, Mermaid in place |
| 5. Claude Code config | `bootstrap/05-claude-config` | Every file cites its doc URL or has `TODO(verify):` |
| 6. Examples and evals | `bootstrap/06-examples` | Green |
| 7. Self-review and release prep | `bootstrap/07-release` | Checklist ticked, `v0.1.0` tag is local only |

Each phase ends with:

1. `make check-docker` (at most 5 fix loops).
2. Self-critique against `CLAUDE.md` and brief section 5.
3. A Conventional Commit with no AI trailers.
4. A phase report, then I stop until your "go".

### Verification

- **Every phase:** `make check-docker` exits 0, and `make doctor` lists the tools.
- **Phase 2 negative tests:** prove each check catches what it should, then revert:
  - plant a fake token (gitleaks fails);
  - add an em dash (the typography check fails);
  - break a link (lychee fails);
  - edit one GitLab template (the sync check fails);
  - touch `scripts/` and `docs/` on one branch (the guard fails).
- **Phase 3:** `yamllint` passes on the CI files. Every `uses:` is pinned to a 40-character SHA with a version comment.
- **Phase 7:** a fresh `git clone` into the scratchpad, then `make check-docker` is green, then `git tag -l v0.1.0`.
