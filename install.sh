#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

BINARY_PATH="github.com/zczy-k/rathole-deploy-release/releases/latest/download/rathole-deploy-linux-${ARCH}"
DOWNLOAD_URLS=(
    "https://gh-proxy.com/${BINARY_PATH}"
    "https://ghproxy.vip/${BINARY_PATH}"
    "https://gh.ddlc.top/${BINARY_PATH}"
    "https://ghfast.top/${BINARY_PATH}"
    "https://${BINARY_PATH}"
)
TMPFILE=$(mktemp)

cleanup() {
    rm -f "$TMPFILE"
}
trap cleanup EXIT

download_binary() {
    for url in "${DOWNLOAD_URLS[@]}"; do
        echo "尝试下载: $url"
        if curl -fL --connect-timeout 10 --retry 2 --retry-delay 1 "$url" -o "$TMPFILE"; then
            echo "下载成功"
            return 0
        fi
        echo "下载失败，切换下一个下载源..."
    done

    echo "错误：所有下载源都不可用"
    return 1
}

echo "正在下载 rathole-deploy (linux-${ARCH})..."
download_binary
chmod +x "$TMPFILE"
"$TMPFILE"
