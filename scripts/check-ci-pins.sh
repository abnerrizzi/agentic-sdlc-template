#!/usr/bin/env bash
# CI pin check. The CI files cannot include tools.versions, so they repeat the image
# digest. This fails when:
# 1. an image: in a CI file differs from CHECK_IMAGE in tools.versions (or its value is
#    not written as "image: <reference>" on one line, so it cannot be read);
# 2. a CI file has no image: at all;
# 3. a uses: line is not "owner/repo@<40 hex characters>" followed by a "# v1.2.3" comment;
# 4. a workflow uses the pull_request_target trigger (fork code with a write token).
# CI files: .gitlab-ci.yml, .github/workflows/ and .gitea/workflows/ (YAML files).
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"
load_versions
: "${CHECK_IMAGE:?CHECK_IMAGE is not set in tools.versions}"

workflows=()
repo_files workflows '.github/workflows/*.yml' '.github/workflows/*.yaml' '.gitea/workflows/*.yml' '.gitea/workflows/*.yaml'
gitlab=()
repo_files gitlab '.gitlab-ci.yml'
files=("${gitlab[@]}" "${workflows[@]}")
[ "${#files[@]}" -gt 0 ] || { fail "ci-pins: no CI files found (.gitlab-ci.yml, .github/workflows/*.yml)"; exit 1; }

status=0

# Quote and comment stripping for a YAML scalar on one line.
unquote() {
  local v="$1"
  v="${v%%[[:space:]]#*}"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  v="${v#[\"\']}"
  v="${v%[\"\']}"
  printf '%s' "$v"
}

images=0
for f in "${files[@]}"; do
  found=0
  while IFS= read -r line; do
    found=1
    images=$((images + 1))
    value="$(unquote "${line#*image:}")"
    if [ -z "$value" ]; then
      fail "$f: 'image:' has no value on the same line. Write 'image: <reference>' so this check can read it."
      status=1
    elif [ "$value" != "$CHECK_IMAGE" ]; then
      fail "$f: image '$value' differs from CHECK_IMAGE in tools.versions ('$CHECK_IMAGE')"
      status=1
    fi
  done < <(grep -E '^[[:space:]]*(-[[:space:]]+)?image:' "$f" || true)
  if [ "$found" -eq 0 ]; then
    fail "$f: no image: found. CI jobs must run in the pinned CHECK_IMAGE."
    status=1
  fi
done

uses=0
pin_re='^[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+@[0-9a-f]{40}$'
for f in "${workflows[@]}"; do
  while IFS= read -r line; do
    uses=$((uses + 1))
    rest="${line#*uses:}"
    ref="$(unquote "${rest%%[[:space:]]#*}")"
    comment=""
    [[ "$rest" == *[[:space:]]#* ]] && comment="${rest#*#}"
    if ! [[ "$ref" =~ $pin_re ]]; then
      fail "$f: 'uses: $ref' is not pinned to a full 40-hex commit SHA (owner/repo@<sha> # vX.Y.Z)"
      status=1
    elif ! [[ "$comment" =~ ^[[:space:]]*v[0-9]+(\.[0-9]+)*([-+][A-Za-z0-9.]+)?[[:space:]]*$ ]]; then
      fail "$f: 'uses: $ref' needs a version comment after the SHA, for example '# v1.2.3'"
      status=1
    fi
  done < <(grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$f" || true)
  if grep -nE '^[^#]*pull_request_target' "$f"; then
    fail "$f: pull_request_target is not allowed (it runs fork code with a write token). Use pull_request."
    status=1
  fi
done

[ "$status" -eq 0 ] && ok "ci-pins: ${#files[@]} CI files, $images image pins match tools.versions, $uses uses: lines pinned"
exit "$status"
