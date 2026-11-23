#!/usr/bin/env bash
# Fail if the GitHub and GitLab issue and MR/PR templates have drifted.
# Both platforms must offer the same content in different folders. Before
# comparing, platform-only lines are removed:
# - GitHub: the leading YAML front matter block (name, about, labels).
# - GitLab: quick action lines such as /label ~"type/bug".
#
# The pairs come from the folder listings, not from a fixed list:
# - Each .github/ISSUE_TEMPLATE/*.md pairs with the .gitlab/issue_templates/*.md
#   of the same name, ignoring case (bug.md and Bug.md). Other files, such as
#   GitHub's config.yml, are ignored.
# - .github/pull_request_template.md pairs with
#   .gitlab/merge_request_templates/Default.md.
# - A .md file without a twin fails. So does a template folder with no pair.
# - With no template folders at all, the check passes ("no templates yet").
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

GH_ISSUES=".github/ISSUE_TEMPLATE"
GL_ISSUES=".gitlab/issue_templates"
GH_PR=".github/pull_request_template.md"
GL_PR=".gitlab/merge_request_templates/Default.md"

strip_blank_edges() {
  awk 'NF { found = 1 } found' | awk '{ lines[NR] = $0 } NF { last = NR } END { for (i = 1; i <= last; i++) print lines[i] }'
}
normalise_github() {
  awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' "$1" | strip_blank_edges
}
normalise_gitlab() {
  grep -vE '^/[a-z_]+( .*)?$' "$1" | strip_blank_edges
}

if [ ! -d "$GH_ISSUES" ] && [ ! -d "$GL_ISSUES" ] && [ ! -d ".gitlab/merge_request_templates" ] &&
  [ ! -e "$GH_PR" ] && [ ! -e "$GL_PR" ]; then
  ok "template sync: no templates yet"
  exit 0
fi

status=0
checked=0

# compare GITHUB_FILE GITLAB_FILE: count the pair and diff the normalised content.
compare() {
  checked=$((checked + 1))
  if ! diff -u --label "$1" --label "$2" <(normalise_github "$1") <(normalise_gitlab "$2"); then
    fail "templates drifted: $1 and $2 must have the same content (diff above)"
    status=1
  fi
}

# Issue templates, matched by lower-cased file name.
declare -A gh_files=() gl_files=()
shopt -s nullglob
for f in "$GH_ISSUES"/*.md; do
  key="$(basename "$f")"
  key="${key,,}"
  if [ -n "${gh_files[$key]:-}" ]; then
    fail "two GitHub templates differ only by case: ${gh_files[$key]} and $f"
    status=1
  fi
  gh_files[$key]="$f"
done
for f in "$GL_ISSUES"/*.md; do
  key="$(basename "$f")"
  key="${key,,}"
  if [ -n "${gl_files[$key]:-}" ]; then
    fail "two GitLab templates differ only by case: ${gl_files[$key]} and $f"
    status=1
  fi
  gl_files[$key]="$f"
done
shopt -u nullglob

for key in "${!gh_files[@]}"; do
  if [ -z "${gl_files[$key]:-}" ]; then
    fail "template exists on GitHub only: ${gh_files[$key]} has no twin in $GL_ISSUES/"
    status=1
    continue
  fi
  compare "${gh_files[$key]}" "${gl_files[$key]}"
done
for key in "${!gl_files[@]}"; do
  if [ -z "${gh_files[$key]:-}" ]; then
    fail "template exists on GitLab only: ${gl_files[$key]} has no twin in $GH_ISSUES/"
    status=1
  fi
done

# The MR/PR template is one fixed pair.
if [ -f "$GH_PR" ] && [ -f "$GL_PR" ]; then
  compare "$GH_PR" "$GL_PR"
elif [ -f "$GH_PR" ]; then
  fail "template exists on GitHub only: $GH_PR has no twin $GL_PR"
  status=1
elif [ -f "$GL_PR" ]; then
  fail "template exists on GitLab only: $GL_PR has no twin $GH_PR"
  status=1
fi

if [ "$checked" -eq 0 ]; then
  fail "template folders exist but no pair was compared"
  status=1
fi

[ "$status" -eq 0 ] && ok "template sync: $checked pairs identical"
exit "$status"
