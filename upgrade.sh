#!/usr/bin/env bash
# 智能升级脚本 - 保留配置，仅更新代码
# 公开版本，放置在 rathole-deploy-release 仓库

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}>>>${NC} $*"; }
ok() { echo -e "${GREEN}OK:${NC} $*"; }
warn() { echo -e "${YELLOW}WARN:${NC} $*"; }
fail() { echo -e "${RED}ERROR:${NC} $*"; }

echo "=========================================="
echo "  Rathole Deploy 智能升级"
echo "=========================================="
echo

if [ "${EUID}" -ne 0 ]; then
    fail "请使用 root 权限运行：sudo $0"
    exit 1
fi

# 备份当前版本
BACKUP_DIR="/var/lib/rathole-feiniu-deploy/backup/upgrade-$(date +%Y%m%d%H%M%S)"
info "备份当前配置到 $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

[ -f /etc/rathole/server.toml ] && cp /etc/rathole/server.toml "$BACKUP_DIR/"
[ -f /etc/rathole/client.toml ] && cp /etc/rathole/client.toml "$BACKUP_DIR/"
[ -d /etc/nginx/rathole-feiniu-streams ] && cp -r /etc/nginx/rathole-feiniu-streams "$BACKUP_DIR/"
[ -f /var/lib/rathole-feiniu-deploy/state.conf ] && cp /var/lib/rathole-feiniu-deploy/state.conf "$BACKUP_DIR/"

ok "配置已备份"

# 检测当前部署方式
if systemctl list-units --type=service 2>/dev/null | grep -q rathole-server; then
    DEPLOY_TYPE="vps"
    info "检测到 VPS 端部署"
elif docker ps --format '{{.Names}}' 2>/dev/null | grep -q rathole-client; then
    DEPLOY_TYPE="fnos"
    info "检测到飞牛 NAS 端部署"
else
    warn "未检测到已有部署，请先运行安装脚本"
    echo "安装命令："
    echo "  curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash"
    exit 1
fi

# 停止服务
info "临时停止服务..."
if [ "$DEPLOY_TYPE" = "vps" ]; then
    systemctl stop rathole-server 2>/dev/null || true
    systemctl stop nginx 2>/dev/null || true
elif [ "$DEPLOY_TYPE" = "fnos" ]; then
    docker stop rathole-client 2>/dev/null || true
fi
ok "服务已停止"

# 下载最新二进制
info "下载最新版本..."
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) fail "不支持的架构: $ARCH"; exit 1 ;;
esac

BINARY_PATH="github.com/zczy-k/rathole-deploy-release/releases/latest/download/rathole-deploy-linux-${ARCH}"
DOWNLOAD_URLS=(
    "https://gh-proxy.com/${BINARY_PATH}"
    "https://ghproxy.vip/${BINARY_PATH}"
    "https://${BINARY_PATH}"
)

TMPFILE=$(mktemp)
DOWNLOAD_SUCCESS=false

for url in "${DOWNLOAD_URLS[@]}"; do
    info "尝试: $url"
    if curl -fL --connect-timeout 10 --retry 2 --retry-delay 1 "$url" -o "$TMPFILE" 2>/dev/null; then
        DOWNLOAD_SUCCESS=true
        break
    fi
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    fail "下载失败，升级中止"
    [ "$DEPLOY_TYPE" = "vps" ] && systemctl start rathole-server nginx
    [ "$DEPLOY_TYPE" = "fnos" ] && docker start rathole-client
    exit 1
fi

chmod +x "$TMPFILE"
ok "最新版本已下载"

# 更新二进制
info "更新程序文件..."
[ -f /usr/local/bin/rathole-deploy ] && cp /usr/local/bin/rathole-deploy "$BACKUP_DIR/rathole-deploy.old"
mv "$TMPFILE" /usr/local/bin/rathole-deploy
ok "程序已更新"

# 启动服务
info "重新启动服务..."
if [ "$DEPLOY_TYPE" = "vps" ]; then
    systemctl start rathole-server
    systemctl start nginx
    sleep 2
    if systemctl is-active --quiet rathole-server && systemctl is-active --quiet nginx; then
        ok "VPS 服务已启动"
    else
        fail "服务启动失败"
    fi
elif [ "$DEPLOY_TYPE" = "fnos" ]; then
    docker start rathole-client
    sleep 2
    if docker ps | grep -q rathole-client; then
        ok "飞牛 NAS 服务已启动"
    else
        fail "服务启动失败"
    fi
fi

echo
echo "=========================================="
echo -e "${GREEN}升级完成！${NC}"
echo "=========================================="
echo
echo "✅ 程序已更新到最新版本"
echo "✅ 配置已保留（Token、端口、域名）"
echo "✅ 服务已重启"
echo
echo "备份位置："
echo "  $BACKUP_DIR"
echo
echo "如需回滚："
echo "  sudo mv $BACKUP_DIR/rathole-deploy.old /usr/local/bin/rathole-deploy"
echo "  sudo systemctl restart rathole-server nginx"
