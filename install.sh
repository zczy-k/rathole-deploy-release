#!/usr/bin/env bash
# Rathole 飞牛部署工具 - 一键安装脚本
# 此脚本从 GitHub Release 下载编译好的二进制文件

set -e

REPO="zczy-k/rathole-deploy"
BINARY_NAME="rathole-deploy"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"

# 检测系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm64" ;;
    *)       echo "❌ 不支持的架构: $ARCH"; exit 1 ;;
esac

# 检测操作系统
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$OS" != "linux" ]; then
    echo "❌ 仅支持 Linux 系统"
    exit 1
fi

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ 请使用 root 权限运行此脚本"
    echo "   sudo $0"
    exit 1
fi

echo "🚀 Rathole 飞牛部署工具 - 安装程序"
echo "   架构: ${OS}-${ARCH}"
echo ""

# 获取最新版本
echo "📡 正在获取最新版本..."
LATEST_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-${OS}-${ARCH}"

# 下载二进制文件
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

echo "⬇️  正在下载 ${BINARY_NAME}-${OS}-${ARCH}..."
if ! curl -fsSL "$LATEST_URL" -o "$TMPFILE"; then
    echo "❌ 下载失败，请检查网络连接或访问："
    echo "   https://github.com/${REPO}/releases"
    exit 1
fi

# 验证文件不为空
if [ ! -s "$TMPFILE" ]; then
    echo "❌ 下载的文件为空"
    exit 1
fi

# 安装二进制文件
echo "📦 正在安装到 ${INSTALL_PATH}..."
chmod +x "$TMPFILE"
mv "$TMPFILE" "$INSTALL_PATH"

# 验证安装
if [ -x "$INSTALL_PATH" ]; then
    echo "✅ 安装成功！"
    echo ""
    echo "🎯 使用方法："
    echo "   sudo ${BINARY_NAME}"
    echo ""

    # 自动运行
    read -p "是否立即运行？[Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        exec "$INSTALL_PATH"
    fi
else
    echo "❌ 安装失败"
    exit 1
fi
