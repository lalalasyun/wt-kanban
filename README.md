# wt-kanban

worktree + kanban + tmux + Claude Code のワークフロー管理 CLI。

[cline kanban](https://github.com/cline/kanban) をベースに、`wt` コマンドでタスク管理・worktree 分離・tmux 並列運用をシンプルに行う。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/lalalasyun/wt-kanban/main/install.sh | bash
```

### 前提条件

- git, tmux, Node.js, npm
- [cline kanban](https://github.com/cline/kanban) (`install.sh` が自動インストール)

## コマンド一覧

```
wt up                              kanban サーバーを起動
wt down                            kanban サーバーを停止
wt log                             kanban サーバーのログ表示
wt add <タスク説明> [ブランチ]       タスクを作成
wt start <task-id>                 タスクを開始 (worktree + エージェント)
wt ls [カラム]                      タスク一覧
wt rm <task-id>                    タスクを削除
wt status                          全体の状態サマリ
wt install-service                 systemd で永続化 (初回のみ)
```

`wt add` / `wt ls` / `wt start` / `wt rm` はサーバー未起動時に自動で `wt up` する。

## セットアップ

```bash
# 1. インストール
curl -fsSL https://raw.githubusercontent.com/lalalasyun/wt-kanban/main/install.sh | bash

# 2. systemd で永続化 (再起動後も自動起動)
wt install-service

# 3. 動作確認
wt status
```

## 使い方

```bash
# タスクを追加
wt add "Issue #45: archive search を実装" main

# タスク一覧
wt ls
wt ls in_progress

# タスク開始 (worktree 作成 + エージェント起動)
wt start <task-id>

# タスク削除
wt rm <task-id>

# サーバー管理
wt up       # 起動
wt down     # 停止
wt log      # ログ
```

## 運用パターン

### 単発の長時間作業

```bash
tmux new -s dev
cd ~/workspace/your-project
while true; do claude; echo "exited: $(date)"; sleep 2; done
```

### 複数タスク並列

```bash
# タスク追加 → 開始 (サーバーは自動起動)
wt add "Issue #45: 機能実装" main
wt add "Issue #46: ドキュメント整備" main
wt start <task-id-1>
wt start <task-id-2>

# 状態確認
wt status
```

### 外出先からの監視

SSH トンネルでポート 3484 を転送:

```bash
ssh -L 3484:localhost:3484 user@server
```

ブラウザで `http://localhost:3484` を開く。

## 環境変数

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `WT_PROJECT` | git root | 対象リポジトリ |
| `WT_TMUX_SESSION` | `dev` | tmux セッション名 |
| `WT_PORT` | `3484` | kanban ポート |

## トラブルシューティング

### ワークスペースの JSON ファイルが壊れた場合

kanban は `~/.cline/kanban/workspaces/<workspace>/` 以下に状態ファイルを保持する。バリデーションエラーが出た場合、以下の正しいフォーマットで再作成する。

**board.json** — ボード状態 (`RuntimeBoardData`)

```json
{
  "columns": [
    { "id": "backlog", "title": "Backlog", "cards": [] },
    { "id": "in_progress", "title": "In Progress", "cards": [] },
    { "id": "review", "title": "Review", "cards": [] },
    { "id": "trash", "title": "Trash", "cards": [] }
  ],
  "dependencies": []
}
```

- `columns` は配列（オブジェクトではない）
- 4 つのカラム ID (`backlog`, `in_progress`, `review`, `trash`) が必須

**sessions.json** — セッション状態 (`Record<string, SessionSummary>`)

```json
{}
```

- トップレベルが直接 `Record<taskId, Session>` のオブジェクト
- `{ "sessions": {} }` のようにラップしない

**meta.json** — メタデータ (`WorkspaceStateMeta`)

```json
{
  "revision": 0,
  "updatedAt": 0
}
```

- `updatedAt` は数値（Unix タイムスタンプ）。文字列の日付ではない

## アンインストール

```bash
systemctl --user disable --now kanban  # サービス停止
sudo rm /usr/local/bin/wt
rm -rf ~/.wt-kanban
rm ~/.config/systemd/user/kanban.service
sudo npm uninstall -g kanban  # 任意
```
