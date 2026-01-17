# OCTA Web 前端重建方案

## 🎯 推荐技术栈

### 核心框架
- **React 19** + **TypeScript 5.9** + **Vite 7** - 现代化、高性能
- **CSS Modules** - 精确还原 Figma 设计，避免样式冲突
- **Zustand** - 轻量级状态管理（比 Redux 简单，比 Context 高效）
- **React Router v7** - 路由管理

### 开发工具
- **ESLint** + **TypeScript** - 代码质量
- **pnpm** - 更快的包管理（可选，npm 也可以）

### 动画和媒体
- **lottie-web** - Lottie 动画支持
- **react-player** 或原生 `<video>` - 视频播放

## 🏗️ 推荐架构：Monorepo + 共享类型

### 方案 A：Monorepo（推荐）

```
OCTA/
├── backend-v1/          # 现有后端（FastAPI）
├── octa-frontend-v1/     # 现有 iOS（SwiftUI）
├── octa-web/            # 新 Web 前端
│   ├── src/
│   │   ├── api/         # API 客户端
│   │   ├── components/  # 通用组件
│   │   ├── features/    # 功能模块（按页面组织）
│   │   ├── stores/      # Zustand 状态管理
│   │   ├── styles/      # CSS Modules + 变量
│   │   └── types/       # TypeScript 类型（从后端生成）
│   └── package.json
└── shared/              # 共享代码（可选）
    └── types/           # 从后端 Pydantic 生成的 TypeScript 类型
```

### 方案 B：独立项目 + 类型同步

保持独立项目，但通过脚本从后端生成 TypeScript 类型。

## 🔗 代码融合方案

### 1. 类型定义共享

**选项 1：手动维护（简单，适合 MVP）**
- 在 `octa-web/src/types/` 手动维护 TypeScript 类型
- 与后端 `backend-v1/app/models/` 的 Pydantic 模型保持同步
- 优点：简单直接，无需额外工具
- 缺点：需要手动同步

**选项 2：自动生成（推荐，适合长期）**
- 使用 `pydantic-to-typescript` 或 `datamodel-code-generator`
- 从后端 Pydantic 模型自动生成 TypeScript 类型
- 优点：类型一致，减少错误
- 缺点：需要配置生成脚本

### 2. API 客户端类型化

```typescript
// octa-web/src/api/profiles.ts
import apiClient from './client';
import type { 
  CreateBaziProfileRequest, 
  BaziProfileResponse 
} from '../types/models';

export const profilesApi = {
  create: (data: CreateBaziProfileRequest) => 
    apiClient.post<BaziProfileResponse>('/v1/profiles/bazi', data),
  
  list: () => 
    apiClient.get<BaziProfileResponse[]>('/v1/profiles/bazi'),
  
  get: (id: string) => 
    apiClient.get<BaziProfileResponse>(`/v1/profiles/bazi/${id}`),
};
```

### 3. 常量共享

从 iOS 的 `DSStrings.swift` 和 `DSColors.swift` 提取：
- 字符串常量 → `src/constants/strings.ts`
- 颜色/渐变 → `src/styles/variables.css` (CSS 变量)

## 📁 推荐项目结构

