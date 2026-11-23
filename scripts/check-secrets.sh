#!/usr/bin/env bash
# Secret scan with gitleaks: the full git history, uncommitted changes, and new
# files git would track. Config and custom rules: .gitleaks.toml.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
need gitleaks

opts=(--config .gitleaks.toml --redact --no-banner --log-level warn --exit-code 1)

gitleaks git "${opts[@]}" . || die "secret found in git history. Rotate it first, then rewrite history."
gitleaks git "${opts[@]}" --staged . || die "secret found in staged changes"
gitleaks git "${opts[@]}" --pre-commit . || die "secret found in unstaged changes"

# Untracked files that are not ignored: git has never seen them.
while IFS= read -r f; do
  gitleaks stdin "${opts[@]}" < "$f" || die "secret found in untracked file: $f"
done < <(git ls-files --others --exclude-standard)

ok "secrets: gitleaks found nothing"
