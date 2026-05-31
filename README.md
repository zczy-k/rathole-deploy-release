# Rathole 部署工具

#无公网 IP 设备映射方案 - 使用 Rathole 实现内网穿透

## 🚀 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

安装脚本会自动识别 Linux AMD64 / ARM64 平台，并优先使用国内加速下载源，失败后自动切换，最后回退到官方 GitHub 下载链接。

## 📥 手动下载

请前往 [Releases](https://github.com/zczy-k/rathole-deploy-release/releases) 页面下载最新版本。

- Linux AMD64：`rathole-deploy-linux-amd64`
- Linux ARM64：`rathole-deploy-linux-arm64`

## 🚀 使用

```bash
rathole-deploy
```

按照交互式菜单操作即可。

## 📖 文档

- [安装指南](./docs/INSTALL.md)
- [证书管理](./docs/CERT.md)
- [故障排查](./docs/TROUBLESHOOTING.md)

## 📝 许可证

MIT License

## 🔒 源代码

本项目为闭源软件，源代码不公开。
