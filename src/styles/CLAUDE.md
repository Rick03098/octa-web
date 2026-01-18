# 样式系统层 | src/styles/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位

设计系统层，定义全局 CSS 变量和基础样式，所有组件必须使用这些变量保持设计一致性。

## 核心逻辑

- **设计令牌化**: 所有设计值 (颜色、字体、间距) 定义为 CSS 变量
- **单一数据源**: variables.css 是所有样式的唯一真相源
- **Figma 同步**: 变量值从 Figma 设计稿提取

## 架构约束

### 严禁
- **严禁硬编码颜色值**: 必须使用 `var(--color-*)` 变量
- **严禁硬编码字体大小**: 必须使用 `var(--font-size-*)`
- **严禁硬编码间距**: 必须使用 `var(--spacing-*)`
- **严禁全局样式污染**: 使用 CSS Modules 或 Tailwind

### 必须
- **必须使用 CSS 变量**: 所有样式值通过变量引用
- **必须使用 CSS Modules**: 组件样式使用 `.module.css`
- **必须从 Figma 提取**: 新增变量需从设计稿提取

## 成员清单

### **variables.css** - Design Tokens
- **依赖**: 无
- **导出**: CSS 自定义属性 (--变量名)
- **职责**: 定义所有设计令牌
- **来源**: Figma 设计稿
- **变量类别**:
  - `--color-*` - 颜色系统
  - `--font-family-*` - 字体家族
  - `--font-size-*` - 字体大小
  - `--font-weight-*` - 字重
  - `--spacing-*` - 间距系统
  - `--border-radius-*` - 圆角
  - `--shadow-*` - 阴影
  - `--gradient-*` - 渐变

### **index.css** - Global Styles
- **依赖**: variables.css
- **导出**: 全局样式 (body, html 等)
- **职责**: 应用全局重置和基础样式
- **内容**:
  - CSS Reset
  - 字体导入 (Noto Serif SC, Source Han Serif SC)
  - 全局 box-sizing
  - 根元素变量应用

## 上游依赖

- Figma 设计稿 (设计令牌来源)
- Google Fonts (字体文件)

## 下游消费者

- src/features/* (所有功能页面样式)
- src/components/* (所有组件样式)
- tailwind.config.js (Tailwind 扩展主题)

## 设计变量结构

### 颜色系统
```css
--color-primary: #主色;
--color-secondary: #次色;
--color-background: #背景色;
--color-text: #文字色;
--color-border: #边框色;
```

### 字体系统
```css
--font-family-heading: 'Noto Serif SC', serif;
--font-family-body: 'Source Han Serif SC', serif;
--font-size-xs: 12px;
--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 18px;
--font-size-xl: 24px;
```

### 间距系统
```css
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 16px;
--spacing-lg: 24px;
--spacing-xl: 32px;
```

## 使用方式

### 在 CSS Modules 中
```css
.button {
  background-color: var(--color-primary);
  padding: var(--spacing-md);
  border-radius: var(--border-radius-md);
}
```

### 在 Tailwind 中
通过 tailwind.config.js 扩展:
```javascript
theme: {
  extend: {
    colors: {
      primary: 'var(--color-primary)',
    }
  }
}
```

## 协议回环检查

变更此模块时必须检查:

### 1. 新增 CSS 变量
- [ ] 在 variables.css 中定义
- [ ] 更新本文件变量列表
- [ ] 通知团队新变量可用
- [ ] 考虑是否需要更新 Tailwind 配置

### 2. 修改变量值
- [ ] 确认是否从 Figma 提取
- [ ] 检查所有使用该变量的组件 (目视检查)
- [ ] 考虑是否影响已有设计

### 3. 删除变量
- [ ] 使用 `grep` 搜索所有使用该变量的地方
- [ ] 替换为新变量或直接移除
- [ ] 更新本文件变量列表

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
