# 组件库层 | src/components/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位

通用UI组件层，提供可复用的组件库，供 Features 使用。

## 核心逻辑

- **可复用**: 组件无业务逻辑，可在多个 Features 中使用
- **受控组件**: 组件通过 props 接收数据和回调函数
- **样式隔离**: 每个组件使用 CSS Modules

## 架构约束

### 严禁
- **严禁包含业务逻辑**: 只负责 UI 渲染
- **严禁调用 API**: 数据由父组件通过 props 传递
- **严禁直接使用 Stores**: 保持组件纯净性

### 必须
- **必须受控**: 组件状态由父组件控制
- **必须类型化**: 完整的 Props 类型定义
- **必须使用 CSS Modules**: 样式隔离

## 成员清单

### 布局组件
- **AppShell.tsx** - App Layout Container
  - 依赖: react@19.2.0
  - 导出: AppShell 组件
  - 职责: 应用布局容器，提供统一的页面结构

### 输入组件
- **DateWheelPicker/** - Date Wheel Picker
  - 依赖: @ncdai/react-wheel-picker@1.1.0
  - 导出: DateWheelPicker 组件
  - 职责: iOS 风格日期滚轮选择器 (年月日)

- **StringWheelPicker/** - String Wheel Picker
  - 依赖: @ncdai/react-wheel-picker@1.1.0
  - 导出: StringWheelPicker 组件
  - 职责: iOS 风格字符串滚轮选择器 (时分)

### 导航组件
- **BottomNavigation/** - Bottom Navigation Bar → [详见 BottomNavigation/CLAUDE.md](BottomNavigation/CLAUDE.md)
  - 依赖: react@19.2.0, react-router-dom@7.11.0
  - 导出: BottomNavigation 组件
  - 职责: 主界面底部导航栏

- **GlassSearchButton/** - Glass Search Button → [详见 GlassSearchButton/CLAUDE.md](GlassSearchButton/CLAUDE.md)
  - 依赖: react@19.2.0
  - 导出: GlassSearchButton 组件
  - 职责: 毛玻璃效果搜索按钮

- **ReportBottomTabBar/** - Report Bottom Tab Bar → [详见 ReportBottomTabBar/CLAUDE.md](ReportBottomTabBar/CLAUDE.md)
  - 依赖: react@19.2.0
  - 导出: ReportBottomTabBar 组件
  - 职责: 报告页面底部标签栏

### 多媒体组件
- **LottieAnimation/** - Lottie Animation Wrapper
  - 依赖: lottie-web@5.13.0, react@19.2.0
  - 导出: LottieAnimation 组件
  - 职责: Lottie 动画播放封装

- **icons/** - SVG Icon Components
  - 依赖: react@19.2.0
  - 导出: 各种图标组件
  - 职责: SVG 图标库

## 子模块索引 (L2.5)

- [BottomNavigation/CLAUDE.md](BottomNavigation/CLAUDE.md) - 底部导航栏
- [GlassSearchButton/CLAUDE.md](GlassSearchButton/CLAUDE.md) - 毛玻璃搜索按钮
- [ReportBottomTabBar/CLAUDE.md](ReportBottomTabBar/CLAUDE.md) - 报告底部标签栏

## 上游依赖

- react@19.2.0
- @ncdai/react-wheel-picker@1.1.0
- lottie-web@5.13.0
- src/styles/variables.css

## 下游消费者

- src/features/* (所有功能页面)

## 协议回环检查

变更此模块时必须检查:

### 1. 新增组件
- [ ] 创建组件文件和样式文件
- [ ] 添加 L3 头部
- [ ] 更新本文件成员清单
- [ ] 如复杂，创建 L2.5 CLAUDE.md

### 2. 删除组件
- [ ] 检查所有使用该组件的 Features
- [ ] 删除组件文件夹
- [ ] 更新本文件成员清单

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
