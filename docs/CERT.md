# SSL 证书管理

## 申请证书

### 1. 准备 Cloudflare API Token

1. 登录 Cloudflare
2. 进入 "My Profile" → "API Tokens"
3. 创建 Token，权限：`Zone - DNS - Edit`
4. 记录 Token

### 2. 部署证书网关

在 VPS 上运行：

```bash
rathole-deploy
```

选择菜单：
- VPS 菜单：选择 `4) 申请 SSL 证书`
- 输入域名（多个域名用空格分隔）
- 输入邮箱
- 输入 Cloudflare API Token
- 输入监听端口（默认：443）
- 输入后端地址（默认：https://127.0.0.1:8001）

### 3. 验证

访问：`https://your-domain:443`

---

## 证书续期

### 自动续期

证书会自动续期，无需手动操作。

系统会在证书到期前自动续期，通过 cron 任务：
- 时间：每天凌晨 3:17
- 日志：`/var/log/rathole-cert-renew.log`

### 手动续期

如需手动续期：

```bash
/root/.acme.sh/acme.sh --cron --home /root/.acme.sh
```

---

## 查看证书

### 查看证书列表

```bash
/root/.acme.sh/acme.sh --list
```

### 查看证书信息

```bash
openssl x509 -in /etc/rathole-certs/fullchain.pem -text -noout
```

---

## 故障排查

### 证书申请失败

1. 检查 Cloudflare API Token 权限
2. 检查域名 DNS 解析
3. 查看日志：`/var/log/rathole-deploy.log`

### 证书续期失败

1. 检查 cron 任务：`cat /etc/cron.d/rathole-cert-renew`
2. 查看续期日志：`cat /var/log/rathole-cert-renew.log`
3. 手动测试续期：`/root/.acme.sh/acme.sh --cron --home /root/.acme.sh`

### HTTPS 访问失败

1. 检查 Nginx 配置：`nginx -t`
2. 检查 Nginx 状态：`systemctl status nginx`
3. 检查证书文件：`ls -la /etc/rathole-certs/`
4. 查看 Nginx 日志：`tail -f /var/log/nginx/error.log`

---

## 卸载

在 VPS 上运行：

```bash
rathole-deploy
```

选择菜单：
- VPS 菜单：选择 `4) 申请 SSL 证书`（如果已部署）
- 然后选择卸载选项

或者手动卸载：

```bash
# 删除 Nginx 配置
rm -f /etc/nginx/conf.d/rathole-gateway.conf
systemctl reload nginx

# 卸载 acme.sh
/root/.acme.sh/acme.sh --uninstall
rm -rf /root/.acme.sh
rm -rf /etc/rathole-certs

# 删除 cron 任务
rm -f /etc/cron.d/rathole-cert-renew
```
