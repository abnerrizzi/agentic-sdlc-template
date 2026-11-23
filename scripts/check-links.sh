#!/usr/bin/env bash
# Internal link check with lychee in offline mode: relative links and #anchors
# between files in this repo. External URLs are skipped, so the check needs no
# network and gives the same result everywhere. Config: lychee.toml.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
need lychee

md=()
repo_files md '*.md'
[ "${#md[@]}" -eq 0 ] && { ok "links: no files"; exit 0; }
lychee --config lychee.toml -- "${md[@]}"
ok "links: internal links valid in ${#md[@]} files"
