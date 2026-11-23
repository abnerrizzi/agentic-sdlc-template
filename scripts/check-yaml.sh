#!/usr/bin/env bash
# YAML lint with yamllint in strict mode (warnings fail). Rules: .yamllint.yaml.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
need yamllint

mapfile -t yml < <(repo_files '*.yml' '*.yaml')
[ "${#yml[@]}" -eq 0 ] && { ok "yaml: no files"; exit 0; }
yamllint --strict --config-file .yamllint.yaml -- "${yml[@]}"
ok "yaml: ${#yml[@]} files clean"
