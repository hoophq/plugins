#!/usr/bin/env bash
# Builds dist/sqlframe.wasm from sqlframe.cpp against the C header in the
# hoop repository.
#
# Needs clang with the wasm32 target and wasm-ld (LLVM's lld). On macOS:
# `brew install llvm lld`, then CC=/opt/homebrew/opt/llvm/bin/clang++,
# because Apple clang ships no wasm target. Any LLVM >= 15 works elsewhere.
#
# Environment:
#   HOOP_SIDECAR  checkout of the hoop repository; default ../../../../hoop
#   CC            the clang++ to use; default clang++
#   WASM_LD_DIR   a directory holding wasm-ld, prepended to PATH when set
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
sidecar="${HOOP_SIDECAR:-$here/../../../../hoop}"
include="$sidecar/sidecar/codec/wasm/sdk/c"
CC="${CC:-clang++}"

if [ -n "${WASM_LD_DIR:-}" ]; then
  PATH="$WASM_LD_DIR:$PATH"
fi
if ! command -v wasm-ld >/dev/null 2>&1 && [ ! -x "$(dirname "$(command -v "$CC")")/wasm-ld" ]; then
  echo "build.sh: wasm-ld not found; brew install lld (or set WASM_LD_DIR to a directory holding it)" >&2
  exit 1
fi
if [ ! -f "$include/hoop_codec.h" ]; then
  echo "build.sh: $include/hoop_codec.h not found; set HOOP_SIDECAR to a checkout of the hoop repository" >&2
  exit 1
fi

mkdir -p "$here/dist"
"$CC" --target=wasm32-unknown-unknown -std=c++17 \
  -nostdlib -fno-builtin -fno-exceptions -fno-rtti -O2 \
  -Wall -Wextra -I"$include" \
  -fuse-ld=lld -Wl,--no-entry -Wl,--strip-all \
  -o "$here/dist/sqlframe.wasm" "$here/sqlframe.cpp"
ls -l "$here/dist/sqlframe.wasm"