```
octa-web/
├── src/
│   ├── api/                    # API 客户端
│   │   ├── client.ts           # Axios 配置
│   │   ├── auth.ts             # 认证相关 API
│   │   ├── profiles.ts         # 八字档案 API
│   │   ├── analysis.ts         # 分析相关 API
│   │   └── media.ts            # 媒体上传 API
│   │
│   ├── components/             # 通用组件
│   │   ├── AppShell.tsx        # 应用外壳（固定宽度、背景）
│   │   ├── LottieAnimation/    # Lottie 动画组件
│   │   ├── WheelPicker/        # 滚轮选择器
│   │   └── icons/              # SVG 图标组件
│   │
│   ├── features/               # 功能模块（按页面组织）
│   │   ├── Login/
│   │   │   ├── LoginView.tsx
│   │   │   └── LoginView.module.css
│   │   ├── NameEntry/
│   │   ├── BirthdayInput/
│   │   ├── BirthTimeInput/
│   │   ├── BirthLocationInput/
│   │   ├── GenderSelection/
│   │   ├── BaziResult/
│   │   ├── Permissions/
│   │   ├── MainDashboard/
│   │   └── ...
│   │
│   ├── stores/                 # Zustand 状态管理
│   │   ├── onboardingStore.ts  # 用户输入状态
│   │   ├── authStore.ts        # 认证状态
│   │   └── appStore.ts         # 全局状态
│   │
│   ├── styles/                 # 全局样式
│   │   ├── variables.css       # CSS 变量（设计令牌）
│   │   └── reset.css           # CSS Reset（可选）
│   │
│   ├── types/                  # TypeScript 类型定义
│   │   ├── models.ts           # 数据模型（对应后端 Pydantic）
│   │   ├── api.ts              # API 响应类型
│   │   └── common.ts           # 通用类型
│   │
│   ├── utils/                  # 工具函数
│   │   ├── date.ts             # 日期处理
│   │   ├── format.ts           # 格式化
│   │   └── validation.ts      # 验证
│   │
│   ├── App.tsx                 # 主应用组件（路由）
│   ├── main.tsx                # 入口文件
│   └── index.css               # 全局样式入口
│
├── public/                     # 静态资源
│   ├── fonts/                  # 字体文件（从 iOS 复制）
│   └── videos/                 # 视频文件
│
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 🚀 迁移步骤

### 第一步：清理并重建基础结构
1. 删除 `octa-web` 中所有现有代码（或备份）
2. 重新初始化 Vite + React + TypeScript 项目
3. 安装核心依赖：`zustand`, `react-router-dom`, `axios`, `lottie-web`

### 第二步：建立类型系统
1. 从后端 `models/` 目录提取 Pydantic 模型
2. 手动转换为 TypeScript 类型（或配置自动生成）
3. 创建 `src/types/models.ts`

### 第三步：建立 API 客户端
1. 配置 Axios 客户端（认证、错误处理）
2. 为每个后端 API 模块创建对应的 API 函数
3. 使用 TypeScript 类型确保类型安全

### 第四步：建立设计系统
1. 从 Figma 提取设计令牌（颜色、字体、间距）
2. 创建 `src/styles/variables.css`（CSS 变量）
3. 建立组件库基础（按钮、输入框等）

### 第五步：按页面逐步实现
1. 从登录页开始，逐个页面实现
2. 每个页面：Figma → CSS Modules → React 组件
3. 确保像素级还原

## 🎨 设计系统实现

### CSS 变量（设计令牌）

```css
/* src/styles/variables.css */
:root {
  /* 字体 */
  --font-family-serif: 'Noto Serif SC', serif;
  --font-size-title: 24px;
  --font-weight-bold: 700;
  
  /* 颜色 */
  --color-primary: #000000;
  --color-background: #FFFFFF;
  
  /* 渐变 */
  --gradient-login: linear-gradient(180deg, #FFE5E5 0%, #FFF5F5 100%);
  
  /* 间距 */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  
  /* 圆角 */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 16px;
}
```

### CSS Modules 使用

```tsx
// LoginView.tsx
import styles from './LoginView.module.css';

export function LoginView() {
  return (
    <div className={styles.container}>
      <h1 className={styles.title}>登录</h1>
    </div>
  );
}
```

```css
/* LoginView.module.css */
.container {
  width: 100%;
  max-width: 480px;
  margin: 0 auto;
  padding: var(--spacing-lg);
}

.title {
  font-family: var(--font-family-serif);
  font-size: var(--font-size-title);
  font-weight: var(--font-weight-bold);
}
```

## 🔧 工具配置

### Vite 配置（移动端预览）

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0', // 允许网络访问
    port: 5173,
  },
  css: {
    modules: {
      localsConvention: 'camelCase',
    },
  },
});
```

### TypeScript 配置

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "strict": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "skipLibCheck": true
  }
}
```

## 📦 依赖清单

```json
{
  "dependencies": {
    "react": "^19.2.0",
    "react-dom": "^19.2.0",
    "react-router-dom": "^7.11.0",
    "zustand": "^5.0.9",
    "axios": "^1.13.2",
    "lottie-web": "^5.13.0",
    "dayjs": "^1.11.19"
  },
  "devDependencies": {
    "@types/react": "^19.2.5",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^5.1.1",
    "typescript": "~5.9.3",
    "vite": "^7.2.4"
  }
}
```

## ✅ 优势总结

1. **类型安全**：TypeScript + 后端类型同步，减少 API 调用错误
2. **设计还原**：CSS Modules 精确控制样式，像素级还原 Figma
3. **代码复用**：共享类型定义，减少重复代码
4. **易于维护**：清晰的目录结构，按功能模块组织
5. **性能优化**：Vite 快速构建，React 19 性能提升
6. **移动优先**：固定宽度布局（480px），完美适配手机

## 🎯 下一步行动

1. **确认方案**：选择 Monorepo 或独立项目
2. **清理重建**：删除现有 `octa-web` 代码，重新初始化
3. **建立类型**：从后端模型生成/手动创建 TypeScript 类型
4. **实现第一页**：从登录页开始，建立开发流程
5. **逐步迁移**：按页面顺序逐个实现


