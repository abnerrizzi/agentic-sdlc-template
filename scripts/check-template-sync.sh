#!/usr/bin/env bash
# Fail if the GitHub and GitLab issue and MR/PR templates have drifted.
# Both platforms must offer the same content in different folders. Before
# comparing, platform-only lines are removed:
# - GitHub: the leading YAML front matter block (name, about, labels).
# - GitLab: quick action lines such as /label ~"type/bug".
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

# GitHub path | GitLab path
PAIRS=(
  ".github/ISSUE_TEMPLATE/idea.md|.gitlab/issue_templates/Idea.md"
  ".github/ISSUE_TEMPLATE/epic.md|.gitlab/issue_templates/Epic.md"
  ".github/ISSUE_TEMPLATE/story.md|.gitlab/issue_templates/Story.md"
  ".github/ISSUE_TEMPLATE/bug.md|.gitlab/issue_templates/Bug.md"
  ".github/ISSUE_TEMPLATE/incident.md|.gitlab/issue_templates/Incident.md"
  ".github/pull_request_template.md|.gitlab/merge_request_templates/Default.md"
)

strip_blank_edges() {
  awk 'NF { found = 1 } found' | awk '{ lines[NR] = $0 } NF { last = NR } END { for (i = 1; i <= last; i++) print lines[i] }'
}
normalise_github() {
  awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' "$1" | strip_blank_edges
}
normalise_gitlab() {
  grep -vE '^/[a-z_]+( .*)?$' "$1" | strip_blank_edges
}

status=0
checked=0
for pair in "${PAIRS[@]}"; do
  gh="${pair%%|*}"
  gl="${pair##*|}"
  if [ ! -f "$gh" ] && [ ! -f "$gl" ]; then
    continue
  fi
  if [ ! -f "$gh" ] || [ ! -f "$gl" ]; then
    fail "template exists on one platform only: $gh vs $gl"
    status=1
    continue
  fi
  checked=$((checked + 1))
  if ! diff -u --label "$gh" --label "$gl" <(normalise_github "$gh") <(normalise_gitlab "$gl"); then
    fail "templates drifted: $gh and $gl must have the same content (diff above)"
    status=1
  fi
done

[ "$status" -eq 0 ] && ok "template sync: $checked pairs identical"
exit "$status"
