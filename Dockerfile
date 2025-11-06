FROM ubuntu:25.04

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive \
    RUST_SERVER_DIR=/opt/rust_server \
    RUST_APP_ID=258550 \
    HOME=/root

# 必要なパッケージのインストール（32bit SteamCMD用ライブラリ含む）
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    lib32gcc-s1 \
    lib32stdc++6 \
    wget \
    curl \
    unzip \
    ca-certificates \
    tar \
    locales \
    netcat-openbsd \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ロケール設定
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# サーバーディレクトリの作成
RUN mkdir -p ${RUST_SERVER_DIR}

WORKDIR /root

# SteamCMDのインストール（rootユーザーで実行）
RUN mkdir -p /root/steamcmd && \
    cd /root/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# スクリプトディレクトリの作成
RUN mkdir -p ${RUST_SERVER_DIR}/bin

# スクリプトファイルをコピー
COPY src/update.sh ${RUST_SERVER_DIR}/bin/update.sh
COPY src/start_rust.sh ${RUST_SERVER_DIR}/bin/start_rust.sh

# 実行権限を付与
RUN chmod +x ${RUST_SERVER_DIR}/bin/update.sh ${RUST_SERVER_DIR}/bin/start_rust.sh

# 必要なポートを公開
# 28015: ゲームポート (UDP)
# 28016: クエリポート・RCONポート (UDP/TCP)
EXPOSE 28015/udp 28016/udp 28016/tcp

# ボリュームの定義
VOLUME ["${RUST_SERVER_DIR}/server"]

WORKDIR ${RUST_SERVER_DIR}

# ヘルスチェック（RustDedicatedプロセスの確認）
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=150 \
    CMD pgrep -f RustDedicated > /dev/null || exit 1

# rootユーザーで実行
CMD ["/opt/rust_server/bin/start_rust.sh"]
