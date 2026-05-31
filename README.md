# Rathole 飞牛部署工具

> **无公网 IP 设备的 HTTPS 映射解决方案**  
> 基于 Rathole + Nginx SNI 代理 + Let's Encrypt 自动证书

---

## 🚀 快速开始

### 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

安装完成后，直接运行：

```bash
sudo rathole-deploy
```

---

## 📋 功能特性

- ✅ **自动平台检测**：VPS / 飞牛 NAS / 通用模式
- ✅ **交互式菜单**：分类布局，操作简单
- ✅ **一键部署**：Rathole 服务端/客户端自动安装
- ✅ **SSL 证书管理**：Let's Encrypt 自动申请与续期
- ✅ **SNI 白名单**：支持多域名配置
- ✅ **状态监控**：实时查看服务运行状态
- ✅ **安全卸载**：完整清理所有组件

---

## 🏗️ 架构说明

```
用户设备                VPS 服务器              飞牛 NAS
   │                       │                      │
   │  ① HTTPS 请求         │                      │
   │  (your.domain.com)    │                      │
   └──────────────────────>│                      │
                           │                      │
                           │  ② SNI 白名单检查     │
                           │  (Nginx Stream)      │
                           │                      │
                           │  ③ Rathole 隧道      │
                           │<────────────────────>│
                           │   (加密传输)          │
                           │                      │
                           │                      │  ④ 转发到本地服务
                           │                      │  (127.0.0.1:8001)
```

---

## 📦 手动下载

如果无法使用一键安装脚本，可以手动下载：

### Linux AMD64

```bash
wget https://github.com/zczy-k/rathole-deploy/releases/latest/download/rathole-deploy-linux-amd64
chmod +x rathole-deploy-linux-amd64
sudo ./rathole-deploy-linux-amd64
```

### Linux ARM64

```bash
wget https://github.com/zczy-k/rathole-deploy/releases/latest/download/rathole-deploy-linux-arm64
chmod +x rathole-deploy-linux-arm64
sudo ./rathole-deploy-linux-arm64
```

### 校验文件完整性

```bash
wget https://github.com/zczy-k/rathole-deploy/releases/latest/download/rathole-deploy-linux-amd64.sha256
sha256sum -c rathole-deploy-linux-amd64.sha256
```

---

## 🛠️ 使用场景

### VPS 服务端部署

1. 配置域名与 DNS（A 记录指向 VPS IP）
2. 安装 Rathole 服务端
3. 配置 SNI 白名单域名
4. 申请 SSL 证书

### 飞牛 NAS 客户端部署

1. 输入 VPS IP 和连接 Token
2. 安装 Rathole 客户端
3. 配置端口映射
4. 查看连接状态

---

## 📖 常见问题

### 1. 安装失败怎么办？

检查以下几点：
- 是否使用 `sudo` 运行
- 网络是否能访问 GitHub
- 系统架构是否支持（仅支持 Linux AMD64/ARM64）

### 2. 如何更新到最新版本？

重新运行安装命令即可：

```bash
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

### 3. 如何完全卸载？

运行程序后选择"卸载"选项，会自动清理所有组件。

---

## 🔒 安全说明

- 本工具为**编译后的二进制文件**，源代码位于私有仓库
- 所有网络传输均通过 Rathole 加密隧道
- SSL 证书由 Let's Encrypt 官方签发
- 支持 SNI 白名单，防止域名滥用

---

## 📄 开源协议

本项目采用 MIT 协议开源。

---

## 🙋 技术支持

如有问题，请提交 [Issue](https://github.com/zczy-k/rathole-deploy-release/issues)。

---

**注意**：此仓库仅用于发布编译后的二进制文件和文档，不包含源代码。
