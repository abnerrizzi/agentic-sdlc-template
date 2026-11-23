# Labels

Back to the [README](../README.md).

One small label set, the same on GitHub, GitLab and Gitea. The issue templates in `.github/ISSUE_TEMPLATE/` and `.gitlab/issue_templates/` apply `type/*` and `status/triage` for you. Colours are suggestions.

## type/

What kind of work the issue is. Exactly one per issue.

| Label | Meaning | Colour |
| --- | --- | --- |
| `type/idea` | A rough idea, not yet planned | `#c5def5` |
| `type/epic` | A larger goal that splits into stories | `#5319e7` |
| `type/story` | A user story with acceptance criteria | `#0e8a16` |
| `type/bug` | Something is broken | `#d73a4a` |
| `type/incident` | An outage or security event | `#b60205` |
| `type/chore` | Maintenance, tooling, dependency bumps | `#cfd3d7` |
| `type/docs` | Documentation only | `#0075ca` |

## status/

Where the issue is in the flow. Exactly one at a time.

| Label | Meaning | Colour |
| --- | --- | --- |
| `status/triage` | New, not yet looked at by a human | `#fbca04` |
| `status/ready` | Clear enough to start | `#c2e0c6` |
| `status/in-progress` | Someone is working on it | `#1d76db` |
| `status/blocked` | Waiting on something, say what in a comment | `#e99695` |
| `status/review` | MR/PR open, waiting for a human review | `#bfdadc` |
| `status/done` | Merged and verified | `#0e8a16` |

## prio/

How urgent it is.

| Label | Meaning | Colour |
| --- | --- | --- |
| `prio/p0` | Drop everything: outage, data loss or active security problem | `#b60205` |
| `prio/p1` | Do next: major feature broken, no workaround | `#d93f0b` |
| `prio/p2` | Normal: plan it into the next batch | `#fbca04` |
| `prio/p3` | Low: do when there is time | `#c2e0c6` |

## sec/

Security flags.

| Label | Meaning | Colour |
| --- | --- | --- |
| `sec/review-needed` | A security-minded reviewer must look before merge | `#d93f0b` |
| `sec/vuln` | A vulnerability, in our code or a dependency. Report privately first, see [SECURITY.md](../SECURITY.md) | `#b60205` |
| `sec/secrets` | A secret may have leaked. Rotate it first, then clean up | `#b60205` |

## agent/

For MR/PRs written with a coding agent.

| Label | Meaning | Colour |
| --- | --- | --- |
| `agent/authored` | An agent wrote most of the change | `#7057ff` |
| `agent/hard` | The verify loop hit 5, or a human had to step in. Add a learnings inbox entry | `#e4e669` |

## Creating the labels

Do it once per project. This repo makes no API calls for you.

### By hand

- GitHub: repository, Issues, Labels, New label.
- GitLab: project, Manage, Labels, New label. Names with a slash become scoped labels on tiers that support them; on Free they are plain labels and still work.
- Gitea: repository, Issues, Labels, New Label.

### With a CLI (optional)

Run one line per label. These are examples, not run by this repo.

```text
gh label create "type/bug" --color d73a4a --description "Something is broken"
glab label create --name "type/bug" --color "#d73a4a" --description "Something is broken"
tea labels create --name "type/bug" --color d73a4a --description "Something is broken"
```

TODO(verify): check the flags against `gh label create --help`, `glab label create --help` and `tea labels create --help` for your installed versions.
