#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

BINARY_URL="https://github.com/zczy-k/rathole-deploy-release/releases/latest/download/rathole-deploy-linux-${ARCH}"
TMPFILE=$(mktemp)

cleanup() {
    rm -f "$TMPFILE"
}
trap cleanup EXIT

echo "正在下载 rathole-deploy (linux-${ARCH})..."
curl -fsSL "$BINARY_URL" -o "$TMPFILE"
chmod +x "$TMPFILE"
"$TMPFILE"
