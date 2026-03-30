# wt-kanban

kanban サーバー管理 + worktree 並列運用 CLI。

[cline kanban](https://github.com/cline/kanban) のサーバー管理を `wt` コマンドで行い、タスク管理は kanban を直接使用する。

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/lalalasyun/wt-kanban/main/install.sh | bash
```

### 前提条件

- git, tmux, Node.js, npm
- [cline kanban](https://github.com/cline/kanban) (`install.sh` が自動インストール)
- [GitHub CLI](https://cli.github.com/) (`gh`) — PR 作成に必要

## wt コマンド (サーバー管理)

```
wt up                              kanban サーバーを起動
wt down                            kanban サーバーを停止
wt log                             kanban サーバーのログ表示
wt status                          全体の状態サマリ
wt install-service                 systemd で永続化 (初回のみ)
```

## タスク管理 (kanban 直接使用)

```bash
# タスク作成 (PR自動作成モード)
kanban task create \
  --prompt "機能実装の説明" \
  --project-path . \
  --base-ref main \
  --auto-review-mode pr

# タスク開始 (worktree 作成 + エージェント起動)
kanban task start --task-id <id> --project-path .

# タスク一覧
kanban task list --project-path .
kanban task list --project-path . --column in_progress

# タスク削除
kanban task trash --task-id <id> --project-path .

# タスク依存関係
kanban task link --task-id <id1> --linked-task-id <id2> --project-path .
```

### auto-review-mode

| モード | 動作 |
|--------|------|
| `commit` | 完了時にベースブランチへ cherry-pick |
| `pr` | 完了時にエージェントが `gh pr create` でPR作成 |
| `move_to_trash` | 完了時にそのまま trash へ移動 |

## セットアップ

```bash
# 1. インストール
curl -fsSL https://raw.githubusercontent.com/lalalasyun/wt-kanban/main/install.sh | bash

# 2. systemd で永続化 (再起動後も自動起動)
wt install-service

# 3. 動作確認
wt status
```

## 運用パターン

### 複数タスク並列 (PR自動作成)

```bash
# サーバー起動
wt up

# タスク追加 → 開始
kanban task create --prompt "機能A実装" --project-path . --base-ref main --auto-review-mode pr
kanban task create --prompt "機能B実装" --project-path . --base-ref main --auto-review-mode pr
kanban task start --task-id <id1> --project-path .
kanban task start --task-id <id2> --project-path .

# 状態確認
wt status
```

### 外出先からの監視

SSH トンネルでポート 3484 を転送:

```bash
ssh -L 3484:localhost:3484 user@server
```

ブラウザで `http://localhost:3484` を開く。

## Worktree

kanban がタスクごとに `~/.cline/worktrees/<taskId>/` に git worktree を自動作成する。

- detached HEAD でベースコミットから分離
- gitignore 対象 (node_modules 等) はシンボリックリンクで共有
- タスク削除時に自動クリーンアップ

## 環境変数

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `WT_PROJECT` | git root | 対象リポジトリ |
| `WT_TMUX_SESSION` | `dev` | tmux セッション名 |
| `WT_PORT` | `3484` | kanban ポート |

## アンインストール

```bash
systemctl --user disable --now kanban  # サービス停止
sudo rm /usr/local/bin/wt
rm -rf ~/.wt-kanban
rm ~/.config/systemd/user/kanban.service
sudo npm uninstall -g kanban  # 任意
```
