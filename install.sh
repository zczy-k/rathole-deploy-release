#!/usr/bin/env bash
# Rathole Deploy 一键启动脚本
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}>>>${NC} $*"; }
ok() { echo -e "${GREEN}OK:${NC} $*"; }

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

download_binary() {
    local tmpfile="$1"
    for url in "${DOWNLOAD_URLS[@]}"; do
        info "尝试: $url"
        if curl -fL --connect-timeout 10 --retry 2 --retry-delay 1 "$url" -o "$tmpfile" 2>/dev/null; then
            ok "下载成功"
            return 0
        fi
    done
    return 1
}

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

info "正在下载 rathole-deploy (linux-${ARCH})..."
if ! download_binary "$TMPFILE"; then
    echo "错误：所有下载源都不可用"
    exit 1
fi

chmod +x "$TMPFILE"

# 直接运行，进入主菜单
"$TMPFILE"
