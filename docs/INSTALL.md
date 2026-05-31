# 🚀 国内加速安装指南

## 方法 1：自动选择最快镜像（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

脚本会自动尝试以下镜像源（按优先级）：
1. GitHub 官方源
2. ghproxy.com（推荐）
3. mirror.ghproxy.com
4. gh.api.99988866.xyz
5. github.moeyy.xyz

---

## 方法 2：手动指定镜像源

### 使用 ghproxy（推荐）

```bash
# 下载 AMD64
wget https://ghproxy.com/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64

# 或使用 curl
curl -fsSL https://ghproxy.com/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy

# 安装
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
sudo rathole-deploy
```

### 使用 mirror.ghproxy.com

```bash
curl -fsSL https://mirror.ghproxy.com/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
```

### 使用 99988866

```bash
curl -fsSL https://gh.api.99988866.xyz/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
```

### 使用 moeyy

```bash
curl -fsSL https://github.moeyy.xyz/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
```

---

## 方法 3：使用 Gitee 镜像（待配置）

如果 GitHub 镜像都无法访问，可以使用 Gitee：

```bash
# 需要先将 Release 同步到 Gitee
curl -fsSL https://gitee.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
```

---

## 方法 4：使用代理

### 使用 HTTP 代理

```bash
export http_proxy=http://your-proxy:port
export https_proxy=http://your-proxy:port
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

### 使用 SOCKS5 代理

```bash
curl -x socks5h://127.0.0.1:1080 -fsSL https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64 -o rathole-deploy
chmod +x rathole-deploy
sudo mv rathole-deploy /usr/local/bin/
```

---

## 方法 5：直接下载到本地再上传

### 步骤 1：在能访问 GitHub 的环境下载

访问：https://github.com/zczy-k/rathole-deploy-release/releases

下载对应架构的文件：
- `rathole-deploy-linux-amd64`（x86_64）
- `rathole-deploy-linux-arm64`（ARM64）

### 步骤 2：上传到服务器

```bash
# 使用 scp
scp rathole-deploy-linux-amd64 root@your-server:/tmp/

# 或使用 SFTP、FTP 等工具上传
```

### 步骤 3：安装

```bash
ssh root@your-server
chmod +x /tmp/rathole-deploy-linux-amd64
sudo mv /tmp/rathole-deploy-linux-amd64 /usr/local/bin/rathole-deploy
sudo rathole-deploy
```

---

## 常用镜像源对比

| 镜像源 | 地址 | 速度 | 稳定性 | 推荐度 |
|--------|------|------|--------|--------|
| ghproxy.com | https://ghproxy.com | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ 推荐 |
| mirror.ghproxy.com | https://mirror.ghproxy.com | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ 推荐 |
| 99988866 | https://gh.api.99988866.xyz | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ 可用 |
| moeyy | https://github.moeyy.xyz | ⭐⭐⭐ | ⭐⭐⭐ | ✅ 可用 |
| GitHub 官方 | https://github.com | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⚠️ 国内慢 |

---

## 测试镜像源速度

```bash
# 测试 ghproxy
time curl -I https://ghproxy.com/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64

# 测试 mirror.ghproxy
time curl -I https://mirror.ghproxy.com/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64

# 测试 99988866
time curl -I https://gh.api.99988866.xyz/https://github.com/zczy-k/rathole-deploy-release/releases/download/v0.1.0-beta/rathole-deploy-linux-amd64
```

---

## 常见问题

### Q1: 所有镜像都无法访问？

**解决方案**：
1. 检查网络连接
2. 尝试使用代理
3. 使用方法 5（直接下载再上传）

### Q2: 下载速度很慢？

**解决方案**：
1. 尝试不同的镜像源
2. 使用 `wget` 代替 `curl`
3. 使用多线程下载工具（如 `aria2c`）

### Q3: 镜像源返回 404？

**解决方案**：
1. 确认版本号正确（当前为 `v0.1.0-beta`）
2. 尝试其他镜像源
3. 访问 Release 页面确认文件存在

---

## 推荐配置

### 飞牛 NAS 用户

```bash
# 推荐使用 ghproxy
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

### VPS 用户（国内）

```bash
# 自动选择最快镜像
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

### VPS 用户（国外）

```bash
# 直接使用官方源
curl -fsSL https://raw.githubusercontent.com/zczy-k/rathole-deploy-release/main/install.sh | sudo bash
```

---

**更新时间**：2026-05-31  
**当前版本**：v0.1.0-beta
