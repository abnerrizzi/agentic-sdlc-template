#!/usr/bin/env bash
# Text rules no linter covers:
# 1. No em dash character anywhere (house style: use a hyphen or rewrite).
# 2. No wikilinks in Markdown. Relative Markdown links render on GitHub, GitLab,
#    Gitea and Obsidian; wikilinks only render in Obsidian.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

status=0
EM_DASH="$(printf '\342\200\224')"

mapfile -t files < <(repo_files)
if [ "${#files[@]}" -gt 0 ]; then
  if LC_ALL=C grep -nIF -- "$EM_DASH" "${files[@]}"; then
    fail "em dash found (lines above). Use a hyphen or rewrite the sentence."
    status=1
  fi
fi

mapfile -t md < <(repo_files '*.md')
if [ "${#md[@]}" -gt 0 ]; then
  if grep -nE '\[\[[^]]+\]\]' "${md[@]}"; then
    fail "wikilink found (lines above). Use a relative Markdown link: [text](path.md)."
    status=1
  fi
fi

[ "$status" -eq 0 ] && ok "text: no em dashes, no wikilinks"
exit "$status"
