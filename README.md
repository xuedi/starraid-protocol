# protocol

The **wire contract** between client/npc and server — the single source of truth for the
game's messages (see [../docs/protocol.md](../docs/protocol.md)).

- Language-neutral **Protobuf** schema under `proto/starraid/v1/`.
- Each component generates its own bindings; **Go** (server, npc, dispatcher, admin backend)
  and **C#** (the Godot client). The wire format can't drift — one schema.
- Scope is the **wire protocol only** — *not* the DB schema (server↔admin contract) and *not*
  the dispatcher control API.

## Prerequisites

- `protoc` — a system package (e.g. `paru -S protobuf` on Arch)
- the `protoc-gen-go` plugin on your `PATH` — `just install` (drops it in `$(go env GOPATH)/bin`)

## Generate bindings

```sh
just install    # one-time: install the protoc Go plugin
just gen        # → gen/go (Go, committed) and gen/csharp (C#, gitignored)
```

(`buf.yaml` is provided for lint/format if you adopt [buf](https://buf.build); the `justfile`
uses `protoc` directly so no extra install is needed beyond the Go plugin.)

The **Go** bindings under `gen/go` are a **committed** Go module
(`github.com/xuedi/starraid-protocol/gen/go`) so the server/npc build without everyone running
`protoc` — regenerate them on every schema change. Consumers (server, npc) point a local
`go.work` at this checkout; see their READMEs. The **C# bindings** (`gen/csharp`) are gitignored
and regenerated for the client build.

## Framing & envelopes

Protobuf is not self-delimiting, so each message is sent as a **length-prefixed frame**:

```
+-----------------------------+------------------------------+
| length: uint32 (big-endian) | payload: marshalled envelope |
+-----------------------------+------------------------------+
```

The 4-byte length is the payload byte count; the receiver reads exactly that many bytes and
unmarshals them. A **max frame size** is enforced to bound per-connection memory.

Every frame carries exactly one **directional envelope** — `ClientMessage` (client → server) or
`ServerMessage` (server → client), each a `oneof` over the concrete messages
(`envelope.proto`). One envelope per direction lets the receiver dispatch on type and keeps
illegal-direction messages off the wire. The `oneof` grows additively as the protocol evolves.
