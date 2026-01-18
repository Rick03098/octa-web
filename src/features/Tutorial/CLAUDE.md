# Tutorial 模块 | src/features/Tutorial/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/features/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
拍摄教程页面，通过 Lottie 动画引导用户如何拍摄环境照片。

## 成员清单
- **TutorialView.tsx** - Tutorial Display
  - 依赖: react@19.2.0, react-router-dom@7.11.0, components/LottieAnimation, ./TutorialView.module.css
  - 导出: TutorialView (React 函数组件)
  - 职责: 播放拍摄教程动画，引导用户操作

- **TutorialView.module.css** - Tutorial Styles
  - 依赖: src/styles/variables.css
  - 职责: 教程页面样式 (全屏布局、动画容器、继续按钮)

- **index.ts** - Module Aggregator
  - 导出: TutorialView

## 路由
- `/tutorial` → TutorialView

## 协议回环检查
变更时检查:
- [ ] 更新 L3 头部 (TutorialView.tsx)
- [ ] 更新本文件成员清单
- [ ] 更新 ../CLAUDE.md 对应条目

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/features/CLAUDE.md**
