# protocol — generate language bindings from the .proto schema.
# Requires: protoc, and (for Go) protoc-gen-go on PATH:
#   go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

proto_files := `find proto -name '*.proto' 2>/dev/null`

# Generate all bindings
gen: gen-go gen-csharp

# Generate Go bindings into gen/go
gen-go:
    mkdir -p gen/go
    protoc -I proto --go_out=gen/go --go_opt=paths=source_relative {{proto_files}}

# Generate C# bindings into gen/csharp
gen-csharp:
    mkdir -p gen/csharp
    protoc -I proto --csharp_out=gen/csharp {{proto_files}}
