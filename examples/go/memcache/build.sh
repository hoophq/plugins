#!/usr/bin/env bash
# Builds dist/memcache.wasm with TinyGo. The SDK comes from a checkout of
# the hoop repository: go.mod's replace directive names the sibling
# checkout, and HOOP_SIDECAR overrides it through a modfile under dist/.
#
# Needs TinyGo 0.33 or later:
#   brew tap tinygo-org/tools && brew install tinygo
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

if ! command -v tinygo >/dev/null 2>&1; then
  echo "build.sh: tinygo is not installed; the module is built with TinyGo (https://tinygo.org):" >&2
  echo "  brew tap tinygo-org/tools && brew install tinygo" >&2
  exit 1
fi

mkdir -p "$here/dist"
modfile="$here/go.mod"
if [ -n "${HOOP_SIDECAR:-}" ]; then
  sdk="$HOOP_SIDECAR/sidecar/codec/wasm/sdk/tinygo"
  if [ ! -f "$sdk/go.mod" ]; then
    echo "build.sh: no TinyGo SDK at $sdk; HOOP_SIDECAR must name a checkout of github.com/hoophq/hoop" >&2
    exit 1
  fi
  modfile="$here/dist/go.mod"
  sed "s#=> .*#=> $sdk#" "$here/go.mod" > "$modfile"
fi

# -tags must name the same capability set as the manifest in main.go:
# describe traps at load when they differ.
GOWORK=off GOFLAGS="-modfile=$modfile" tinygo build \
  -o "$here/dist/memcache.wasm" \
  -target wasm-unknown -opt=z -no-debug \
  -tags hoop_deny,hoop_content \
  "$here"
ls -l "$here/dist/memcache.wasm"
