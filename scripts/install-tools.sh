#!/usr/bin/env bash
# Install the pinned lint tools from tools.versions into TOOLS_DIR.
#
# This is the ONLY script in scripts/ that uses the network. make check never
# calls it. It is used by CI, by ci/Dockerfile, and by humans who opt in.
# Every download is checked against the sha256 in tools.versions (or the
# lockfile hashes for npm and pip) before it is unpacked.
#
# Usage: scripts/install-tools.sh [--with-os-packages]
#   --with-os-packages  also apt-get install git, make, curl, xz (containers/CI only)
# Writes only to TOOLS_DIR (default: ~/.cache/agentic-sdlc-template/tools).
set -euo pipefail
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
load_versions

if [ "${1:-}" = "--with-os-packages" ]; then
  command -v apt-get >/dev/null || die "--with-os-packages needs apt-get (Debian or Ubuntu)"
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends git make curl ca-certificates xz-utils >/dev/null
  rm -rf /var/lib/apt/lists/*
fi

need curl
need sha256sum
need tar

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)         arch=X64;   gl_arch=x64;   ly_arch=x86_64;  sc_arch=x86_64;  node_arch=x64 ;;
  Linux-aarch64|Linux-arm64) arch=ARM64; gl_arch=arm64; ly_arch=aarch64; sc_arch=aarch64; node_arch=arm64 ;;
  *) die "unsupported platform $(uname -s)-$(uname -m). Use make check-docker, or install the tools by hand (see make doctor)." ;;
esac

pin() { local v="$1_SHA256_LINUX_$arch"; printf '%s' "${!v}"; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$TOOLS_DIR/bin"

# fetch NAME URL SHA256: download to $tmp/NAME and verify before use.
fetch() {
  info "download $1"
  curl -fsSL --retry 3 -o "$tmp/$1" "$2"
  printf '%s  %s\n' "$3" "$tmp/$1" | sha256sum -c --quiet - || die "checksum mismatch for $1"
}

# install_binary NAME ARCHIVE: unpack and copy the binary called NAME to TOOLS_DIR/bin.
install_binary() {
  mkdir -p "$tmp/x-$1"
  tar -xf "$tmp/$2" -C "$tmp/x-$1"
  find "$tmp/x-$1" -type f -name "$1" -exec install -m 0755 {} "$TOOLS_DIR/bin/$1" \;
  [ -x "$TOOLS_DIR/bin/$1" ] || die "$1 not found in $2"
}

fetch gitleaks.tgz \
  "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${gl_arch}.tar.gz" \
  "$(pin GITLEAKS)"
install_binary gitleaks gitleaks.tgz

fetch lychee.tgz \
  "https://github.com/lycheeverse/lychee/releases/download/lychee-v${LYCHEE_VERSION}/lychee-${ly_arch}-unknown-linux-musl.tar.gz" \
  "$(pin LYCHEE)"
install_binary lychee lychee.tgz

fetch shellcheck.tgz \
  "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${sc_arch}.tar.gz" \
  "$(pin SHELLCHECK)"
install_binary shellcheck shellcheck.tgz

# Node.js, then markdownlint-cli2 from the lockfile.
fetch node.txz \
  "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz" \
  "$(pin NODE)"
rm -rf "$TOOLS_DIR/node"
mkdir -p "$TOOLS_DIR/node"
tar -xJf "$tmp/node.txz" -C "$TOOLS_DIR/node" --strip-components 1
"$TOOLS_DIR/node/bin/node" --version >/dev/null 2>&1 ||
  die "the official Node.js build does not run here (it needs glibc 2.28 or newer). Use make check-docker."

mkdir -p "$TOOLS_DIR/npm"
cp "$REPO_ROOT/package.json" "$REPO_ROOT/package-lock.json" "$TOOLS_DIR/npm/"
info "npm ci markdownlint-cli2"
npm ci --prefix "$TOOLS_DIR/npm" --ignore-scripts --no-audit --no-fund --loglevel error

# yamllint into a virtualenv, every file hash-checked.
need python3
python3 - "$PYTHON_MIN_VERSION" <<'PY' || die "python3 >= $PYTHON_MIN_VERSION is needed for yamllint. Use make check-docker."
import sys
want = tuple(int(p) for p in sys.argv[1].split("."))
sys.exit(0 if sys.version_info[:2] >= want else 1)
PY
rm -rf "$TOOLS_DIR/venv"
python3 -m venv "$TOOLS_DIR/venv"
info "pip install yamllint"
"$TOOLS_DIR/venv/bin/pip" install --quiet --disable-pip-version-check \
  --require-hashes --no-deps --only-binary=:all: -r "$REPO_ROOT/requirements-lint.txt"

ok "tools installed in $TOOLS_DIR"
"$REPO_ROOT/scripts/doctor.sh"
