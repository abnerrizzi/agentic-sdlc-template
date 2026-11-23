# Contributing

Back to the [README](README.md).

The workflow is the same for humans and agents: agents propose, humans decide.

## The flow

1. **Issue first.** Every change starts from an issue (idea, epic, story, bug or incident) on your platform's tracker.
2. **Branch** from `main`:

   | Kind | Branch name |
   | --- | --- |
   | Feature or story | `feat/<issue>-<short-name>` |
   | Bug | `fix/<issue>-<short-name>` |
   | Docs only | `docs/<issue>-<short-name>` |
   | Chores, tooling | `chore/<issue>-<short-name>` |

3. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), for example `feat: add incident template` or `fix(scripts): handle empty diff`. Keep commits small: one logical step each.
4. **Run `make check`** until it is green. It is the same check CI runs.
5. **Open an MR/PR** and fill in every section of the template, including test evidence and rollback steps.
6. **Review.** At least one human approves. Code owners must approve changes to verifier paths.
7. **Merge** to `main`. Squash or merge commits are both fine; keep the Conventional Commit title.

## Verifier changes are separate

Verifiers are the `Makefile`, `scripts/`, CI files, lint and secret-scan configs, tool pins and `.claude/settings.json` (see [CODEOWNERS](CODEOWNERS)). A change to a verifier goes in its own MR/PR, never mixed with content changes. The verifier guard in `make check` enforces this.

## Agent-authored MR/PRs

- Label them `agent/authored`. Add `agent/hard` when the agent hit its verify-loop limit or a human had to step in.
- Fill in the "Agent disclosure" section: model, effort, what was generated, and the human reviewer.
- The human who opens the MR/PR owns it and answers review comments.
- Review them like any other change. Pay extra attention to tests that were changed to pass, and to anything touching verifiers or permissions.

## Learnings

If something cost you time, such as a confusing failure or a check that missed a problem, add an entry to the learnings inbox. The retro decides whether it becomes a rule.

## Security

Never commit secrets. Report vulnerabilities privately, as described in [SECURITY.md](SECURITY.md). By contributing you agree to follow the [code of conduct](CODE_OF_CONDUCT.md).
