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

## 使い方

```bash
# kanban ダッシュボードを起動 (先に起動が必要)
wt board

# タスクを追加
wt add "Issue #45: archive search を実装" main

# タスク一覧
wt ls
wt ls in_progress

# タスク開始 (worktree 作成 + エージェント起動)
wt start <task-id>

# タスク削除
wt rm <task-id>

# 全体の状態確認
wt status
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
tmux new -s dev

# ウィンドウ 0: kanban ダッシュボード
wt board

# 別ウィンドウ: タスク追加 → 開始
wt add "Issue #45: 機能実装" main
wt start <task-id>
```

### 外出先からの監視

Termius や SSH トンネルでポート 3484 を転送:

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

## アンインストール

```bash
sudo rm /usr/local/bin/wt
rm -rf ~/.wt-kanban
sudo npm uninstall -g kanban  # 任意
```
