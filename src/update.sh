#!/bin/bash
set -ex

export DEBIAN_FRONTEND=noninteractive

echo "=== Starting Rust Server Update ==="
echo "Installing/Updating Rust server (this may take 15-30 minutes on first run)..."
echo "SteamCMD path: /root/steamcmd/steamcmd.sh"
echo "Install directory: /opt/rust_server"

# SteamCMDを使用してRustサーバーをダウンロード・更新
echo "Running SteamCMD..."
/root/steamcmd/steamcmd.sh \
    +force_install_dir /opt/rust_server \
    +login anonymous \
    +app_update 258550 \
    +quit || {
        EXITCODE=$?
        echo "SteamCMD failed with exit code $EXITCODE"
        echo "SteamCMD directory contents:"
        ls -la /root/steamcmd/
        echo "Server directory contents:"
        ls -la /opt/rust_server/
        exit 1
    }

echo "Checking for RustDedicated binary..."
ls -lh /opt/rust_server/ | head -20

if [ ! -f "/opt/rust_server/RustDedicated" ]; then
    echo "ERROR: RustDedicated not found after download!"
    exit 1
fi

# 実行権限を付与
echo "Setting executable permissions..."
chmod +x /opt/rust_server/RustDedicated

# Steam SDKの設定（SteamCMDから64bit版steamclient.soを取得）
echo "Setting up Steam SDK..."
mkdir -p /root/.steam/sdk64

# app_id 1007でsteamclient.soを取得
echo "Downloading steamclient.so (64bit) using SteamCMD..."
mkdir -p /tmp/steamclient_download
/root/steamcmd/steamcmd.sh \
    +login anonymous \
    +force_install_dir /tmp/steamclient_download \
    +app_update 1007 validate \
    +quit

# 64bit版steamclient.soをコピー
if [ -f "/tmp/steamclient_download/linux64/steamclient.so" ]; then
    cp -f /tmp/steamclient_download/linux64/steamclient.so /root/.steam/sdk64/steamclient.so
    echo "Copied 64bit steamclient.so to /root/.steam/sdk64/"
    rm -rf /tmp/steamclient_download
else
    echo "WARNING: steamclient.so (64bit) not found"
fi

echo "Rust server downloaded successfully!"
echo "Installing/Updating Oxide..."
cd /opt/rust_server
wget -q https://umod.org/games/rust/download/develop -O oxide.zip || {
    echo "Failed to download Oxide"
    exit 1
}
unzip -o oxide.zip
rm oxide.zip
echo "=== Update completed successfully! ==="

