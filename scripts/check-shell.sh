#!/usr/bin/env bash
# Shell lint with shellcheck for every script in the repo.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
need shellcheck

sh=()
repo_files sh '*.sh'
[ "${#sh[@]}" -eq 0 ] && { ok "shell: no files"; exit 0; }
shellcheck --external-sources --source-path=SCRIPTDIR -- "${sh[@]}"
ok "shell: ${#sh[@]} scripts clean"
