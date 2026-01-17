# 分享给同事后出现的问题诊断与解决方案

## ✅ 修复状态

**已修复** - 2025-01-XX

- ✅ 所有图片路径已从 `localhost:3845` 改为 `public/images/` 相对路径
- ✅ 滚轮组件已添加硬件加速和性能优化
- ✅ 移除了对 `convertLocalhostUrl` 的依赖

**重要提醒**：现在需要将图片文件放入 `public/images/` 目录，详见下方说明。

## 问题概述

根据 GitHub 仓库 [Rick03098/octa-web](https://github.com/Rick03098/octa-web) 的检查，发现两个主要问题：

1. **部分照片没有加载出来** ✅ 已修复
2. **滚轮组件无法流畅运行** ✅ 已修复

---

## 问题 1：图片加载失败

### 根本原因

代码中有 **8 个文件** 使用了硬编码的 `localhost:3845` 路径来加载图片：

```
http://localhost:3845/assets/xxx.png
```

这些图片路径依赖外部的 **Figma MCP 服务器**（运行在 `localhost:3845`）。当同事：
- 没有运行 Figma MCP 服务器
- 在不同的机器上访问时
- 无法访问 `localhost:3845` 时

图片就无法加载。

### 受影响的文件

1. `src/features/Chat/ChatView.tsx`
2. `src/features/ChatIntro/ChatIntroView.tsx`
3. `src/features/Tutorial/TutorialView.tsx`
4. `src/features/Preview/PreviewView.tsx`
5. `src/features/MainDashboard/MainDashboardView.tsx`
6. `src/features/Report/ReportView.tsx`
7. `src/features/Capture/CaptureView.tsx`
8. `src/utils/imageUtils.ts`（工具函数）

### 涉及的图片资源

根据代码分析，以下图片需要处理：

- `e503f988099e962c10dd595d7fb80340d7487ce9.png` - 聊天背景图（多处使用）
- `b4eb843683aafc4dd42a29a982a4295167ad755a.png` - 教程插图
- `708-17842.png` - 预览图
- `8c1d33aa4d06566d5842aed8fc0fd8a8ea89fd7.png` - 拍摄图

---

## 问题 2：滚轮组件不流畅

### 可能的原因

滚轮组件的代码逻辑看起来正确，但可能受到以下因素影响：

1. **CSS 样式未正确加载**：`scrollbar-hide` 类可能在某些环境下失效
2. **性能问题**：频繁的 `onScroll` 事件可能导致卡顿
3. **触摸事件冲突**：移动端触摸事件处理可能有冲突
4. **CSS 变量缺失**：如果 `styles/variables.css` 未正确加载，样式可能异常

### 检查点

- ✅ `scrollbar-hide` 类已在 `src/index.css` 中定义
- ✅ 滚轮组件的 CSS Modules 文件存在（`StringWheelPicker.module.css`, `DateWheelPicker.module.css`）
- ⚠️ 需要确认 `-webkit-overflow-scrolling: touch` 在目标浏览器上是否正常工作

---

## 解决方案

### 方案 1：将图片迁移到 `public` 目录（推荐）

**优点**：
- ✅ 图片随项目一起分发，不依赖外部服务
- ✅ 同事可以直接使用，无需额外配置
- ✅ 部署时也能正常访问

**步骤**：

1. **下载图片并放置到 `public` 目录**：
   ```bash
   # 创建图片目录
   mkdir -p octa-web/public/images
   
   # 将图片文件放入：
   # - public/images/e503f988099e962c10dd595d7fb80340d7487ce9.png
   # - public/images/b4eb843683aafc4dd42a29a982a4295167ad755a.png
   # - public/images/708-17842.png
   # - public/images/8c1d33aa4d06566d5842aed8fc0fd8a8ea89fd7.png
   ```

2. **修改代码使用相对路径**：
   
   将所有的：
   ```typescript
   convertLocalhostUrl("http://localhost:3845/assets/xxx.png")
   ```
   
   改为：
   ```typescript
   "/images/xxx.png"
   ```

3. **更新 `imageUtils.ts`（可选）**：
   
   保留 `convertLocalhostUrl` 函数作为兼容处理，但默认使用相对路径。

### 方案 2：使用占位符图片（临时方案）

如果暂时无法获取原始图片，可以使用占位符：

1. 创建简单的占位符图片（纯色或渐变背景）
2. 放置在 `public/images/placeholders/` 目录
3. 在图片加载失败时使用 `onError` 回调显示占位符

### 方案 3：改进滚轮组件性能

1. **使用节流（throttle）优化 `onScroll` 事件**：
   ```typescript
   import { throttle } from 'lodash';
   
   const handleScroll = throttle(() => {
     // 滚动处理逻辑
   }, 16); // 约 60fps
   ```

2. **使用 `requestAnimationFrame` 优化滚动**：
   ```typescript
   const handleScroll = () => {
     requestAnimationFrame(() => {
       // 滚动处理逻辑
     });
   };
   ```

3. **添加 CSS 硬件加速**：
   ```css
   .scrollContainer {
     transform: translateZ(0); /* 启用硬件加速 */
     will-change: scroll-position;
   }
   ```

---

## 立即修复步骤

### 第一步：确认图片文件是否已在仓库中

检查 GitHub 仓库是否包含 `public/images/` 目录和图片文件。

### 第二步：下载缺失的图片

如果图片不在仓库中，需要：
1. 从 Figma MCP 服务器（`localhost:3845`）下载图片
2. 或者从 Figma 设计文件直接导出

### 第三步：修改代码路径

批量替换所有 `localhost:3845` 路径为相对路径。

### 第四步：测试

1. 在本地测试图片加载是否正常
2. 在同事的机器上测试
3. 确保构建后的 `dist` 目录也包含图片

---

## 预防措施

### 1. 创建图片资源清单

在 `README.md` 或单独文档中列出所有图片资源及其来源。

### 2. 添加到 `.gitignore` 例外

确保 `public/images/` 目录中的图片文件被 Git 跟踪（不要忽略）。

### 3. 在构建脚本中验证

在 `package.json` 中添加构建前检查脚本，验证所有图片文件是否存在。

### 4. 文档化图片依赖

在项目文档中明确说明：
- 哪些图片是必需的
- 图片的获取方式
- 图片的放置位置

---

## 检查清单

分享项目前，请确认：

- [ ] 所有图片文件已放置在 `public/images/` 目录
- [ ] 代码中不再有硬编码的 `localhost:3845` 路径
- [ ] `.gitignore` 不会忽略 `public/images/` 目录
- [ ] GitHub 仓库包含所有图片文件
- [ ] `npm run build` 后，`dist/images/` 目录包含所有图片
- [ ] 在无网络环境下测试项目，图片仍能正常加载

---

## 需要帮助？

如果遇到问题，可以：

1. 查看项目 `README.md`
2. 检查 `DEPLOYMENT_GUIDE.md` 中的图片资源部分
3. 联系项目维护者
