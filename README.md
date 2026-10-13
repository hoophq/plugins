# hoop Sidecar plug-ins

Codec plug-ins for the [hoop Sidecar](https://hoop.dev/docs/setup/configuration/hoop-sidecar/plugins/overview). A plug-in is one WebAssembly module that decodes one wire protocol the Sidecar does not ship. The Sidecar loads it from its config file, hands it the bytes of each connection, and evaluates the statements it returns with the same guardrails, masking, audit and AI analysis a built-in protocol gets.

This repository is the starting point for a vendor: the SDK install commands, one worked example per language, and the config that runs each one.

## Install an SDK

| Language | Install | Build target |
|---|---|---|
| Rust | `cargo add hoop-codec` | `rustup target add wasm32-unknown-unknown` |
| Go | `go get github.com/hoophq/hoop/sidecar/codec/wasm/sdk/tinygo@v0.1.0` | [TinyGo](https://tinygo.org) 0.43 or later |
| C / C++ | `curl -fsSLO https://raw.githubusercontent.com/hoophq/plugins/main/sdk/c/hoop_codec.h` (this repository, `sdk/c/`) | LLVM 15 or later with the wasm32 target and `wasm-ld` (`brew install llvm lld` on macOS) |

None of them depends on anything private. The SDK source and the ABI live in the hoop repository under `sidecar/codec/wasm`; the versions above are what the release workflow published.

## Examples

| Directory | Protocol | Language | Shows |
|---|---|---|---|
| `examples/resp` | Redis RESP2 | Rust | arrays and inline commands, native deny frame, masking of bulk replies, credential lifting from `AUTH` |
| `examples/memcache` | memcached text | Go (TinyGo) | a line protocol with data blocks, native deny frame, custom analyzer content |
| `examples/sqlframe` | a binary framing that carries SQL | C++17 freestanding | the host SQL classifier through `analyze_sql` and `split_sql`, a stream filter for keepalive padding |

Each directory carries a `README.md` (the protocol, the build, which rule types fence it), `fixtures.json` (the scripts the conformance tool replays), `build.sh`, and a `config.yaml` that loads the module and fences one command.

A workflow in the hoop repository copies these from `sidecar/codec/wasm/examples` on every SDK release, with the dependencies pointed at the published versions. Edit them there; a change here is overwritten on the next release.

## Write your own

```sh
cp -r examples/resp my-plugin && cd my-plugin
# edit src/lib.rs: manifest(), the frame parser, the operation table
# edit fixtures.json: captured frames and the statements you expect
cargo test
./build.sh
hoop start sidecar --codec-test dist/my-plugin.wasm fixtures.json
hoop start sidecar --config config.yaml --validate
```

All eight checks must pass before a module goes near traffic. Check 7 replays each script one byte at a time through the Sidecar's reassembly and is the one that catches most decoders; it names the failing step.

The author guide is at [Writing a Plug-in](https://hoop.dev/docs/setup/configuration/hoop-sidecar/plugins/writing). The [ABI reference](https://hoop.dev/docs/setup/configuration/hoop-sidecar/plugins/abi) is the contract for a language without an SDK.

## Run

```sh
hoop start sidecar --config config.yaml --validate
hoop start sidecar --config config.yaml
```

The validate report names the loaded module, its version, its digest and its capabilities. Pin `sha256` in the `plugins` entry before you serve a module from a URL.

## License

MIT.
