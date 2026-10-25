#!/usr/bin/env bash
set -eu

REPO_URL="https://github.com/shibatatera/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# 1. 権限（sudo / root）の自動判定
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO="sudo"
    else
        echo "エラー: このスクリプトを実行するには root 権限または sudo が必要です。"
        exit 1
    fi
fi

echo "==> 1. 実行環境の確認とパッケージマネージャーの判定を行っています..."

OS_TYPE=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ -f /etc/debian_version ]]; then
    OS_TYPE="debian"
elif [[ -f /etc/fedora-release ]]; then
    OS_TYPE="fedora"
else
    echo "警告: 未対応のOSですが、処理を継続します。"
fi

# 2. git が入っていなければ自動インストール
if ! command -v git &> /dev/null; then
    echo "git が見つからないため、自動インストールします..."
    case "$OS_TYPE" in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "エラー: Homebrewが見つかりません。先にHomebrewをインストールしてください。"
                exit 1
            fi
            brew install git
            ;;
        debian)
            $SUDO apt update && $SUDO apt install -y git
            ;;
        fedora)
            $SUDO dnf install -y git
            ;;
        *)
            echo "エラー: gitを自動インストールできませんでした。手動でインストールしてください。"
            exit 1
            ;;
    esac
fi

echo "==> 2. dotfilesリポジトリの準備をしています..."

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "既存のdotfilesを更新しています..."
    git -C "$DOTFILES_DIR" pull origin main || true
fi

# 作業ディレクトリを ~/.dotfiles に移動
cd "$DOTFILES_DIR"

echo "==> 3. stow, micro, sqlite3 のインストール状況を確認しています..."

case "$OS_TYPE" in
    macos)
        if ! command -v brew &> /dev/null; then
            echo "エラー: Homebrewが見つかりません。"
            exit 1
        fi
        brew install stow micro sqlite3
        ;;
    debian)
        $SUDO apt update
        $SUDO apt install -y stow micro sqlite3
        ;;
    fedora)
        $SUDO dnf install -y stow micro sqlite3
        ;;
    *)
        echo "警告: 自動インストール非対応の環境です。stow, micro, sqlite3 を手動でインストールしてください。"
        ;;
esac

echo "==> 4. GNU Stowでシンボリックリンクを作成します..."

# Stowが既存のディレクトリと競合するのを防ぐため、あらかじめディレクトリを作成
mkdir -p "$HOME/.config/micro"

# stowコマンドを実行
stow -v -d "$DOTFILES_DIR" -t "$HOME" sqlite micro

echo "==> セットアップが完了しました！"
