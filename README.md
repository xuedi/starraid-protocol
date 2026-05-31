# protocol

The **wire contract** between client/npc and server — the single source of truth for the
game's messages (see [../docs/protocol.md](../docs/protocol.md)).

- Language-neutral **Protobuf** schema under `proto/starraid/v1/`.
- Each component generates its own bindings; **Go** (server, npc, dispatcher, admin backend)
  and **C#** (the Godot client). The wire format can't drift — one schema.
- Scope is the **wire protocol only** — *not* the DB schema (server↔admin contract) and *not*
  the dispatcher control API.

## Generate bindings

Requires `protoc`, plus the Go plugin on your `PATH`:

```sh
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
just gen        # → gen/go (Go) and gen/csharp (C#)
```

(`buf.yaml` is provided for lint/format if you adopt [buf](https://buf.build); the `justfile`
uses `protoc` directly so no extra install is needed beyond the Go plugin.)

Generated code lives in `gen/` and is **not committed** (regenerate from the schema).
