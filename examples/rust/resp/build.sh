#!/usr/bin/env bash
# Builds the x-resp plug-in for wasm32-unknown-unknown into dist/resp.wasm.
#
# HOOP_SIDECAR names the hoop checkout that carries the SDK; the default is
# the sibling checkout Cargo.toml already points at. Cargo cannot read an
# environment variable inside a `path` dependency, so another location
# gets a generated manifest under target/ that names it.
#
# Needs: rustup target add wasm32-unknown-unknown
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
sidecar="${HOOP_SIDECAR:-$here/../../../../hoop}"
sdk="$sidecar/sidecar/codec/wasm/sdk/rust"
if [ ! -f "$sdk/Cargo.toml" ]; then
  echo "build.sh: no SDK at $sdk; set HOOP_SIDECAR to the hoop checkout" >&2
  exit 1
fi

manifest="$here/Cargo.toml"
default_sdk="$(cd "$here/../../../../hoop/sidecar/codec/wasm/sdk/rust" 2>/dev/null && pwd || true)"
if [ "$(cd "$sdk" && pwd)" != "$default_sdk" ]; then
  mkdir -p "$here/target/hoop-sidecar"
  manifest="$here/target/hoop-sidecar/Cargo.toml"
  sed -e "s#path = \"../../../../hoop/sidecar/codec/wasm/sdk/rust\"#path = \"$sdk\"#" "$here/Cargo.toml" \
    | awk -v lib='path = "../../src/lib.rs"' '{ print } /^\[lib\]$/ { print lib }' > "$manifest"
fi

cargo build --release --target wasm32-unknown-unknown \
  --manifest-path "$manifest" --target-dir "$here/target"
mkdir -p "$here/dist"
cp "$here/target/wasm32-unknown-unknown/release/resp.wasm" "$here/dist/resp.wasm"
ls -l "$here/dist/resp.wasm"
