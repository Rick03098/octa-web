# 移动端图片加载修复说明

## 问题描述

在手机上预览网站时，部分图片无法显示，因为代码中使用了 `http://localhost:3845` 作为图片路径。当手机通过局域网 IP（如 `192.168.1.196:5173`）访问时，无法访问电脑上的 `localhost:3845`，导致图片加载失败。

## 解决方案

创建了 `src/utils/imageUtils.ts` 工具函数，自动将 `localhost` 替换为当前访问的 IP 地址，这样手机访问时就能正确加载图片了。

## 修复的文件

以下所有使用图片的组件已更新：

1. ✅ `src/features/Tutorial/TutorialView.tsx` - 教程页面插图
2. ✅ `src/features/Capture/CaptureView.tsx` - 拍摄页面占位图
3. ✅ `src/features/Preview/PreviewView.tsx` - 预览页面背景图
4. ✅ `src/features/MainDashboard/MainDashboardView.tsx` - 主界面环境卡片
5. ✅ `src/features/Report/ReportView.tsx` - 报告页面环境图片
6. ✅ `src/features/ChatIntro/ChatIntroView.tsx` - 对话开启页背景图
7. ✅ `src/features/Chat/ChatView.tsx` - 对话页背景图

## 工作原理

`convertLocalhostUrl` 函数会：
1. 检测当前访问的主机名（`window.location.hostname`）
2. 如果是通过 IP 访问（非 localhost），自动将 URL 中的 `localhost:3845` 替换为 `当前IP:3845`
3. 如果是本地访问，保持原样

## 使用示例

```typescript
import { convertLocalhostUrl } from '../../utils/imageUtils';

// 原来的代码
<img src="http://localhost:3845/assets/xxx.png" />

// 修复后的代码
<img src={convertLocalhostUrl("http://localhost:3845/assets/xxx.png")} />
```

## 注意事项

⚠️ **重要**：此方案假设 Figma MCP 服务器（运行在 3845 端口）允许外部访问。如果图片仍然无法加载，可能需要：

1. 配置 Figma MCP 服务器允许外部访问（绑定到 `0.0.0.0` 而不是 `127.0.0.1`）
2. 或者将图片下载到 `public` 目录，使用相对路径

## 测试

1. 在电脑上启动开发服务器：`npm run dev`
2. 在手机上访问：`http://192.168.1.196:5173`（替换为你的实际 IP）
3. 检查所有页面，确认图片都能正常显示


