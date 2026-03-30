#!/usr/bin/env bash
set -euo pipefail

# wt-kanban installer
# curl -fsSL https://raw.githubusercontent.com/lalalasyun/wt-kanban/main/install.sh | bash

REPO_URL="https://github.com/lalalasyun/wt-kanban.git"
INSTALL_DIR="${WT_INSTALL_DIR:-$HOME/.wt-kanban}"
BIN_DIR="/usr/local/bin"

echo "wt-kanban セットアップ"
echo "========================"

# 1. 依存チェック
echo ""
echo "[1/5] 依存チェック..."

missing=()
command -v git    &>/dev/null || missing+=(git)
command -v tmux   &>/dev/null || missing+=(tmux)
command -v node   &>/dev/null || missing+=(node)
command -v npm    &>/dev/null || missing+=(npm)

if [ ${#missing[@]} -gt 0 ]; then
  echo "Error: 以下が必要です: ${missing[*]}"
  echo "  sudo apt install -y git tmux nodejs npm"
  exit 1
fi
echo "  git, tmux, node, npm ... OK"

# 2. kanban インストール
echo ""
echo "[2/5] cline kanban インストール..."

if command -v kanban &>/dev/null; then
  echo "  kanban $(kanban --version) ... 既にインストール済み"
else
  echo "  sudo npm install -g kanban ..."
  sudo npm install -g kanban
  echo "  kanban $(kanban --version) ... OK"
fi

# 3. wt コマンド配置
echo ""
echo "[3/5] wt コマンド配置..."

if [ -d "$INSTALL_DIR" ]; then
  echo "  既存インストールを更新..."
  cd "$INSTALL_DIR" && git pull --ff-only
else
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/wt"
sudo ln -sf "$INSTALL_DIR/wt" "$BIN_DIR/wt"
echo "  $BIN_DIR/wt -> $INSTALL_DIR/wt ... OK"

# 4. tmux 設定
echo ""
echo "[4/5] tmux 設定..."

TMUX_CONF="$HOME/.tmux.conf"
touch "$TMUX_CONF"

add_tmux_setting() {
  local setting="$1"
  if ! grep -qF "$setting" "$TMUX_CONF"; then
    echo "$setting" >> "$TMUX_CONF"
    echo "  追加: $setting"
  fi
}

add_tmux_setting "set -g mouse on"
add_tmux_setting "set -g history-limit 50000"
add_tmux_setting "set -g status-interval 5"
echo "  $TMUX_CONF ... OK"

# 5. systemd 永続化
echo ""
echo "[5/5] systemd サービス登録..."

wt install-service 2>/dev/null && echo "  kanban サービス ... OK" || echo "  スキップ (手動で wt install-service を実行してください)"

# 完了
echo ""
echo "========================"
echo "セットアップ完了!"
echo ""
echo "使い方:"
echo "  wt status                        # 状態確認"
echo "  wt add \"タスク説明\" main          # タスク追加"
echo "  wt start <task-id>               # タスク開始"
echo "  wt ls                            # 一覧"
echo "  wt rm <task-id>                  # 削除"
echo "  wt up / wt down / wt log         # サーバー管理"
echo "  wt --help                        # ヘルプ"
