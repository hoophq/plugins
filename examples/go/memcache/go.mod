// The x-memcache plug-in. The SDK is outside every go.work, so run go
// here with GOWORK=off; README.md has the commands.
module github.com/hoophq/plugins/examples/go/memcache

go 1.22

require github.com/hoophq/hoop/sidecar/codec/wasm/sdk/tinygo v0.0.0

replace github.com/hoophq/hoop/sidecar/codec/wasm/sdk/tinygo => ../../../../hoop/sidecar/codec/wasm/sdk/tinygo
