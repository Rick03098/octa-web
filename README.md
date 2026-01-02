# OCTA Web Frontend

这是 OCTA 项目的 Web 前端版本，采用 React + TypeScript + Vite 构建。

## 技术栈

- **React 19** + **TypeScript 5.9** + **Vite 7** - 现代化、高性能
- **CSS Modules** - 精确还原 Figma 设计，避免样式冲突
- **Zustand** - 轻量级状态管理
- **React Router v7** - 路由管理
- **Axios** - HTTP 客户端
- **lottie-web** - Lottie 动画支持

## 项目结构

```
src/
├── api/              # API 客户端层（封装所有后端 API 调用）
├── components/       # 通用组件（AppShell, LottieAnimation 等）
├── features/         # 功能模块（按页面组织，每个模块包含 View 和样式）
├── stores/           # 状态管理（Zustand stores）
├── styles/           # 设计系统（CSS 变量、全局样式、渐变工具函数）
├── types/            # TypeScript 类型定义（与后端 Pydantic 模型同步）
├── utils/            # 工具函数
├── constants/        # 常量定义
├── App.tsx           # 路由配置
└── main.tsx          # 应用入口
```

## 架构规范

本项目遵循"分形架构守护者"规范：

- **IOP 契约**: 每个文件头部包含 `[INPUT]`、`[OUTPUT]`、`[POS]` 注释
- **文件夹地图**: 每个关键文件夹包含 `.folder.md` 说明文件
- **文档同步**: 代码变更时同步更新相关文档

详细规范请参考：
- [../.cursorrules](../.cursorrules) - 核心规范定义
- [../ARCHITECTURE_GUARDIAN.md](../ARCHITECTURE_GUARDIAN.md) - 工作流指南

## 开发

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:5173

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 环境变量

创建 `.env` 文件（参考 `.env.example`）：

```bash
VITE_API_BASE_URL=http://localhost:8000
```

## 设计系统

设计令牌定义在 `src/styles/variables.css` 中，包括：

- 字体系统（字体族、大小、粗细、行高）
- 颜色系统（文本颜色、背景颜色）
- 渐变颜色值（各页面的背景渐变）
- 间距系统
- 圆角系统
- 阴影系统
- 布局系统

所有组件应使用 CSS 变量，严禁硬编码值。

## API 集成

API 客户端位于 `src/api/` 目录：

- `client.ts` - Axios 配置（认证、错误处理）
- `auth.ts` - 认证相关 API
- `profiles.ts` - 八字档案相关 API
- `analysis.ts` - 风水分析相关 API
- `users.ts` - 用户资料相关 API

所有 API 函数都有完整的 TypeScript 类型定义，与后端 Pydantic 模型保持一致。

## 状态管理

使用 Zustand 管理全局状态：

- `onboardingStore` - 用户引导流程状态（姓名、生日、时间、地点、性别、朝向）
- `authStore` - 用户认证状态（登录状态、用户信息、token）

## 待实现页面

- [x] 登录页（基础版本）
- [ ] 姓名输入页
- [ ] 生日输入页
- [ ] 出生时间输入页
- [ ] 出生地输入页
- [ ] 性别选择页
- [ ] 八字结果页（4页滑动）
- [ ] 权限页
- [ ] 拍摄相关页面
- [ ] 朝向捕捉页
- [ ] 环境报告页
- [ ] 主界面

## 移动端预览

配置已支持移动端预览，详见 [MOBILE_PREVIEW.md](./MOBILE_PREVIEW.md)。
