# LoginView Component

基于 Figma 设计精确实现的登录页面组件。

## 技术栈

- **React** + **TypeScript**
- **CSS Modules** (不使用 Tailwind)
- **CSS Variables** (所有文字样式提取为变量)

## 文件结构

```
LoginView/
├── LoginView.tsx          # React 组件
├── LoginView.module.css   # CSS Modules 样式
└── README.md             # 文档
```

## CSS Variables 使用

所有文字样式都定义在 `src/styles/variables.css` 中：

- `--font-serif-medium`: 中文字体（Medium 字重）
- `--font-serif-regular`: 中文字体（Regular 字重）
- `--font-size-md`: 按钮和链接字体大小（16px）
- `--color-text-primary`: 主要文字颜色
- `--color-text-white`: 白色文字
- `--color-text-link`: 链接文字颜色
- `--color-text-link-accent`: 链接强调色

## 组件特性

1. **响应式设计**: 移动端优先，支持不同屏幕尺寸
2. **可访问性**: 包含 `aria-label` 属性
3. **交互反馈**: 按钮 hover 和 active 状态
4. **视频背景**: 支持背景视频播放（带降级方案）

## 使用示例

```tsx
import { LoginView } from './features/Login/LoginView';

function App() {
  return <LoginView />;
}
```

## 待实现功能

- [ ] Google 登录集成
- [ ] 会员登录功能
- [ ] 背景视频资源（当前使用占位符）

## 设计规范

- 设计来源: Figma (node-id: 818-19534)
- 设计宽度: 390px (移动端)
- 圆角: 20px (按钮), 24px (底部卡片)

