#!/usr/bin/env bash
# Markdown lint with markdownlint-cli2. Rules: .markdownlint-cli2.yaml.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
need markdownlint-cli2

mapfile -t md < <(repo_files '*.md')
[ "${#md[@]}" -eq 0 ] && { ok "markdown: no files"; exit 0; }
markdownlint-cli2 "${md[@]}"
ok "markdown: ${#md[@]} files clean"
