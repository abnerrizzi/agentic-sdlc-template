#!/usr/bin/env bash
# Verifier guard: a single change must not touch both verifier paths and
# non-verifier paths. Otherwise a change could weaken a check and slip past it
# in the same MR/PR. Verifier paths are read from CODEOWNERS, between the
# "BEGIN verifier paths" and "END verifier paths" markers.
#
# The change is everything on this branch since its merge base with the base
# branch, plus uncommitted and untracked files.
#
# Which patterns count: the UNION of the block in CODEOWNERS at the merge base
# and the block in the working tree. A change that deletes a line from the block
# therefore still guards that path, for this change. If the merge base has no
# CODEOWNERS or no markers (the very first change that adds them), the working
# tree block is used alone and a warning says so. If the working tree has no
# markers, the guard fails.
#
# Base branch, first match wins:
#   GUARD_BASE (for example a parent branch when stacking). Ignored, with a
#     warning, when CI is set: GUARD_BASE=HEAD would make the diff empty.
#   origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME (GitLab MR pipelines)
#   origin/$GITHUB_BASE_REF (GitHub and Gitea pull request runs)
#   origin/main, then main
#
# Override, for the human owner only (agents must never use it): add this
# trailer to a commit on the branch, with a reason reviewers can judge:
#   Verifier-Guard-Override: <reason>
# The trailer stays in git history. When it fires, the guard prints a loud
# warning per commit with the SHA, the author name and email, and the reason.
#
# Limits, read this before you trust the guard: checks that live in the repo
# cannot tell who wrote a commit. An author name, an email and a trailer are
# plain text that anyone can type, and a change can edit this very script. The
# real control is outside the repo: a protected main branch plus owner approval
# (CODEOWNERS) of every verifier path. CI must also run the guard from the base
# branch, not from the change's own copy, for example:
#   git show "$base:scripts/verifier-guard.sh" > "$RUNNER_TEMP/guard.sh"
# (the CI wiring comes in Phase 3).
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

if [ -n "${CI:-}" ] && [ -n "${GUARD_BASE:-}" ]; then
  warn "CI is set, so GUARD_BASE=$GUARD_BASE is ignored. Using the platform base branch or origin/main."
  GUARD_BASE=""
fi

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

# verifier_block: CODEOWNERS text on stdin, the verifier patterns on stdout.
verifier_block() {
  tr -d '\r' | awk '/BEGIN verifier paths/ { on = 1; next } /END verifier paths/ { on = 0 } on && $1 !~ /^#/ && NF { print $1 }'
}
# has_markers: CODEOWNERS text on stdin, true when both markers are there.
has_markers() {
  local text
  text="$(cat)"
  grep -q 'BEGIN verifier paths' <<<"$text" && grep -q 'END verifier paths' <<<"$text"
}

base="$(pick_base)"
merge_base="$(git merge-base "$base" HEAD)" || die "no merge base between $base and HEAD (shallow clone?)"

[ -f CODEOWNERS ] || die "CODEOWNERS not found"
has_markers <CODEOWNERS || die "CODEOWNERS has no verifier path markers (BEGIN/END)"
mapfile -t patterns < <(verifier_block <CODEOWNERS)
[ "${#patterns[@]}" -gt 0 ] || die "no verifier paths found between the markers in CODEOWNERS"

if base_owners="$(git show "$merge_base:CODEOWNERS" 2>/dev/null)" && has_markers <<<"$base_owners"; then
  mapfile -t base_patterns < <(verifier_block <<<"$base_owners")
  patterns+=("${base_patterns[@]}")
else
  warn "no verifier path block in CODEOWNERS at the merge base ${merge_base:0:12}: using the working tree block only"
fi

# is_verifier PATH: true when PATH matches a pattern. Forms, gitignore style:
#   /exact/file, /folder/   anchored at the repo root
#   name, *.ext             no leading / and no other /: matches the basename at any depth
is_verifier() {
  local path="$1" pat anchored
  for pat in "${patterns[@]}"; do
    anchored=0
    [[ "$pat" == /* ]] && anchored=1
    pat="${pat#/}"
    case "$pat" in
      */)
        if [ "$anchored" -eq 1 ] || [[ "${pat%/}" == */* ]]; then
          [[ "$path" == "$pat"* ]] && return 0
        else
          [[ "/$path" == *"/$pat"* ]] && return 0
        fi ;;
      *)
        if [ "$anchored" -eq 1 ] || [[ "$pat" == */* ]]; then
          # shellcheck disable=SC2053 # the pattern is meant to glob
          [[ "$path" == $pat ]] && return 0
        else
          # shellcheck disable=SC2053 # the pattern is meant to glob
          [[ "${path##*/}" == $pat ]] && return 0
        fi ;;
    esac
  done
  return 1
}

tracked_changes=()
new_files=()
git_z tracked_changes diff --name-only -z --no-renames "$merge_base"
git_z new_files ls-files -z --others --exclude-standard
changed=()
while IFS= read -r -d '' f; do
  if [ -n "$f" ]; then changed+=("$f"); fi
done < <(printf '%s\0' "${tracked_changes[@]}" "${new_files[@]}" | sort -z -u)

verifier=()
content=()
for f in "${changed[@]}"; do
  if is_verifier "$f"; then verifier+=("$f"); else content+=("$f"); fi
done

if [ "${#verifier[@]}" -gt 0 ] && [ "${#content[@]}" -gt 0 ]; then
  commits="$(git rev-list "$merge_base..HEAD")" || die "git rev-list failed"
  overridden=0
  while IFS= read -r sha; do
    [ -z "$sha" ] && continue
    reason="$(git log -1 --format='%(trailers:key=Verifier-Guard-Override,valueonly)' "$sha" | sed '/^$/d' | paste -sd ';' -)"
    [ -z "$reason" ] && continue
    overridden=1
    warn "!!! VERIFIER GUARD OVERRIDDEN by commit $sha"
    warn "!!!   author: $(git log -1 --format='%an <%ae>' "$sha")"
    warn "!!!   reason: $reason"
  done <<<"$commits"
  if [ "$overridden" -eq 1 ]; then
    warn "!!! Reviewers: a human owner must confirm each override above. The guard cannot tell who wrote the trailer."
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
