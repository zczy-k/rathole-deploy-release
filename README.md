# Rathole + Nginx Stream 飞牛 NAS 安全穿透部署工具

这是一个面向 **飞牛 NAS / FnOS** 的内网穿透部署版本，配合 VPS 公网入口使用。
公开仓库仅提供安装脚本和编译后的二进制文件。

## 这个项目是做什么的

- 在 **VPS** 上部署 Rathole 服务端、Nginx Stream 和 SNI 白名单
- 在 **飞牛 NAS** 上部署 Rathole 客户端和 HTTPS 网关
- 支持证书管理、端口修改、诊断修复和卸载

## 适用场景

适合把飞牛 NAS 上的服务通过域名安全映射到公网访问。

## 安装方式

```bash
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

安装完成后，执行 `rathole-deploy`，按菜单提示选择对应功能即可。

## Releases

你也可以直接前往 GitHub Releases 下载对应架构的编译产物。
