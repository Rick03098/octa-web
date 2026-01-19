# OCTA Web 同事部署指南

## 快速开始（5分钟）

### 1. 下载代码

```bash
git clone https://github.com/Rick03098/octa-web.git
cd octa-web
```

### 2. 安装依赖

```bash
npm install
```

### 3. 启动开发服务器

```bash
npm run dev
```

服务器启动后会显示：
- **本地访问**: http://localhost:5173
- **手机访问**: http://[你的IP]:5173（同一WiFi下）

---

## 如何检验是否有 Bug

### 方法一：构建检查（推荐）

```bash
npm run build
```

如果构建成功（显示 `✓ built in X.XXs`），说明代码没有语法错误。

### 方法二：类型检查

```bash
npx tsc --noEmit
```

检查 TypeScript 类型错误。

### 方法三：代码检查

```bash
npm run lint
```

检查代码风格问题。

---

## 常见问题解决

### 问题1：`npm install` 失败

```bash
# 清除缓存后重试
rm -rf node_modules package-lock.json
npm install
```

### 问题2：端口被占用

```bash
# 使用不同端口启动
npm run dev -- --port 3000
```

### 问题3：手机无法访问

1. 确保手机和电脑在同一 WiFi
2. 检查电脑防火墙是否阻止了端口访问
3. 使用 `npm run dev -- --host` 确保监听所有网络接口

### 问题4：字体不显示

检查网络是否能访问 Google Fonts（fonts.googleapis.com）

---

## 生产部署

### 构建生产版本

```bash
npm run build
```

生成的文件在 `dist/` 目录。

### 部署到服务器

将 `dist/` 目录上传到任意静态文件服务器（Nginx、Apache、Vercel、Netlify 等）。

### Vercel 一键部署（最简单）

1. 访问 https://vercel.com
2. 导入 GitHub 仓库
3. 点击 Deploy

---

## 版本信息

- **最新提交**: feat(octa-web): 完善移动端体验和修复构建问题
- **主要更新**:
  - 修复移动端字体加载问题
  - 修复对话框溢出问题
  - 修复移动端布局宽度问题
  - 添加 UnifiedWheelPicker 组件

## 遇到问题？

如果遇到其他问题，请先运行 `npm run build` 检查是否有错误，然后将错误信息发给我。
