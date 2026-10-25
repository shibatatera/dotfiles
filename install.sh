#!/usr/bin/env bash
set -eu

# dotfilesディレクトリのパスを取得
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

echo "==> 1. パッケージのインストール状況を確認しています..."

# OSごとのパッケージマネージャー判定とインストール
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "エラー: Homebrewが見つかりません。先にHomebrewをインストールしてください。"
        exit 1
    fi
    echo "Homebrewを使って stow, micro, sqlite3 をインストールします..."
    brew install stow micro sqlite3

elif [[ -f /etc/debian_version ]]; then
    # Debian / Ubuntu
    echo "APTを使って stow, micro, sqlite3 をインストールします..."
    sudo apt update
    sudo apt install -y stow micro sqlite3

elif [[ -f /etc/fedora-release ]]; then
    # Fedora
    echo "DNFを使って stow, micro, sqlite3 をインストールします..."
    sudo dnf install -y stow micro sqlite3

else
    echo "警告: 未対応のOSです。手動で stow, micro, sqlite3 をインストールしてください。"
fi

echo "==> 2. GNU Stowでシンボリックリンクを作成します..."

# Stowが既存のディレクトリと競合するのを防ぐため、あらかじめ .config/micro を作成
mkdir -p "$HOME/.config/micro"

# stowコマンドを実行 (sqlite と micro パッケージをホームディレクトリにリンク)
stow -v -d "$DOTFILES_DIR" -t "$HOME" sqlite micro

echo "==> セットアップが完了しました！"
