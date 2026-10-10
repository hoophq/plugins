# hoop Sidecar plug-ins

Codec plug-ins for the [hoop Sidecar](https://hoop.dev/docs/setup/configuration/hoop-sidecar/plugins/overview). A plug-in is one WebAssembly module that decodes one wire protocol the Sidecar does not ship. The Sidecar loads it from its config file, hands it the bytes of each connection, and evaluates the statements it returns with the same guardrails, masking, audit and AI analysis a built-in protocol gets.

This repository holds worked examples, one per language, each a complete plug-in with fixtures and a config you can run.

## Examples

| Directory | Protocol | Language | Shows |
|---|---|---|---|
| `examples/rust/resp` | Redis RESP2 | Rust (`hoop-codec` crate) | arrays and inline commands, native deny frame, masking of bulk replies, credential lifting from `AUTH` |
| `examples/go/memcache` | memcached text | Go (TinyGo) | line protocol with data blocks, native deny frame, custom analyzer content |
| `examples/cpp/sqlframe` | a binary framing that carries SQL | C++17 freestanding over `hoop_codec.h` | the host SQL classifier through `analyze_sql` and `split_sql`, a stream filter for keepalive padding |

Each example directory carries:

- `README.md`: the protocol, the build, the test, and which rule types can fence it
- `fixtures.json`: scripts the conformance tool replays
- `build.sh`: produces `dist/<name>.wasm`
- `config.yaml`: a Sidecar config that loads the module and fences one command

## Build

The SDKs and the ABI live in the hoop repository under `sidecar/codec/wasm`. Every build script reads `HOOP_SIDECAR`, the path to a checkout of that repository, and defaults to `../../../../hoop` relative to the example.

| Language | Toolchain |
|---|---|
| Rust | `rustup target add wasm32-unknown-unknown` |
| Go | [TinyGo](https://tinygo.org) 0.33 or later |
| C++ | LLVM 15 or later with the wasm32 target and `wasm-ld` (`brew install llvm lld` on macOS) |

## Test

`hoop start sidecar --codec-test` proves a module against the ABI, then replays the example's fixtures:

```sh
cd examples/rust/resp
./build.sh
hoop start sidecar --codec-test dist/resp.wasm fixtures.json
```

All eight checks must pass before a module goes near traffic. Check 7 replays each script one byte at a time and is the one that catches most decoders.

## Run

```sh
hoop start sidecar --config config.yaml --validate
hoop start sidecar --config config.yaml
```

The validate report names the loaded module, its version, its digest and its capabilities. Pin `sha256` in the `plugins` entry before you serve a module from a URL.

## Writing your own

Copy the example closest to your protocol. The author guide is at `documentation/setup/configuration/hoop-sidecar/plugins/writing`, and the ABI reference for a language without an SDK at `.../plugins/abi`.

## License

MIT.
