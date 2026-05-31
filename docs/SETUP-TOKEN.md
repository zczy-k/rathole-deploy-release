# 配置 GitHub Actions Secret

## 问题

工作流失败，错误信息：
```
remote: Permission to zczy-k/rathole-deploy-release.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/zczy-k/rathole-deploy-release.git/': The requested URL returned error: 403
```

## 原因

`PUBLIC_REPO_TOKEN` Secret 未配置或权限不足。

---

## 解决方案

### 步骤 1：创建 Personal Access Token

1. 登录 GitHub
2. 点击右上角头像 → `Settings`
3. 左侧菜单最底部 → `Developer settings`
4. 左侧菜单 → `Personal access tokens` → `Tokens (classic)`
5. 点击 `Generate new token` → `Generate new token (classic)`

### 步骤 2：配置 Token

**Token 名称**：`rathole-deploy-sync`

**Expiration（过期时间）**：
- 选择 `No expiration`（不过期）
- 或选择 `Custom` 设置较长时间（如 1 年）

**Select scopes（选择权限）**：
- ✅ 勾选 `repo`（完整仓库访问权限）
  - 这会自动勾选所有子选项：
    - `repo:status`
    - `repo_deployment`
    - `public_repo`
    - `repo:invite`
    - `security_events`

**重要**：只需要勾选 `repo`，其他权限不需要！

### 步骤 3：生成并复制 Token

1. 滚动到页面底部
2. 点击绿色按钮 `Generate token`
3. **立即复制 Token**（只显示一次！）
   - Token 格式：`ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - 长度：约 40 个字符

### 步骤 4：添加 Secret 到私有仓库

1. 进入私有仓库：https://github.com/zczy-k/rathole-deploy
2. 点击 `Settings` 标签
3. 左侧菜单 → `Secrets and variables` → `Actions`
4. 点击 `New repository secret`
5. 填写信息：
   - **Name**：`PUBLIC_REPO_TOKEN`（必须完全一致）
   - **Secret**：粘贴刚才复制的 Token
6. 点击 `Add secret`

### 步骤 5：验证配置

1. 进入 `Actions` 标签
2. 选择 `Sync to Public Repository` 工作流
3. 点击 `Run workflow`
4. 选择 `main` 分支
5. 点击绿色的 `Run workflow` 按钮
6. 等待工作流执行完成
7. 检查是否成功（绿色勾号）

---

## 验证 Token 是否有效

可以使用以下命令测试 Token：

```bash
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

如果返回你的用户信息，说明 Token 有效。

---

## 常见问题

### Q1: Token 已配置，但仍然失败

**可能原因**：
1. Token 权限不足（没有勾选 `repo`）
2. Token 已过期
3. Secret 名称不正确（必须是 `PUBLIC_REPO_TOKEN`）

**解决方法**：
1. 重新生成 Token，确保勾选 `repo` 权限
2. 检查 Token 是否过期
3. 删除旧 Secret，重新添加

### Q2: 如何删除和重新添加 Secret

1. 进入 `Settings` → `Secrets and variables` → `Actions`
2. 找到 `PUBLIC_REPO_TOKEN`
3. 点击右侧的 `Remove`
4. 确认删除
5. 重新添加新的 Secret

### Q3: Token 泄露了怎么办

1. 立即进入 `Settings` → `Developer settings` → `Personal access tokens`
2. 找到泄露的 Token
3. 点击 `Delete`
4. 重新生成新的 Token
5. 更新仓库中的 Secret

---

## 安全建议

1. **不要将 Token 提交到代码中**
2. **不要在日志中打印 Token**
3. **定期更换 Token**（建议每 6-12 个月）
4. **使用最小权限原则**（只勾选必需的权限）
5. **Token 泄露后立即删除**

---

## 配置完成后

配置完成后，工作流会自动工作：

### 自动触发
```bash
git push origin main
# ✅ 自动同步到公开仓库
```

### 手动触发
1. 进入 `Actions` 标签
2. 选择 `Sync to Public Repository`
3. 点击 `Run workflow`
4. 点击绿色的 `Run workflow` 按钮

---

## 检查清单

配置前请确认：

- [ ] 已创建 Personal Access Token
- [ ] Token 权限包含 `repo`
- [ ] Token 已复制（只显示一次）
- [ ] 已在私有仓库添加 Secret
- [ ] Secret 名称为 `PUBLIC_REPO_TOKEN`
- [ ] Secret 值为完整的 Token
- [ ] 已测试工作流是否成功

---

## 需要帮助？

如果按照以上步骤操作后仍然失败，请：

1. 检查工作流日志
2. 确认 Secret 名称和值
3. 重新生成 Token
4. 提交 Issue 并附上错误日志（注意隐藏敏感信息）
