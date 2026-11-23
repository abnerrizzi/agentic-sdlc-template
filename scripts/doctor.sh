#!/usr/bin/env bash
# List required tools, the pinned version, the detected version and an install
# hint. Installs nothing. Exit code: 0, or 1 with --strict when a required tool
# is missing or not at the pinned version.
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
load_versions

strict=0
[ "${1:-}" = "--strict" ] && strict=1

semver() { grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1; }

# version_at_least FOUND MIN: true when FOUND >= MIN (dotted numbers).
version_at_least() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n 1)" = "$2" ]; }

detect() {
  case "$1" in
    gitleaks)          gitleaks version 2>/dev/null | semver ;;
    lychee)            lychee --version 2>/dev/null | semver ;;
    shellcheck)        shellcheck --version 2>/dev/null | sed -n 's/^version: //p' ;;
    markdownlint-cli2) markdownlint-cli2 --help 2>/dev/null | head -n 1 | semver ;;
    yamllint)          yamllint --version 2>/dev/null | semver ;;
    node)              node --version 2>/dev/null | semver ;;
    python3)           python3 --version 2>&1 | semver ;;
    git)               git --version 2>/dev/null | semver ;;
    make)              make --version 2>/dev/null | head -n 1 | semver ;;
    docker)            docker --version 2>/dev/null | semver ;;
  esac
}

# tool | pinned version (or "any") | required? | install hint
ROWS=(
  "git|any|yes|your OS package manager"
  "make|any|yes|your OS package manager"
  "gitleaks|$GITLEAKS_VERSION|yes|scripts/install-tools.sh"
  "lychee|$LYCHEE_VERSION|yes|scripts/install-tools.sh"
  "shellcheck|$SHELLCHECK_VERSION|yes|scripts/install-tools.sh"
  "markdownlint-cli2|$MARKDOWNLINT_CLI2_VERSION|yes|scripts/install-tools.sh (needs node)"
  "yamllint|$YAMLLINT_VERSION|yes|scripts/install-tools.sh (needs python3 >= $PYTHON_MIN_VERSION)"
  "node|$NODE_VERSION|for install|scripts/install-tools.sh (needs glibc >= 2.28)"
  "python3|>= $PYTHON_MIN_VERSION|for install|your OS package manager"
  "docker|any|optional|only for make check-docker"
)

problems=0
printf '%-18s %-14s %-12s %-8s %s\n' TOOL PINNED FOUND STATUS HINT
for row in "${ROWS[@]}"; do
  IFS='|' read -r tool want required hint <<<"$row"
  found="$(detect "$tool" || true)"
  if [ -z "$found" ]; then
    status=MISSING
  elif [ "$want" = any ] || [ "$found" = "$want" ]; then
    status=ok
  elif [ "${want#>= }" != "$want" ] && version_at_least "$found" "${want#>= }"; then
    status=ok
  else
    status=DIFFERS
  fi
  if [ "$required" = yes ] && [ "$status" != ok ]; then
    problems=$((problems + 1))
  fi
  printf '%-18s %-14s %-12s %-8s %s\n' "$tool" "$want" "${found:--}" "$status" "$hint"
done

info ""
info "Tools directory: $TOOLS_DIR"
if [ "$problems" -gt 0 ]; then
  info "$problems required tool(s) missing or at a different version."
  info "Install the pins: scripts/install-tools.sh   (downloads, checks sha256, writes only to the tools directory)"
  info "Or run everything in the pinned container: make check-docker"
  [ "$strict" -eq 1 ] && exit 1
fi
exit 0
