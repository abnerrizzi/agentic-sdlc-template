#!/usr/bin/env bash
# Verifier guard: a single change must not touch both verifier paths and
# non-verifier paths. Otherwise a change could weaken a check and slip past it
# in the same MR/PR. Verifier paths are read from CODEOWNERS, between the
# "BEGIN verifier paths" and "END verifier paths" markers.
#
# The change is everything on this branch since its merge base with the base
# branch, plus uncommitted and untracked files.
#
# Base branch, first match wins:
#   GUARD_BASE (for example origin/main, or a parent branch when stacking)
#   origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME (GitLab MR pipelines)
#   origin/$GITHUB_BASE_REF (GitHub and Gitea pull request runs)
#   origin/main, then main
#
# Override, for the human owner only (agents must never use it): add this
# trailer to a commit on the branch, with a reason reviewers can judge:
#   Verifier-Guard-Override: <reason>
# The trailer stays in git history, so every override is auditable.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

pick_base() {
  local candidate
  for candidate in \
    "${GUARD_BASE:-}" \
    "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME:+origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}}" \
    "${GITHUB_BASE_REF:+origin/${GITHUB_BASE_REF}}" \
    origin/main main; do
    [ -z "$candidate" ] && continue
    if git rev-parse --verify --quiet "$candidate^{commit}" >/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
    [ "$candidate" = "${GUARD_BASE:-}" ] && die "GUARD_BASE=$candidate is not a known commit"
  done
  die "no base branch found. Fetch the base branch with full history (CI: fetch-depth 0 / GIT_DEPTH 0) or set GUARD_BASE."
}

mapfile -t patterns < <(
  awk '/BEGIN verifier paths/ { on = 1; next } /END verifier paths/ { on = 0 } on && $1 !~ /^#/ && NF { print $1 }' CODEOWNERS
)
[ "${#patterns[@]}" -gt 0 ] || die "no verifier paths found between the markers in CODEOWNERS"

is_verifier() {
  local path="$1" pat
  for pat in "${patterns[@]}"; do
    pat="${pat#/}"
    case "$pat" in
      */) [[ "$path" == "$pat"* ]] && return 0 ;;
      *) # shellcheck disable=SC2053 # the pattern is meant to glob
         [[ "$path" == $pat ]] && return 0 ;;
    esac
  done
  return 1
}

base="$(pick_base)"
merge_base="$(git merge-base "$base" HEAD)" || die "no merge base between $base and HEAD (shallow clone?)"

mapfile -t changed < <(
  { git diff --name-only --no-renames "$merge_base"; git ls-files --others --exclude-standard; } | sort -u
)

verifier=()
content=()
for f in "${changed[@]}"; do
  [ -z "$f" ] && continue
  if is_verifier "$f"; then verifier+=("$f"); else content+=("$f"); fi
done

if [ "${#verifier[@]}" -gt 0 ] && [ "${#content[@]}" -gt 0 ]; then
  overrides="$(git log --format='%(trailers:key=Verifier-Guard-Override,valueonly)' "$merge_base..HEAD" | sed '/^$/d')"
  if [ -n "$overrides" ]; then
    warn "verifier guard overridden by commit trailer: $overrides"
    warn "reviewers: confirm a human owner wrote this override"
    exit 0
  fi
  fail "this change touches verifier paths and other paths together (base: $base)."
  info "Verifiers must change in their own MR/PR, so a change cannot weaken the check that judges it."
  info "Verifier paths changed:"
  printf '  %s\n' "${verifier[@]}"
  info "Other paths changed:"
  printf '  %s\n' "${content[@]}"
  info "Split the change into two MR/PRs. See CONTRIBUTING.md."
  exit 1
fi

ok "verifier guard: ${#changed[@]} changed files, ${#verifier[@]} verifier, ${#content[@]} other (base: $base)"
