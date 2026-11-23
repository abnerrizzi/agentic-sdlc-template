# Security policy

Back to the [README](README.md).

## Report a vulnerability privately

Do not open a public issue for a security problem.

- **GitHub:** use "Report a vulnerability" on the Security tab (private vulnerability reporting).
- **GitLab:** open an issue and tick "This issue is confidential".
- **Gitea or anything else:** contact the maintainer listed as `@OWNER` in [CODEOWNERS](CODEOWNERS) directly.

Include what you found, how to reproduce it, the affected file or version, and the impact you expect.

## What to expect

| Step | Target |
| --- | --- |
| Acknowledge your report | 5 working days |
| First assessment | 10 working days |
| Fix or mitigation for confirmed issues | Agreed with you, based on severity |

We credit reporters in the CHANGELOG unless you ask us not to.

## Supported versions

| Version | Supported |
| --- | --- |
| Latest `0.x` release | Yes |
| Older releases | No, please upgrade |

## Scope

In scope:

- Scripts, the `Makefile` and CI files in this repo.
- Claude Code configuration under `.claude/`, for example a permission rule that does not block what it claims to block.
- Guidance in the docs that would lead an adopter to an insecure setup.

Out of scope:

- Vulnerabilities in third-party tools we pin (gitleaks, lychee and others). Report those upstream.
- Projects created from this template. Their owners handle their own reports.
