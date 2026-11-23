#!/usr/bin/env bash
# CI only: run the verifier guard as it exists on the BASE branch, against this checkout.
#
# Why: make check runs this change's own copy of verifier-guard.sh, so a change to the
# guard judges itself. Here the guard comes from the base ref (git archive), so a change
# cannot weaken the rule that judges it. The platform wrappers call this after make check.
#
# Usage: scripts/ci-base-guard.sh [BASE_REF]
#   BASE_REF defaults to origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME (GitLab) or
#   origin/$GITHUB_BASE_REF (GitHub and Gitea). With neither set this is not a MR/PR
#   pipeline: the script says so and exits 0.
#
# Never silent: when the base has no usable guard (the base predates the guard, or its
# lib.sh has no REPO_ROOT override yet) the script prints a warning and skips. Once the
# base branch carries both, a skip is no longer possible and the base guard decides.
#
# Limits: the wrapper file (workflow or .gitlab-ci.yml) and this script come from the
# change. The control outside the repo (protected main, owner approval of every verifier
# path in CODEOWNERS) still has the last word. See scripts/verifier-guard.sh.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

base="${1:-}"
if [ -z "$base" ]; then
  if [ -n "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME:-}" ]; then
    base="origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"
  elif [ -n "${GITHUB_BASE_REF:-}" ]; then
    base="origin/$GITHUB_BASE_REF"
  else
    info "base guard: not a MR/PR pipeline (no target branch variable set), nothing to compare. Skipped."
    exit 0
  fi
fi

git rev-parse --verify --quiet "$base^{commit}" >/dev/null ||
  die "base guard: base ref '$base' is not a known commit. Fetch it with full history (CI: fetch-depth 0 / GIT_DEPTH 0)."

if ! git cat-file -e "$base:scripts/verifier-guard.sh" 2>/dev/null ||
  ! git cat-file -e "$base:scripts/lib.sh" 2>/dev/null; then
  warn "base guard SKIPPED: $base has no scripts/verifier-guard.sh or scripts/lib.sh, so there is no base copy to run. This is expected only until the base branch carries the guard."
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git archive "$base" scripts | tar -x -C "$tmp"

# The base copy must honour REPO_ROOT, or it would look for the repo inside $tmp.
probe="$(REPO_ROOT="$REPO_ROOT" bash -c '. "$1/scripts/lib.sh" >/dev/null 2>&1 && printf %s "$REPO_ROOT"' _ "$tmp" 2>/dev/null || true)"
if [ "$probe" != "$REPO_ROOT" ]; then
  warn "base guard SKIPPED: the scripts/lib.sh of $base has no REPO_ROOT override yet, so its guard cannot run against this checkout. This is expected only until the base branch carries it."
  exit 0
fi

info "base guard: running scripts/verifier-guard.sh from $base against this checkout"
# CI is unset on purpose: with CI set the guard ignores GUARD_BASE. The base was validated above
# and comes from the platform variables or from the caller, never from the change's content.
# Not exec: the EXIT trap must still remove $tmp.
rc=0
env -u CI REPO_ROOT="$REPO_ROOT" GUARD_BASE="$base" "$tmp/scripts/verifier-guard.sh" || rc=$?
exit "$rc"
