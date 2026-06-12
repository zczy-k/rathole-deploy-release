#!/usr/bin/env bash
# Rathole Deploy 一键安装/升级脚本
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}>>>${NC} $*"; }
ok() { echo -e "${GREEN}OK:${NC} $*"; }
warn() { echo -e "${YELLOW}WARN:${NC} $*"; }

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

# 检测是否已有部署
EXISTING_DEPLOY=false
if systemctl list-units --type=service 2>/dev/null | grep -q rathole-server; then
    EXISTING_DEPLOY=true
    DEPLOY_TYPE="VPS"
elif docker ps --format '{{.Names}}' 2>/dev/null | grep -q rathole-client; then
    EXISTING_DEPLOY=true
    DEPLOY_TYPE="飞牛 NAS"
fi

echo "=========================================="
echo "  Rathole Deploy 部署工具"
echo "=========================================="
echo

if [ "$EXISTING_DEPLOY" = true ]; then
    warn "检测到已有 $DEPLOY_TYPE 端部署"
    echo
    echo "请选择操作："
    echo "  1) 全新安装（覆盖所有配置，需重新输入 Token）"
    echo "  2) 智能升级（保留配置，仅更新程序）← 推荐"
    echo "  0) 取消"
    echo
    read -p "请选择 [2]: " choice
    choice=${choice:-2}

    case "$choice" in
        1)
            MODE="install"
            warn "将执行全新安装，所有配置将被重置"
            ;;
        2)
            MODE="upgrade"
            info "将执行智能升级，保留现有配置"
            ;;
        0)
            echo "已取消"
            exit 0
            ;;
        *)
            echo "无效选择"
            exit 1
            ;;
    esac
else
    info "未检测到已有部署，将执行全新安装"
    MODE="install"
fi

echo

# 下载最新版本
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

info "正在下载 rathole-deploy (linux-${ARCH})..."
if ! download_binary "$TMPFILE"; then
    echo "错误：所有下载源都不可用"
    exit 1
fi

chmod +x "$TMPFILE"

# 执行操作
if [ "$MODE" = "upgrade" ]; then
    info "开始智能升级..."
    echo

    # 备份配置
    BACKUP_DIR="/var/lib/rathole-feiniu-deploy/backup/upgrade-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    [ -f /etc/rathole/server.toml ] && cp /etc/rathole/server.toml "$BACKUP_DIR/"
    [ -f /etc/rathole/client.toml ] && cp /etc/rathole/client.toml "$BACKUP_DIR/"
    [ -f /var/lib/rathole-feiniu-deploy/state.conf ] && cp /var/lib/rathole-feiniu-deploy/state.conf "$BACKUP_DIR/"
    ok "配置已备份到 $BACKUP_DIR"

    # 停止服务
    info "停止服务..."
    if [ "$DEPLOY_TYPE" = "VPS" ]; then
        systemctl stop rathole-server 2>/dev/null || true
        systemctl stop nginx 2>/dev/null || true
    else
        docker stop rathole-client 2>/dev/null || true
    fi
    ok "服务已停止"

    # 更新程序
    info "更新程序..."
    [ -f /usr/local/bin/rathole-deploy ] && cp /usr/local/bin/rathole-deploy "$BACKUP_DIR/rathole-deploy.old"
    mv "$TMPFILE" /usr/local/bin/rathole-deploy
    ok "程序已更新"

    # 启动服务
    info "重新启动服务..."
    if [ "$DEPLOY_TYPE" = "VPS" ]; then
        systemctl start rathole-server
        systemctl start nginx
        sleep 2
        if systemctl is-active --quiet rathole-server && systemctl is-active --quiet nginx; then
            ok "服务已启动"
        fi
    else
        docker start rathole-client
        sleep 2
        if docker ps | grep -q rathole-client; then
            ok "服务已启动"
        fi
    fi

    echo
    echo "=========================================="
    ok "升级完成！"
    echo "=========================================="
    echo
    echo "✅ 程序已更新到最新版本"
    echo "✅ 配置已保留（Token、端口、域名）"
    echo "✅ 服务已重启"
    echo
    echo "备份位置："
    echo "  $BACKUP_DIR"

else
    # 全新安装
    info "开始全新安装..."
    echo
    "$TMPFILE"
fi
# v2.0.1
