#!/usr/bin/env bash
# Listen on Railway's PORT (8080 by default), then run the upstream entrypoint,
# which prepares /app-data, writes the nginx config and execs our CMD.
set -e
export LISTEN_PORT="${PORT:-8080}"
exec /entrypoint.sh "$@"
