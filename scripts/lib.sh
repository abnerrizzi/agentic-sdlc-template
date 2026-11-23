#!/usr/bin/env bash
# Shared helpers for the verifier scripts. Source it, do not run it.
# Rules for every script in scripts/: bash, set -euo pipefail, shellcheck-clean,
# and no network calls (the only exception is install-tools.sh).

# These scripts use mapfile -d, namerefs and other bash 4.4 features. macOS ships bash 3.2.
if [ "${BASH_VERSINFO[0]}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }; then
  printf 'FAIL bash 4.4 or newer is required (found %s). Install a newer bash, or use make check-docker.\n' "$BASH_VERSION" >&2
  exit 1
fi

# REPO_ROOT is the folder above scripts/. One override exists: a REPO_ROOT that is already
# set and points into a git work tree wins. scripts/ci-base-guard.sh uses it to run the
# base branch's copy of a script (extracted to a temp dir) against this checkout. The
# override is announced on stderr, so a stray REPO_ROOT in your shell never goes unnoticed.
_lib_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -n "${REPO_ROOT:-}" ] && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
  [ "$REPO_ROOT" = "$_lib_root" ] || printf 'note REPO_ROOT override in use: %s (scripts from %s)\n' "$REPO_ROOT" "$_lib_root" >&2
else
  REPO_ROOT="$_lib_root"
fi
unset _lib_root
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

# check_array_name NAME RESERVED_GLOB...: die unless NAME is a plain variable name that
# does not collide with the internal names of the helper below. A nameref that points at
# the helper's own local would silently hand the caller an empty array (fail-open).
check_array_name() {
  local _ca_name="$1" _ca_glob
  shift
  [[ "$_ca_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die "internal error: '$_ca_name' is not a valid array name"
  for _ca_glob in "$@"; do
    # shellcheck disable=SC2053 # the reserved names are globs
    [[ "$_ca_name" == $_ca_glob ]] && die "internal error: array name '$_ca_name' collides with a helper's own variable; pick another name"
  done
  return 0
}

# git_z ARRAY GIT_ARGS...: run git in the repo and fill ARRAY (in the current shell)
# with its NUL-delimited output. Names are never C-quoted and may hold any byte
# except NUL. A git failure (not a repo, "dubious ownership", bad ref) is fatal for
# the calling script. Process substitution would hide that exit status, so the
# output goes through a temp file.
git_z() {
  check_array_name "$1" '_gz_*'
  local -n _gz_out="$1"
  shift
  local _gz_tmp _gz_rc=0
  _gz_tmp="$(mktemp)" || die "cannot create a temp file"
  git -C "$REPO_ROOT" "$@" >"$_gz_tmp" || _gz_rc=$?
  if [ "$_gz_rc" -ne 0 ]; then
    rm -f "$_gz_tmp"
    die "git $* failed (exit $_gz_rc). Is this a git repository you may read (safe.directory)?"
  fi
  mapfile -d '' -t _gz_out <"$_gz_tmp"
  rm -f "$_gz_tmp"
}

# repo_files ARRAY [PATHSPEC...]: fill ARRAY with the files git tracks or would
# track (not ignored) that exist, sorted and unique. Using git keeps _local/,
# node_modules/ and other ignored paths out of every check. Dies when git fails,
# so a broken repo can never look like "no files".
repo_files() {
  check_array_name "$1" '_rf_*' '_gz_*'
  local -n _rf_out="$1"
  shift
  local -a _rf_all=()
  local _rf_f
  git_z _rf_all ls-files -z --cached --others --exclude-standard -- "$@"
  _rf_out=()
  while IFS= read -r -d '' _rf_f; do
    [ -f "$REPO_ROOT/$_rf_f" ] && _rf_out+=("$_rf_f")
  done < <(if [ "${#_rf_all[@]}" -gt 0 ]; then printf '%s\0' "${_rf_all[@]}" | sort -z -u; fi)
  return 0
}

# load_versions: read tools.versions into the environment.
load_versions() {
  # shellcheck source=../tools.versions
  . "$REPO_ROOT/tools.versions"
}
