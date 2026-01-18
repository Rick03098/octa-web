# ReportBottomTabBar 组件 | src/components/ReportBottomTabBar/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/components/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
报告页面底部标签栏，用于在报告的不同章节间切换。

## 成员清单
- **ReportBottomTabBar.tsx** - Report Tab Controller
  - 依赖: react@19.2.0, ./ReportBottomTabBar.module.css
  - 导出: ReportBottomTabBar (React 函数组件)
  - Props: `{ activeTab: string, onTabChange: (tab: string) => void }`
  - 职责: 渲染报告底部标签栏，切换章节

- **ReportBottomTabBar.module.css** - Report Tab Styles
  - 依赖: src/styles/variables.css
  - 职责: 标签栏样式 (固定底部、标签按钮、选中状态)

- **index.ts** - Module Aggregator
  - 导出: ReportBottomTabBar

## 使用示例
```tsx
import { ReportBottomTabBar } from '@/components/ReportBottomTabBar';

function ReportView() {
  const [activeTab, setActiveTab] = useState('overview');

  return (
    <div>
      <main>{/* 报告内容 */}</main>
      <ReportBottomTabBar
        activeTab={activeTab}
        onTabChange={setActiveTab}
      />
    </div>
  );
}
```

## 协议回环检查
- [ ] 更新 L3 头部
- [ ] 更新 ../CLAUDE.md

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/components/CLAUDE.md**
