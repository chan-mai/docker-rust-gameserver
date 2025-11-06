# docker-rust-gameserver

SteamCMDとOxideを使用したRustゲームサーバーのDockerイメージです。


## 特徴

- Ubuntu 25.04ベース（x86_64）
- **SteamCMD** による自動ダウンロード・インストール
- Rustサーバー（App ID: 258550）自動ダウンロード
- **Oxideプラグインサポート**
- 環境変数による柔軟な設定
- 起動時の自動アップデート
- RCON対応


## 実行方法

### Docker Composeを使用した実行（推奨）

```bash
# サーバーの起動
docker compose up -d

# ログの確認
docker compose logs -f

# サーバーの停止
docker compose down
```

### カスタム設定

`compose.yml`ファイルの`environment`セクションを編集して設定を変更できます：

```yaml
environment:
  - SERVER_HOSTNAME=My Custom Rust Server
  - MAX_PLAYERS=150
  - WORLD_SIZE=6000
  - SERVER_SEED=54321
  - RCON_PASSWORD=your-secure-password
```

### Dockerコマンドで実行

```bash
docker run -d \
  --platform linux/amd64 \
  --name rust-server \
  -p 28015:28015/udp \
  -p 28016:28016/udp \
  -p 28016:28016/tcp \
  -v rust-data:/opt/rust_server/server \
  -e SERVER_HOSTNAME="My Rust Server" \
  -e MAX_PLAYERS=100 \
  -e RCON_PASSWORD=changeme \
  rust-gameserver
```

## 環境変数一覧

| 環境変数 | デフォルト値 | 説明 |
|---------|------------|------|
| `SERVER_PORT` | `28015` | ゲームポート |
| `QUERY_PORT` | `28016` | クエリポート |
| `RCON_PORT` | `28016` | RCONポート |
| `RCON_PASSWORD` | `changeme` | RCONパスワード |
| `MAX_PLAYERS` | `100` | 最大プレイヤー数 |
| `SERVER_HOSTNAME` | `Rust Server in Docker` | サーバー名 |
| `SERVER_IDENTITY` | `rust-server` | サーバー識別名(セーブデータのディレクトリ名) |
| `SERVER_LEVEL` | `Procedural Map` | マップ種別 |
| `SERVER_SEED` | `12345` | マップシード値 |
| `WORLD_SIZE` | `4000` | マップサイズ |
| `SAVE_INTERVAL` | `600` | セーブ間隔(sec) |
| `SERVER_DESCRIPTION` | `Welcome to Rust Server!` | サーバー説明文(`\n`で改行可) |
| `SERVER_URL` | - | サーバーのWebサイトURL |
| `SERVER_TAGS` | - | サーバータグ(カンマ区切り) |

## ポート設定

| ポート | プロトコル | 用途 |
|--------|-----------|------|
| 28015  | UDP       | ゲームポート |
| 28016  | UDP       | クエリポート |
| 28016  | TCP       | RCONポート |

## ボリューム

サーバーデータを永続化するために、以下のディレクトリをボリュームにマウントしてください：

- `/opt/rust_server/server` - サーバーデータ、ワールドデータ、Oxideプラグイン、設定ファイル

プラグインは`/opt/rust_server/server/<SERVER_IDENTITY>/oxide/plugins/`に配置されます。


## サーバーの更新

**このイメージは起動時に自動的にサーバーとOxideを最新版に更新します。**

手動で更新する場合：

```bash
# コンテナに入る
docker exec -it rust-gameserver /bin/bash

# 更新スクリプトを実行
/opt/rust_server/bin/update.sh
```

