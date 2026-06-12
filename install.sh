#!/usr/bin/env bash
# Rathole Deploy 一键启动脚本
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}>>>${NC} $*"; }
ok() { echo -e "${GREEN}OK:${NC} $*"; }
err() { echo -e "${RED}错误：${NC}$*" >&2; }

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

BINARY_NAME="rathole-deploy-linux-${ARCH}"
BINARY_PATH="github.com/zczy-k/rathole-deploy-release/releases/latest/download/${BINARY_NAME}"
DOWNLOAD_URLS=(
    "https://gh-proxy.com/${BINARY_PATH}"
    "https://ghproxy.vip/${BINARY_PATH}"
    "https://gh.ddlc.top/${BINARY_PATH}"
    "https://ghfast.top/${BINARY_PATH}"
    "https://${BINARY_PATH}"
)

# 直接下载地址（用于获取 .sha256 文件）
DIRECT_BASE="https://github.com/zczy-k/rathole-deploy-release/releases/latest/download"

download_binary() {
    local tmpfile="$1"
    local sha_file="$2"

    # 先下载 SHA256 校验文件
    info "下载校验文件..."
    if ! curl -fsSL --connect-timeout 10 --retry 2 "${DIRECT_BASE}/${BINARY_NAME}.sha256" -o "$sha_file" 2>/dev/null; then
        err "无法下载校验文件，跳过完整性校验"
        rm -f "$sha_file"
    else
        ok "校验文件下载成功"
    fi

    # 依次尝试各下载源
    for url in "${DOWNLOAD_URLS[@]}"; do
        info "尝试: $url"
        if curl -fL --connect-timeout 10 --retry 2 --retry-delay 1 "$url" -o "$tmpfile" 2>/dev/null; then
            ok "下载成功"

            # 若有校验文件，进行 SHA256 验证
            if [ -f "$sha_file" ] && [ -s "$sha_file" ]; then
                info "校验文件完整性..."
                expected_hash=$(awk '{print $1}' "$sha_file")
                actual_hash=$(sha256sum "$tmpfile" | awk '{print $1}')
                if [ "$expected_hash" = "$actual_hash" ]; then
                    ok "SHA256 校验通过"
                    return 0
                else
                    err "SHA256 校验失败！文件可能已被篡改"
                    err "期望: $expected_hash"
                    err "实际: $actual_hash"
                    rm -f "$tmpfile"
                    # 继续尝试下一个源
                    continue
                fi
            fi

            return 0
        fi
    done
    return 1
}

TMPFILE=$(mktemp)
SHAFILE=$(mktemp)
trap "rm -f $TMPFILE $SHAFILE" EXIT

info "正在下载 rathole-deploy (linux-${ARCH})..."
if ! download_binary "$TMPFILE" "$SHAFILE"; then
    err "所有下载源都不可用"
    exit 1
fi

chmod +x "$TMPFILE"

# 直接运行，进入主菜单
"$TMPFILE"
