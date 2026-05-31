# 故障排查指南

## VPS 服务端问题

### Rathole 服务无法启动

**症状**：`systemctl status rathole-server` 显示失败

**排查步骤**：

1. 查看日志
```bash
journalctl -u rathole-server -n 50
```

2. 检查配置文件
```bash
cat /etc/rathole/server.toml
```

3. 检查端口占用
```bash
ss -tlnp | grep 52333
```

4. 手动测试
```bash
/usr/local/bin/rathole /etc/rathole/server.toml
```

### Nginx Stream 配置错误

**症状**：`nginx -t` 失败

**排查步骤**：

1. 测试配置
```bash
nginx -t
```

2. 查看配置文件
```bash
cat /etc/nginx/stream.d/rathole.conf
```

3. 检查语法错误
```bash
nginx -T | grep -A 10 "stream {"
```

### SNI 白名单不生效

**症状**：非白名单域名也能访问

**排查步骤**：

1. 检查 Nginx Stream 配置
```bash
cat /etc/nginx/stream.d/rathole.conf
```

2. 确认 map 配置正确
```bash
grep -A 5 "map \$ssl_preread_server_name" /etc/nginx/stream.d/rathole.conf
```

3. 重载 Nginx
```bash
systemctl reload nginx
```

### Fail2ban 不工作

**症状**：恶意 IP 未被封禁

**排查步骤**：

1. 检查 Fail2ban 状态
```bash
systemctl status fail2ban
```

2. 查看 Jail 状态
```bash
fail2ban-client status nginx-sni-block
```

3. 查看日志
```bash
tail -f /var/log/fail2ban.log
```

4. 测试 Filter
```bash
fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-sni-block.conf
```

---

## 飞牛客户端问题

### Rathole 客户端无法连接

**症状**：`systemctl status rathole-client` 显示连接失败

**排查步骤**：

1. 查看日志
```bash
journalctl -u rathole-client -n 50
```

2. 检查配置文件
```bash
cat /etc/rathole/client.toml
```

3. 测试 VPS 连接
```bash
telnet VPS_IP 52333
```

4. 检查 Token
```bash
grep token /etc/rathole/client.toml
```

### 本地服务无法访问

**症状**：Rathole 连接正常，但无法访问本地服务

**排查步骤**：

1. 检查本地服务
```bash
curl -k https://127.0.0.1:8001
```

2. 检查客户端配置
```bash
cat /etc/rathole/client.toml
```

3. 查看 Rathole 日志
```bash
journalctl -u rathole-client -f
```

---

## 网络问题

### 无法通过域名访问

**症状**：域名无法访问，但 IP 可以

**排查步骤**：

1. 检查 DNS 解析
```bash
nslookup your-domain
dig your-domain
```

2. 检查防火墙
```bash
# VPS 上
iptables -L -n | grep 54443
ufw status
```

3. 检查端口监听
```bash
ss -tlnp | grep 54443
```

### 连接超时

**症状**：访问超时

**排查步骤**：

1. 检查 VPS 防火墙
```bash
iptables -L -n
ufw status
```

2. 检查云服务商安全组
- 确保开放 54443 端口（或自定义端口）

3. 测试端口连通性
```bash
# 从本地测试
telnet VPS_IP 54443
```

---

## 证书问题

### HTTPS 证书错误

**症状**：浏览器显示证书错误

**排查步骤**：

1. 检查证书文件
```bash
ls -la /etc/rathole-certs/
openssl x509 -in /etc/rathole-certs/fullchain.pem -text -noout
```

2. 检查证书有效期
```bash
openssl x509 -in /etc/rathole-certs/fullchain.pem -noout -dates
```

3. 检查域名匹配
```bash
openssl x509 -in /etc/rathole-certs/fullchain.pem -noout -text | grep DNS
```

### 证书续期失败

**症状**：证书过期

**排查步骤**：

1. 查看续期日志
```bash
cat /var/log/rathole-cert-renew.log
```

2. 手动续期
```bash
/root/.acme.sh/acme.sh --cron --home /root/.acme.sh
```

3. 检查 Cloudflare API Token
```bash
# 测试 Token 是否有效
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 性能问题

### 访问速度慢

**排查步骤**：

1. 检查 VPS 带宽
```bash
iftop
```

2. 检查 Rathole 性能
```bash
top | grep rathole
```

3. 检查 Nginx 连接数
```bash
ss -s
```

### CPU/内存占用高

**排查步骤**：

1. 查看进程资源占用
```bash
top
htop
```

2. 检查 Rathole 日志
```bash
journalctl -u rathole-server -n 100
journalctl -u rathole-client -n 100
```

---

## 日志位置

### VPS 服务端
- Rathole 服务：`journalctl -u rathole-server`
- Nginx：`/var/log/nginx/error.log`
- Fail2ban：`/var/log/fail2ban.log`
- 部署日志：`/var/log/rathole-deploy.log`
- 证书续期：`/var/log/rathole-cert-renew.log`

### 飞牛客户端
- Rathole 客户端：`journalctl -u rathole-client`
- 部署日志：`/var/log/rathole-deploy.log`

---

## 完全重置

如果问题无法解决，可以完全卸载后重新部署：

### VPS
```bash
rathole-deploy
# 选择：6) 卸载 Rathole 服务端
# 然后重新部署
```

### 飞牛
```bash
rathole-deploy
# 选择：5) 卸载 Rathole 客户端
# 然后重新部署
```

---

## 获取帮助

如果以上方法都无法解决问题，请：

1. 收集日志
```bash
# VPS
journalctl -u rathole-server -n 100 > rathole-server.log
journalctl -u nginx -n 100 > nginx.log
cat /var/log/rathole-deploy.log > deploy.log

# 飞牛
journalctl -u rathole-client -n 100 > rathole-client.log
cat /var/log/rathole-deploy.log > deploy.log
```

2. 提交 Issue，附上日志文件
