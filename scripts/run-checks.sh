#!/usr/bin/env bash
# Run every verifier, keep going after a failure, print a summary, and exit
# non-zero if any check failed. Called by make check.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

# name:script [args]. tools runs first: a check run with the wrong tool version proves nothing.
CHECKS=(
  "tools:doctor.sh --strict"
  secrets:check-secrets.sh
  text:check-text.sh
  markdown:check-markdown.sh
  links:check-links.sh
  yaml:check-yaml.sh
  shell:check-shell.sh
  template-sync:check-template-sync.sh
  verifier-guard:verifier-guard.sh
)

failed=()
for entry in "${CHECKS[@]}"; do
  name="${entry%%:*}"
  read -r -a cmd <<<"${entry#*:}"
  info "== $name"
  if ! "$REPO_ROOT/scripts/${cmd[0]}" "${cmd[@]:1}"; then
    failed+=("$name")
  fi
done

info ""
if [ "${#failed[@]}" -gt 0 ]; then
  fail "make check: ${#failed[@]} of ${#CHECKS[@]} checks failed: ${failed[*]}"
  exit 1
fi
ok "make check: all ${#CHECKS[@]} checks passed"
