# StarRaid protocol — generate language bindings from the .proto schema.
# Requires protoc (install via your package manager) and the protoc-gen-go plugin
# on PATH (`just install`). Run `just` to list recipes.

proto_files := `find proto -name '*.proto' 2>/dev/null | tr '\n' ' '`

# List available recipes
default:
    @just --list

# Install the protoc Go plugin into $(go env GOPATH)/bin (must be on your PATH).
# protoc itself is a system package — e.g. `paru -S protobuf` on Arch.
install:
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# Generate all bindings (Go + C#)
gen: gen-go gen-csharp

# Generate Go bindings into gen/go (committed — server/npc import them directly)
gen-go:
    mkdir -p gen/go
    protoc -I proto --go_out=gen/go --go_opt=paths=source_relative {{proto_files}}

# Generate C# bindings into gen/csharp (gitignored — the client build regenerates them)
gen-csharp:
    mkdir -p gen/csharp
    protoc -I proto --csharp_out=gen/csharp {{proto_files}}

# Remove the gitignored C# bindings (the Go bindings are committed; `just gen` to refresh)
clean:
    rm -rf gen/csharp
