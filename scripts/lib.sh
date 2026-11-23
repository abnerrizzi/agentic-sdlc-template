#!/usr/bin/env bash
# Shared helpers for the verifier scripts. Source it, do not run it.
# Rules for every script in scripts/: bash, set -euo pipefail, shellcheck-clean,
# and no network calls (the only exception is install-tools.sh).

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

# Where install-tools.sh puts pinned tools. Outside the repo, so checks never scan them.
TOOLS_DIR="${TOOLS_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/agentic-sdlc-template/tools}"
export TOOLS_DIR

# Prefer pinned tools over whatever else is on PATH.
PATH="$TOOLS_DIR/bin:$TOOLS_DIR/node/bin:$TOOLS_DIR/npm/node_modules/.bin:$TOOLS_DIR/venv/bin:$PATH"
export PATH

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_OFF=$'\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_OFF=''
fi

info() { printf '%s\n' "$*"; }
ok()   { printf '%sok%s   %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '%swarn%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
fail() { printf '%sFAIL%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; }
die()  { fail "$*"; exit 1; }

# need TOOL: fail with a useful hint when a required tool is missing.
need() {
  command -v "$1" >/dev/null 2>&1 && return 0
  die "$1 not found. Run 'make doctor' for install hints, or use 'make check-docker'."
}

# repo_files [PATHSPEC...]: files git tracks or would track (not ignored), that exist.
# Using git keeps _local/, node_modules/ and other ignored paths out of every check.
repo_files() {
  git -C "$REPO_ROOT" ls-files --cached --others --exclude-standard -- "$@" |
    sort -u |
    while IFS= read -r f; do
      [ -f "$REPO_ROOT/$f" ] && printf '%s\n' "$f"
    done
  return 0
}

# load_versions: read tools.versions into the environment.
load_versions() {
  # shellcheck source=../tools.versions
  . "$REPO_ROOT/tools.versions"
}
