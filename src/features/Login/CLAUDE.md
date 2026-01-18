# Login 模块 | src/features/Login/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/features/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
登录页面，用户认证流程的入口。

## 成员清单
- **LoginView.tsx** - Login Gatekeeper
  - 依赖: react@19.2.0, react-router-dom@7.11.0, useAuthStore, AppShell, ./LoginView.module.css, public/videos/login-background.mp4
  - 导出: LoginView (React 函数组件)
  - 职责: 渲染登录页面UI，处理用户登录交互

- **LoginView.module.css** - Login Styles
  - 依赖: src/styles/variables.css
  - 职责: 登录页面样式 (背景视频、底部卡片、按钮布局)

- **index.ts** - Module Aggregator
  - 导出: LoginView

## 路由
- `/login` → LoginView

## 协议回环检查
变更时检查:
- [ ] 更新 L3 头部 (LoginView.tsx)
- [ ] 更新本文件成员清单
- [ ] 更新 ../CLAUDE.md 对应条目

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/features/CLAUDE.md**
