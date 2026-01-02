# GitHub 上传指南 - 前端代码

## 方案一：推送到现有的团队仓库（推荐用于团队协作）

如果你的项目是团队项目，可以直接在当前仓库中提交：

```bash
# 1. 进入项目根目录
cd /Users/wangjianle/OCTA/Code/OCTA

# 2. 创建新分支（推荐）
git checkout -b feat/web-frontend-initial

# 3. 添加前端文件
git add octa-web/

# 4. 提交代码
git commit -m "feat(web): 完成前端基础功能实现

- 实现用户引导流程（姓名、生日、时间、地点、性别输入）
- 实现八字结果展示页面
- 实现报告预览和阅读页面
- 实现对话开启和对话页面
- 实现主界面（添加环境、查看状态）
- 完成所有页面UI设计，像素级还原Figma设计
- 使用CSS Modules和设计令牌系统
- 遵循分形架构守护者规范，所有文件包含IOP注释"

# 5. 推送到远程仓库
git push origin feat/web-frontend-initial

# 6. 在 GitHub 上创建 Pull Request
# 访问：https://github.com/dzhou20/Octa-v1
```

## 方案二：创建新的 GitHub 仓库（推荐用于个人项目）

如果你想在自己的 GitHub 账号下创建独立的仓库：

### 步骤 1：在 GitHub 上创建新仓库

1. 访问 https://github.com/new
2. 仓库名称：`octa-web-frontend`（或你喜欢的名字）
3. 描述：`OCTA 前端项目 - React + TypeScript + Vite`
4. 选择 **Public** 或 **Private**
5. **不要** 勾选 "Initialize this repository with a README"（因为我们已经有了代码）
6. 点击 "Create repository"

### 步骤 2：添加文件并提交

```bash
# 1. 进入项目根目录
cd /Users/wangjianle/OCTA/Code/OCTA

# 2. 确保所有前端文件都在 octa-web 目录下
# 检查状态
git status

# 3. 添加前端文件
git add octa-web/

# 4. 提交代码
git commit -m "feat(web): 完成前端基础功能实现

- 实现用户引导流程（姓名、生日、时间、地点、性别输入）
- 实现八字结果展示页面
- 实现报告预览和阅读页面
- 实现对话开启和对话页面
- 实现主界面（添加环境、查看状态）
- 完成所有页面UI设计，像素级还原Figma设计
- 使用CSS Modules和设计令牌系统
- 遵循分形架构守护者规范，所有文件包含IOP注释"

# 5. 添加新的远程仓库（替换 YOUR_REPO_NAME）
# 例如：git remote add mygithub https://github.com/Rick03098/octa-web-frontend.git
git remote add mygithub https://github.com/Rick03098/YOUR_REPO_NAME.git

# 6. 推送到你的 GitHub 仓库
git push mygithub main
```

### 方案 2.1：如果只想上传前端代码到新仓库（更简洁）

如果你想创建一个只包含前端代码的独立仓库：

```bash
# 1. 创建一个新的目录用于前端仓库
cd /Users/wangjianle/OCTA/Code
mkdir octa-web-frontend
cd octa-web-frontend

# 2. 初始化 git
git init

# 3. 复制前端文件（使用 rsync 或 cp）
# 注意：不要复制 .git 目录
rsync -av --exclude='.git' ../OCTA/octa-web/ .

# 或者手动复制文件（更安全）
cp -r ../OCTA/octa-web/* .
cp ../OCTA/octa-web/.gitignore .

# 4. 添加所有文件
git add .

# 5. 提交
git commit -m "feat: 初始前端代码提交

- 完整的 React + TypeScript + Vite 前端项目
- 所有页面UI设计和功能实现
- CSS Modules 和设计令牌系统"

# 6. 添加远程仓库（在 GitHub 创建仓库后）
git remote add origin https://github.com/Rick03098/YOUR_REPO_NAME.git

# 7. 推送
git branch -M main
git push -u origin main
```

## 快速检查清单

在提交前，确保：

- [ ] `.gitignore` 已配置（排除 `node_modules`、`dist` 等）
- [ ] 没有敏感信息（API keys、密码等）
- [ ] 代码已通过 lint 检查
- [ ] README.md 文档完整
- [ ] 所有必要的配置文件都已包含

## 常用命令

```bash
# 查看当前状态
git status

# 查看改动
git diff

# 查看远程仓库
git remote -v

# 移除远程仓库（如果需要）
git remote remove mygithub

# 查看提交历史
git log --oneline
```

## 需要帮助？

如果遇到问题：

1. **权限错误**：确保 GitHub 账号已配置 SSH keys 或使用 Personal Access Token
2. **冲突**：如果与现有代码有冲突，先拉取最新代码 `git pull origin main`
3. **大文件**：如果文件太大，考虑使用 Git LFS 或排除不必要的大文件

## 推荐的工作流

对于团队项目：
1. 创建功能分支 `feat/web-frontend-initial`
2. 提交代码
3. 创建 Pull Request
4. 代码审查后合并到 main

对于个人项目：
1. 创建独立的前端仓库
2. 直接推送到 main 分支
3. 后续通过分支进行功能开发

