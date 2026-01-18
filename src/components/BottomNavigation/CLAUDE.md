# BottomNavigation 组件 | src/components/BottomNavigation/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/components/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
主界面底部导航栏，提供主要功能入口。

## 成员清单
- **BottomNavigation.tsx** - Bottom Nav Controller
  - 依赖: react@19.2.0, react-router-dom@7.11.0, ./BottomNavigation.module.css
  - 导出: BottomNavigation (React 函数组件)
  - Props: 无 (自包含)
  - 职责: 渲染底部导航栏，处理路由跳转

- **BottomNavigation.module.css** - Bottom Nav Styles
  - 依赖: src/styles/variables.css
  - 职责: 导航栏样式 (固定底部、图标、文字)

- **index.ts** - Module Aggregator
  - 导出: BottomNavigation

## 使用示例
```tsx
import { BottomNavigation } from '@/components/BottomNavigation';

function MainDashboardView() {
  return (
    <div>
      <main>{/* 主内容 */}</main>
      <BottomNavigation />
    </div>
  );
}
```

## 协议回环检查
- [ ] 更新 L3 头部
- [ ] 更新 ../CLAUDE.md

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/components/CLAUDE.md**
