#!/bin/bash
set -e

echo "=== Starting Rust Server ==="

# 起動前にアップデート
/opt/rust_server/bin/update.sh

echo "Starting Rust Dedicated Server..."
cd /opt/rust_server

if [ ! -f "./RustDedicated" ]; then
    echo "ERROR: RustDedicated binary not found!"
    ls -la /opt/rust_server/
    exit 1
fi

# サーバーデータディレクトリを作成
echo "Setting up server directories..."
mkdir -p /opt/rust_server/server

exec ./RustDedicated \
    -batchmode \
    -server.ip 0.0.0.0 \
    -server.port "${SERVER_PORT:-28015}" \
    -server.queryport "${QUERY_PORT:-28016}" \
    -rcon.ip 0.0.0.0 \
    -rcon.port "${RCON_PORT:-28016}" \
    -rcon.password "${RCON_PASSWORD:-changeme}" \
    -server.maxplayers "${MAX_PLAYERS:-100}" \
    -server.hostname "${SERVER_HOSTNAME:-Rust Server in Docker}" \
    -server.identity "${SERVER_IDENTITY:-rust-server}" \
    -server.level "${SERVER_LEVEL:-Procedural Map}" \
    -server.seed "${SERVER_SEED:-12345}" \
    -server.worldsize "${WORLD_SIZE:-4000}" \
    -server.saveinterval "${SAVE_INTERVAL:-600}" \
    -server.description "${SERVER_DESCRIPTION:-Welcome to Rust Server!}" \
    -server.url "${SERVER_URL:-}" \
    -server.tags "${SERVER_TAGS:-}" \
    "$@"

