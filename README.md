# agentic-sdlc-template

A template for running a DevSecOps software lifecycle with AI coding agents, on GitLab, GitHub or Gitea.

- Agents propose, humans decide.
- Git is the source of truth.
- Agents verify their own work.
- Every cycle teaches.

> Status: under construction (pre-0.1.0). This README is a skeleton; sections marked "coming" land in later phases.

## The 30-second pitch

Coding agents are fast, but speed without traceability is a liability. This template gives you a small, boring setup where agents plan, build and review, while humans approve every merge. Every plan, decision, failure and lesson ends up as reviewable text in git. All checks live in one `make check`, so the result is the same on your laptop, in the agent's loop and in CI, whatever platform you use.

## Who it is for

SREs, platform engineers and small teams who want agent-assisted delivery without losing traceability or security. You should know git and CI. You do not need to know the research behind it.

## Quick start

Coming in a later phase: copy the template, replace `@OWNER`, install the tools, run `make check`, open your first issue.

## Lifecycle

Coming in a later phase: Capture, Plan, Breakdown, Build, Review, Release, Learn.

## Repo map

| Path | What it is |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | The constitution for agents working in this repo |
| [CONTRIBUTING.md](CONTRIBUTING.md) | The workflow: issue, branch, commit, check, MR/PR, review |
| [SECURITY.md](SECURITY.md) | How to report a vulnerability privately |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Contributor Covenant, adopted by reference |
| [CHANGELOG.md](CHANGELOG.md) | Notable changes |
| [CODEOWNERS](CODEOWNERS) | Who must approve what, including verifier paths |
| [docs/labels.md](docs/labels.md) | The label set and what each label means |
| `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md` | GitHub issue and PR templates |
| `.gitlab/issue_templates/`, `.gitlab/merge_request_templates/` | GitLab issue and MR templates, same content as GitHub |
| [docs/bootstrap/kickoff-brief.md](docs/bootstrap/kickoff-brief.md) | The brief this repo was bootstrapped from |

## Works with

GitLab, GitHub, Gitea and Claude Code. No paid platform tier is required.

## License

[Apache-2.0](LICENSE).
