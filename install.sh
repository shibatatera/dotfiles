#!/usr/bin/env bash
set -eu

REPO_URL="https://github.com/your-username/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> 1. dotfilesリポジトリの準備をしています..."

# まだクローンされていなければクローンし、されていれば最新に更新
if [ ! -d "$DOTFILES_DIR" ]; then
    if ! command -v git &> /dev/null; then
        echo "エラー: gitが見つかりません。先にgitをインストールしてください。"
        exit 1
    fi
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "既存のdotfilesを更新しています..."
    git -C "$DOTFILES_DIR" pull origin main || true
fi

# 作業ディレクトリを ~/.dotfiles に移動
cd "$DOTFILES_DIR"

echo "==> 2. パッケージのインストール状況を確認しています..."

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

echo "==> 3. GNU Stowでシンボリックリンクを作成します..."

# Stowが既存のディレクトリと競合するのを防ぐため、あらかじめディレクトリを作成
mkdir -p "$HOME/.config/micro"

# stowコマンドを実行
stow -v -d "$DOTFILES_DIR" -t "$HOME" sqlite micro

echo "==> セットアップが完了しました！"
