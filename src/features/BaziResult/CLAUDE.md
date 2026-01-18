# BaziResult 模块 | src/features/BaziResult/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/features/CLAUDE.md](../CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位
八字结果展示页面，以4页滑动方式展示用户的八字信息。

## 成员清单
- **BaziResultView.tsx** - Bazi Result Display
  - 依赖: react@19.2.0 (useState), useOnboardingStore, ./BaziResultView.module.css
  - 导出: BaziResultView (React 函数组件)
  - 职责: 渲染八字结果4页滑动展示，提交档案到后端

- **BaziResultView.module.css** - Bazi Result Styles
  - 依赖: src/styles/variables.css
  - 职责: 八字结果页面样式 (滑动容器、页码指示器、内容卡片)

- **index.ts** - Module Aggregator
  - 导出: BaziResultView

## 路由
- `/onboarding/result` → BaziResultView

## 数据流
```
onboardingStore (name, birthday, birthTime, location, gender)
    ↓
BaziResultView 展示4页内容
    ↓
用户滑动到最后一页，点击提交
    ↓
submitProfile() → profilesApi.createProfile()
    ↓
跳转到主界面
```

## 协议回环检查
变更时检查:
- [ ] 更新 L3 头部 (BaziResultView.tsx)
- [ ] 更新本文件成员清单
- [ ] 更新 ../CLAUDE.md 对应条目

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/features/CLAUDE.md**
