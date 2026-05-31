# GitHub Actions 工作流说明

## 工作流列表

### 1. Release（发布工作流）

**文件**：`.github/workflows/release.yml`

**功能**：编译 Go 代码并发布到公开仓库

**触发方式**：

#### 方式 1：推送 Tag（自动触发）
```bash
git tag v1.0.0
git push origin v1.0.0
```

#### 方式 2：手动触发
1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `Release` 工作流
4. 点击 `Run workflow`
5. 输入版本号（如 `v1.0.0`）
6. 点击 `Run workflow` 按钮

**执行步骤**：
1. ✅ 检出代码
2. ✅ 设置 Go 环境
3. ✅ 编译 Linux AMD64 版本
4. ✅ 编译 Linux ARM64 版本
5. ✅ 生成 SHA256 校验和
6. ✅ 创建 Release 到公开仓库

**输出**：
- `rathole-deploy-linux-amd64`
- `rathole-deploy-linux-amd64.sha256`
- `rathole-deploy-linux-arm64`
- `rathole-deploy-linux-arm64.sha256`

---

### 2. Sync to Public Repository（同步工作流）

**文件**：`.github/workflows/sync.yml`

**功能**：同步代码到公开仓库

**触发方式**：

#### 方式 1：推送到 main 分支（自动触发）
```bash
git push origin main
```

#### 方式 2：手动触发
1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `Sync to Public Repository` 工作流
4. 点击 `Run workflow`
5. 点击 `Run workflow` 按钮

**执行步骤**：
1. ✅ 检出私有仓库代码
2. ✅ 配置 Git 用户信息
3. ✅ 添加公开仓库为远程仓库
4. ✅ 强制推送到公开仓库

---

## 配置要求

### 必需的 Secret

在仓库 `Settings` → `Secrets and variables` → `Actions` 中配置：

**PUBLIC_REPO_TOKEN**
- 类型：Personal Access Token (PAT)
- 权限：`repo`（完整仓库访问权限）
- 用途：推送代码和创建 Release 到公开仓库

#### 创建 Token 步骤：
1. 进入 GitHub `Settings` → `Developer settings` → `Personal access tokens` → `Tokens (classic)`
2. 点击 `Generate new token` → `Generate new token (classic)`
3. 设置名称：`rathole-deploy-sync`
4. 选择权限：勾选 `repo`
5. 点击 `Generate token`
6. 复制 Token（只显示一次）
7. 在私有仓库中添加为 Secret

---

## 使用场景

### 场景 1：日常开发（自动同步）

```bash
# 正常开发流程
git add .
git commit -m "feat: 添加新功能"
git push origin main

# ✅ 自动触发 Sync 工作流
# ✅ 代码自动同步到公开仓库
```

### 场景 2：发布新版本

```bash
# 1. 确保代码已推送
git push origin main

# 2. 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0

# ✅ 自动触发 Release 工作流
# ✅ 编译二进制文件
# ✅ 创建 Release 到公开仓库
```

### 场景 3：手动发布（无需创建 tag）

1. 进入 GitHub Actions
2. 选择 `Release` 工作流
3. 点击 `Run workflow`
4. 输入版本号：`v1.0.0`
5. 点击 `Run workflow`

### 场景 4：手动同步代码

1. 进入 GitHub Actions
2. 选择 `Sync to Public Repository` 工作流
3. 点击 `Run workflow`
4. 点击 `Run workflow`

---

## 工作流状态

### 查看工作流执行状态

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 查看最近的工作流运行记录

### 查看工作流日志

1. 点击具体的工作流运行
2. 点击具体的 Job
3. 查看每个步骤的日志

---

## 故障排查

### Sync 工作流失败

**可能原因**：
1. `PUBLIC_REPO_TOKEN` 未配置或已过期
2. Token 权限不足
3. 公开仓库不存在

**解决方法**：
1. 检查 Secret 配置
2. 重新生成 Token
3. 确认公开仓库存在

### Release 工作流失败

**可能原因**：
1. `PUBLIC_REPO_TOKEN` 未配置或已过期
2. Go 编译失败
3. 版本号格式错误

**解决方法**：
1. 检查 Secret 配置
2. 查看编译日志
3. 确认版本号格式（如 `v1.0.0`）

---

## 公开仓库

**仓库地址**：https://github.com/zczy-k/rathole-deploy-release

**内容**：
- ✅ 完整源代码
- ✅ 编译后的二进制文件（Releases）
- ✅ 文档
- ✅ 安装脚本

---

## 注意事项

1. **私有仓库**：包含所有开发历史和敏感信息
2. **公开仓库**：只包含发布的代码和二进制文件
3. **同步方式**：使用 force push，确保公开仓库与私有仓库完全一致
4. **Token 安全**：不要将 Token 提交到代码中
5. **版本号格式**：必须以 `v` 开头，如 `v1.0.0`

---

## 快速参考

### 发布新版本（推荐）

```bash
# 方式 1：使用 tag（推荐）
git tag v1.0.0
git push origin v1.0.0

# 方式 2：手动触发
# 进入 Actions → Release → Run workflow
```

### 同步代码

```bash
# 方式 1：自动同步（推荐）
git push origin main

# 方式 2：手动触发
# 进入 Actions → Sync to Public Repository → Run workflow
```
