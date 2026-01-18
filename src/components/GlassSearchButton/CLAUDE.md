# GlassSearchButton 组件 | src/components/GlassSearchButton/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/components/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
毛玻璃效果搜索按钮。

## 成员清单
- **GlassSearchButton.tsx** - Glass Button
  - 依赖: react@19.2.0, ./GlassSearchButton.module.css
  - 导出: GlassSearchButton (React 函数组件)
  - Props: `{ onClick?: () => void }`
  - 职责: 渲染毛玻璃效果搜索按钮

- **GlassSearchButton.module.css** - Glass Button Styles
  - 依赖: src/styles/variables.css
  - 职责: 毛玻璃效果样式 (backdrop-filter, 半透明背景)

- **index.ts** - Module Aggregator
  - 导出: GlassSearchButton

## 使用示例
```tsx
import { GlassSearchButton } from '@/components/GlassSearchButton';

function Header() {
  return (
    <GlassSearchButton onClick={() => navigate('/search')} />
  );
}
```

## 协议回环检查
- [ ] 更新 L3 头部
- [ ] 更新 ../CLAUDE.md

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/components/CLAUDE.md**
