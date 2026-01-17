# 推送前端代码到 GitHub 指南

## ✅ 已完成

1. ✅ 已在 `octa-web` 目录下创建独立的 git 仓库
2. ✅ 所有前端代码已提交到本地仓库

## 📝 下一步：在 GitHub 创建仓库并推送

### 步骤 1：在 GitHub 创建新仓库

1. 访问：**https://github.com/new**
2. 登录你的 GitHub 账号（Rick03098）
3. 填写仓库信息：
   - **Repository name**: `octa-web`
   - **Description**: `OCTA 前端项目 - React + TypeScript + Vite`
   - **Public** 或 **Private**（根据你的需要选择）
   - ⚠️ **不要**勾选以下选项：
     - ❌ Add a README file
     - ❌ Add .gitignore（我们已经有了）
     - ❌ Choose a license
4. 点击 **"Create repository"** 按钮

### 步骤 2：告诉我仓库创建完成

创建好仓库后，告诉我，我会执行以下命令：

```bash
# 添加远程仓库
git remote add origin https://github.com/Rick03098/octa-web.git

# 推送代码
git push -u origin main
```

## 🔐 认证方式

推送代码时可能需要认证：

### 方式 1：使用 Personal Access Token（推荐）

1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写 Note：`octa-web project`
4. 选择权限：至少勾选 `repo`
5. 点击 "Generate token"
6. **复制 token**（只显示一次，务必保存）
7. 推送时，密码输入框填入这个 token

### 方式 2：使用 SSH Key

如果已配置 SSH key，可以使用：
```bash
git remote add origin git@github.com:Rick03098/octa-web.git
```

## ⚡ 快速命令（创建好仓库后执行）

```bash
cd /Users/wangjianle/OCTA/Code/OCTA/octa-web

# 添加远程仓库
git remote add origin https://github.com/Rick03098/octa-web.git

# 推送代码
git push -u origin main
```

**创建好仓库后告诉我，我来帮你完成推送！** 🚀


