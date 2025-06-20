# Hexcall

TODO

# Dev

## Local Dev


Set SECRET_KEY_BASE first:
```bash
export SECRET_KEY_BASE=$(mix phx.gen.secret)
```
Start a local postgres instance:
```bash
docker run --name postgres \
--detach \
--publish 5432:5432 \
-e POSTGRES_HOST_AUTH_METHOD=trust \
--mount type=tmpfs,destination=/tmp/postgresql/data \
postgres
```
Run server with 
```bash
mix phx.server
```
or inside IEx with 
```bash
iex -S mix phx.server
```

## Docker

Build with: 
```bash
docker build .
```
Run (adjust env as needed):
```bash
docker run --rm \
--network="host" \
-e PHX_HOST=localhost \
-e DATABASE_URL="ecto://postgres:postgres@localhost/hexcall_dev" \
-e SECRET_KEY_BASE=TiBFjhsHAWALNyNKhuVd7fMJ+ARH13hQzGRv3+wWsq/XCICB2YhmvajzJjAaqDRo \
hexcall
```

## Docker Compose

Adjust `.env`, then:
```bash
docker compose up
```