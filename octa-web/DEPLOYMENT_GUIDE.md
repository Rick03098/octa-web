# 前端部署指南 - 让别人直接体验

有几种方式可以让别人直接体验前端，无需本地安装。

## 方案一：Vercel 部署（推荐，最简单快速）

### 优势
- ✅ 完全免费
- ✅ 5分钟内完成部署
- ✅ 自动提供 HTTPS 链接
- ✅ 支持 Git 自动部署
- ✅ 全球 CDN 加速

### 步骤

1. **访问 Vercel**
   - 打开 https://vercel.com
   - 使用 GitHub 账号登录（或注册）

2. **导入项目**
   - 点击 "Add New..." → "Project"
   - 选择你的 GitHub 仓库（如果有）
   - 或者直接拖拽 `octa-web` 文件夹

3. **配置项目**
   - **Framework Preset**: Vite
   - **Root Directory**: `octa-web`（如果是整个仓库，需要设置子目录）
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`

4. **部署**
   - 点击 "Deploy"
   - 等待 2-3 分钟
   - 获得一个类似 `https://your-project.vercel.app` 的链接

5. **分享链接**
   - 将这个链接发给其他人
   - 他们可以直接在浏览器中打开体验

### 项目配置文件（可选）

创建 `vercel.json` 让部署更简单：

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite"
}
```

---

## 方案二：Netlify 部署

### 步骤

1. **访问 Netlify**
   - 打开 https://www.netlify.com
   - 使用 GitHub 账号登录

2. **拖拽部署**
   - 先构建项目：`npm run build`
   - 将 `dist` 文件夹拖拽到 Netlify 页面
   - 立即获得预览链接

3. **Git 部署（推荐）**
   - 连接 GitHub 仓库
   - 设置构建命令：`npm run build`
   - 设置发布目录：`dist`

---

## 方案三：GitHub Pages（免费但需要 Git）

### 步骤

1. **构建项目**
   ```bash
   cd octa-web
   npm run build
   ```

2. **配置 vite.config.ts**
   ```typescript
   export default defineConfig({
     base: '/your-repo-name/', // 如果你的仓库名是 octa-web，则改为 '/octa-web/'
     // ... 其他配置
   })
   ```

3. **推送 dist 到 gh-pages 分支**
   ```bash
   npm install -g gh-pages
   gh-pages -d dist
   ```

4. **启用 GitHub Pages**
   - 在 GitHub 仓库设置中启用 Pages
   - 选择 `gh-pages` 分支
   - 获得链接：`https://your-username.github.io/your-repo-name/`

---

## 方案四：StackBlitz（最快体验，无需部署）

### 步骤

1. **访问 StackBlitz**
   - 打开 https://stackblitz.com
   - 点击 "Create" → "Import from GitHub"

2. **导入项目**
   - 输入 GitHub 仓库 URL
   - 或者直接上传压缩包

3. **分享链接**
   - StackBlitz 会自动提供一个可分享的链接
   - 其他人点击链接即可直接在浏览器中运行

---

## 方案五：本地网络分享（临时体验）

### 适用场景
- 只给同一网络的人体验
- 快速演示

### 步骤

1. **启动开发服务器**
   ```bash
   cd octa-web
   npm run dev -- --host
   ```

2. **查看本机 IP**
   ```bash
   # Mac/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # 或者
   ipconfig getifaddr en0
   ```

3. **分享链接**
   - 你会看到类似：`http://192.168.1.100:5173`
   - 将这个链接发给同一 WiFi 网络的人
   - 他们可以直接访问体验

---

## 推荐方案对比

| 方案 | 难度 | 速度 | 适用场景 |
|------|------|------|----------|
| **Vercel** | ⭐ 简单 | ⭐⭐⭐ 很快 | **最佳选择**，适合正式分享 |
| Netlify | ⭐ 简单 | ⭐⭐⭐ 很快 | 类似 Vercel，备选方案 |
| GitHub Pages | ⭐⭐ 中等 | ⭐⭐ 中等 | 已有 GitHub 仓库时使用 |
| StackBlitz | ⭐ 简单 | ⭐⭐⭐ 很快 | 快速演示和开发 |
| 本地网络 | ⭐⭐⭐ 复杂 | ⭐⭐⭐ 最快 | 临时、同网络演示 |

---

## 最快上手：使用 Vercel（5分钟）

### 详细步骤

1. **准备构建**
   ```bash
   cd octa-web
   npm run build
   ```
   确认 `dist` 文件夹生成成功

2. **访问 Vercel**
   - https://vercel.com/new
   - 登录（GitHub/Google/GitLab）

3. **拖拽部署**
   - 直接将 `dist` 文件夹拖到页面
   - 或者导入整个 `octa-web` 文件夹
   - Vercel 会自动检测 Vite 项目

4. **获得链接**
   - 部署完成后获得：`https://octa-web-xxx.vercel.app`
   - 这个链接可以发给任何人

5. **自定义域名（可选）**
   - 在项目设置中可以添加自定义域名

---

## 注意事项

### 环境变量
如果项目使用了环境变量，需要在部署平台设置：
- Vercel: Project Settings → Environment Variables
- Netlify: Site Settings → Environment Variables

### API 地址
如果前端需要连接后端 API：
- 开发环境：`http://localhost:8000`
- 生产环境：需要设置为实际的 API 地址

### 图片资源
- 部分图片使用了 `localhost:3845`，部署后可能无法访问
- 需要将图片资源上传到 CDN 或静态资源服务

---

## 推荐流程

**第一次部署**：
1. 使用 Vercel 快速部署（5分钟）
2. 获得可分享的链接
3. 发给团队成员体验

**后续更新**：
1. 如果连接了 Git 仓库，推送代码后自动部署
2. 或者重新拖拽新的 `dist` 文件夹

---

## 需要帮助？

如果遇到问题，可以：
1. 查看 Vercel 文档：https://vercel.com/docs
2. 查看项目 README.md
3. 联系团队技术支持


