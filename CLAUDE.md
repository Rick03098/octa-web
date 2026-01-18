# OCTA Web Frontend | CLAUDE.md (L1)

> 类型: L1 项目宪法 | 最后更新: 2026-01-18 | 协议: 变更技术栈/目录结构时必须更新此文件

## 项目本质 (Project Essence)

OCTA 项目的 Web 前端应用 - 基于八字风水理论的视觉环境分析系统的移动端 Web 界面

**核心价值**: 将传统八字命理与现代计算机视觉技术结合，提供个性化环境分析服务。用户通过手机拍摄环境照片，系统结合用户的八字信息，分析环境对个人运势的影响，生成专业的风水报告。

## 技术栈 (Tech Stack - Version Precise)

### 核心运行时
- **React**: 19.2.0
- **React DOM**: 19.2.0
- **TypeScript**: 5.9.3

### 构建工具链
- **Vite**: 7.2.4
- **@vitejs/plugin-react**: 5.1.1
- **PostCSS**: 8.5.6
- **Autoprefixer**: 10.4.23

### 路由与状态管理
- **react-router-dom**: 7.11.0 (路由管理)
- **zustand**: 5.0.9 (轻量级状态管理)

### HTTP 通信
- **axios**: 1.13.2 (HTTP 客户端)

### 样式系统
- **Tailwind CSS**: 4.1.18
- **@tailwindcss/postcss**: 4.1.18
- **CSS Modules**: (内置于 Vite)

### UI 组件库
- **@ncdai/react-wheel-picker**: 1.1.0 (iOS 风格滚轮选择器)
- **lottie-web**: 5.13.0 (动画播放)

### 日期时间
- **dayjs**: 1.11.19 (轻量级日期处理)

### 开发工具
- **ESLint**: 9.39.1
- **eslint-plugin-react-hooks**: 7.0.1
- **eslint-plugin-react-refresh**: 0.4.24
- **typescript-eslint**: 8.46.4
- **@types/react**: 19.2.5
- **@types/react-dom**: 19.2.3

## 目录树与职责 (Directory Tree & Responsibilities)

```
/
├── src/                              → L2: src/CLAUDE.md (源代码根目录)
│   ├── api/                          → L2: src/api/CLAUDE.md (API客户端层)
│   │   ├── client.ts                 → HTTP 通信核心 (axios 配置、拦截器)
│   │   ├── auth.ts                   → 认证 API (登录、注册、刷新token)
│   │   ├── profiles.ts               → 八字档案 API (CRUD)
│   │   ├── analysis.ts               → 风水分析 API (提交分析、查询结果)
│   │   ├── media.ts                  → 媒体上传 API (图片、视频)
│   │   └── users.ts                  → 用户资料 API
│   │
│   ├── stores/                       → L2: src/stores/CLAUDE.md (Zustand 状态管理)
│   │   ├── authStore.ts              → 认证状态 (登录状态、用户信息、token)
│   │   ├── onboardingStore.ts        → 用户引导状态 (姓名、生日、时间、地点、性别)
│   │   └── appStore.ts               → 应用全局状态 (主题、语言、导航)
│   │
│   ├── features/                     → L2: src/features/CLAUDE.md (功能模块层)
│   │   ├── Login/                    → L2.5: 登录页面
│   │   ├── NameEntry/                → 姓名输入
│   │   ├── BirthdayInput/            → 生日输入
│   │   ├── BirthTimeInput/           → 出生时间输入
│   │   ├── BirthLocationInput/       → 出生地输入
│   │   ├── GenderSelection/          → 性别选择
│   │   ├── BaziResult/               → L2.5: 八字结果展示 (4页滑动)
│   │   ├── MainDashboard/            → 主界面仪表盘
│   │   ├── MainDashboardEmpty/       → 空状态仪表盘
│   │   ├── Tutorial/                 → L2.5: 拍摄教程
│   │   ├── Capture/                  → 相机拍摄
│   │   ├── CaptureComplete/          → 拍摄完成
│   │   ├── OrientationCapture/       → 朝向捕捉
│   │   ├── Preview/                  → 报告预览
│   │   ├── Report/                   → 报告阅读器
│   │   ├── Chat/                     → 聊天界面 (Phase 2)
│   │   ├── ChatIntro/                → 聊天引导
│   │   ├── Loading/                  → 加载状态
│   │   └── Permissions/              → 权限请求 (移动端)
│   │
│   ├── components/                   → L2: src/components/CLAUDE.md (通用UI组件)
│   │   ├── AppShell.tsx              → 应用布局容器
│   │   ├── DateWheelPicker/          → 日期滚轮选择器
│   │   ├── StringWheelPicker/        → 字符串滚轮选择器
│   │   ├── BottomNavigation/         → L2.5: 底部导航栏
│   │   ├── GlassSearchButton/        → L2.5: 毛玻璃搜索按钮
│   │   ├── ReportBottomTabBar/       → L2.5: 报告底部标签栏
│   │   ├── LottieAnimation/          → Lottie 动画封装
│   │   └── icons/                    → SVG 图标组件
│   │
│   ├── types/                        → L2: src/types/CLAUDE.md (TypeScript 类型定义)
│   │   ├── api.ts                    → API 通信类型 (请求、响应、错误)
│   │   ├── models.ts                 → 业务模型类型 (与后端 Pydantic 同步)
│   │   └── common.ts                 → 通用类型和枚举
│   │
│   ├── styles/                       → L2: src/styles/CLAUDE.md (设计系统)
│   │   └── variables.css             → CSS 变量 (颜色、字体、间距、渐变)
│   │
│   ├── utils/                        → L2: src/utils/CLAUDE.md (工具函数)
│   │   ├── gradients.ts              → 渐变工具函数
│   │   ├── imageUtils.ts             → 图片处理工具
│   │   └── ...                       → 其他工具函数
│   │
│   ├── constants/                    → L2: src/constants/CLAUDE.md (常量定义)
│   │   └── strings.ts                → UI 文本常量
│   │
│   ├── App.tsx                       → 路由配置 (18条路由定义)
│   └── main.tsx                      → 应用入口 (React 根节点挂载)
│
├── public/                           → 静态资源目录
│   ├── images/                       → 图片资源
│   ├── videos/                       → 视频资源
│   └── lottie/                       → Lottie 动画 JSON
│
├── .vscode/                          → VSCode 配置
│   └── l3-header.code-snippets       → L3 头部快速插入代码片段
│
├── .git/hooks/                       → Git Hooks
│   └── pre-commit                    → GEB 协议回环检查脚本
│
├── package.json                      → 依赖清单和脚本定义
├── vite.config.ts                    → Vite 构建配置
├── tsconfig.json                     → TypeScript 编译配置 (主配置)
├── tsconfig.app.json                 → TypeScript 应用代码配置
├── tsconfig.node.json                → TypeScript Node 环境配置
├── tailwind.config.js                → Tailwind CSS 配置
├── postcss.config.js                 → PostCSS 处理器配置
├── eslint.config.js                  → ESLint 代码规范配置
└── README.md                         → 项目快速启动指南
```

## 配置文件用途 (Configuration Files)

| 文件 | 用途 | 关键配置 |
|------|------|---------|
| **package.json** | 依赖管理和脚本定义 | dependencies, devDependencies, scripts (dev/build/lint/preview) |
| **vite.config.ts** | Vite 构建工具配置 | React 插件、开发服务器端口 5173、移动端预览支持 |
| **tsconfig.json** | TypeScript 主配置 | 引用 tsconfig.app.json 和 tsconfig.node.json |
| **tsconfig.app.json** | TypeScript 应用代码配置 | target: ES2020, lib: ES2020+DOM, jsx: react-jsx, strict: true, 路径别名 @/* |
| **tsconfig.node.json** | TypeScript 构建脚本配置 | Node 环境类型定义，用于 vite.config.ts |
| **tailwind.config.js** | Tailwind CSS 配置 | content: src/**/*.{ts,tsx}, theme 扩展 |
| **postcss.config.js** | PostCSS 处理器配置 | 插件: @tailwindcss/postcss, autoprefixer |
| **eslint.config.js** | ESLint 代码规范 | React 19 规则、Hooks 检查、TypeScript 规则 |

## 架构约束 (Architectural Constraints)

### 数据流向 (单向数据流)

```
外部数据源
    ↓
API Client (src/api/*)
    ↓
Stores (src/stores/*)
    ↓
Features/Components (src/features/*, src/components/*)
    ↓
Views (渲染到浏览器)
```

**严格禁止反向调用**: Components/Features 不得直接调用 API，必须通过 Stores 中介。

### 层级隔离规则

#### 1. API 层隔离
- ✅ **允许**: Stores 调用 API
- ❌ **禁止**: Features/Components 直接调用 API
- ❌ **禁止**: 直接使用 axios (必须通过 `api/client.ts`)
- ❌ **禁止**: 硬编码 URL (必须使用 `VITE_API_BASE_URL` 环境变量)

#### 2. Store 层隔离
- ✅ **允许**: Features/Components 订阅 Store 状态
- ✅ **允许**: Features/Components 调用 Store 方法
- ❌ **禁止**: Store 中写 UI 逻辑 (如 DOM 操作)
- ❌ **禁止**: Store 之间循环依赖

#### 3. Features 层隔离
- ✅ **允许**: Features 使用 Components
- ✅ **允许**: Features 使用 Stores
- ❌ **禁止**: Features 之间直接引用 (通过 Stores 共享数据)
- ❌ **禁止**: Features 包含业务逻辑 (应在 Stores 中)

#### 4. Components 层隔离
- ✅ **允许**: Components 接收 props
- ✅ **允许**: Components 有内部 UI 状态 (如展开/收起)
- ❌ **禁止**: Components 调用 API
- ❌ **禁止**: Components 包含业务逻辑

#### 5. 样式层隔离
- ✅ **允许**: 使用 `src/styles/variables.css` 中的 CSS 变量
- ✅ **允许**: 使用 CSS Modules (`.module.css`)
- ❌ **禁止**: 硬编码颜色值 (必须使用 CSS 变量)
- ❌ **禁止**: 全局样式污染 (必须用 CSS Modules 或 Tailwind)

### 类型同步协议

#### 前后端类型同步
- `src/types/models.ts` 中的业务模型必须与后端 Pydantic 模型保持同步
- 后端模型变更时，必须同步更新前端类型定义
- 使用 TypeScript 严格模式 (`strict: true`) 确保类型安全

#### API 函数类型化
- 所有 API 函数必须有明确的请求参数类型和响应类型
- 使用泛型确保类型推断正确 (如 `api.get<UserProfile>('/users/me')`)

### 命名约束

#### 文件命名
- Features: `[FeatureName]View.tsx` + `[FeatureName]View.module.css`
- Components: `[ComponentName].tsx` + `[ComponentName].module.css`
- Stores: `[domain]Store.ts`
- API: `[domain].ts` (如 `auth.ts`, `profiles.ts`)

#### 代码命名
- 组件: PascalCase (如 `LoginView`, `AppShell`)
- 函数: camelCase (如 `getUserProfile`, `handleSubmit`)
- 常量: UPPER_SNAKE_CASE (如 `API_BASE_URL`)
- CSS 变量: kebab-case (如 `--color-primary`, `--font-heading`)

### 环境变量

```bash
# .env.local (开发环境)
VITE_API_BASE_URL=http://localhost:8000

# .env.production (生产环境)
VITE_API_BASE_URL=https://api.octa.example.com
```

**约束**:
- 所有环境变量必须以 `VITE_` 开头 (Vite 约定)
- 不得在代码中硬编码环境变量值
- 敏感信息 (如 API 密钥) 不得提交到 Git

## L2 模块索引 (Module Index)

### 核心数据层
- [API 客户端层](src/api/CLAUDE.md) - HTTP 通信封装，认证处理，错误拦截
- [状态管理层](src/stores/CLAUDE.md) - Zustand stores，连接 API 和 UI
- [类型定义层](src/types/CLAUDE.md) - TypeScript 类型，与后端同步
- [样式系统层](src/styles/CLAUDE.md) - CSS 变量，设计令牌

### 业务功能层
- [功能模块层](src/features/CLAUDE.md) - 页面级功能组件 (27个功能模块)
- [组件库层](src/components/CLAUDE.md) - 可复用 UI 组件 (10+ 组件)

### 基础工具层
- [工具函数层](src/utils/CLAUDE.md) - 纯函数工具集
- [常量定义层](src/constants/CLAUDE.md) - 静态常量和枚举

### 复杂子模块 (L2.5)
- [Login 登录页面](src/features/Login/CLAUDE.md) - 认证入口
- [BaziResult 八字结果](src/features/BaziResult/CLAUDE.md) - 4页滑动展示
- [Tutorial 拍摄教程](src/features/Tutorial/CLAUDE.md) - 动画引导
- [BottomNavigation 底部导航](src/components/BottomNavigation/CLAUDE.md) - 主导航栏
- [GlassSearchButton 搜索按钮](src/components/GlassSearchButton/CLAUDE.md) - 毛玻璃效果
- [ReportBottomTabBar 报告标签栏](src/components/ReportBottomTabBar/CLAUDE.md) - 报告阅读导航

## 辅助文档 (Auxiliary Documentation)

### GEB 分形文档体系 (本体系)
- **CLAUDE.md 系列**: AI Agent 导航地图，同时供开发者理解系统架构
  - L1: `/CLAUDE.md` (本文件) - 项目宪法
  - L2: `src/*/CLAUDE.md` - 模块地图
  - L2.5: `src/features/*/CLAUDE.md` - 子模块地图
  - L3: 文件头部 `[INPUT]/[OUTPUT]/[POS]/[PROTOCOL]` 注释 - 文件契约

- **.folder.md 系列**: 团队内部文档 (与 CLAUDE.md 内容同步，供人类快速阅读)

### 操作指南 (非架构文档)

以下文档提供开发流程指导，但不属于 GEB 分形体系，架构决策以本文件为准:

#### 快速启动
- `README.md` - 项目快速启动指南 (npm install, npm run dev)

#### 部署流程
- `TEAMMATE_GUIDE.md` - 同事部署指南 (中文)
- `DEPLOYMENT_GUIDE.md` - Vercel/Docker/本地部署流程

#### 开发指南
- `MOBILE_PREVIEW.md` - 移动端预览配置
- `HOW_TO_ADD_IMAGES.md` - 图片添加规范
- `IMAGES_REQUIRED.md` - 所需图片清单
- `RESPONSIVE_DESIGN.md` - 响应式设计规范
- `MOBILE_IMAGE_FIX.md` - 移动端图片适配方案
- `CODE_REVIEW.md` - 代码审查标准

#### Git 工作流
- `GITHUB_GUIDE.md` - GitHub 使用指南
- `GITHUB_WORKFLOW.md` - Git 工作流程
- `GITHUB_COLLABORATION.md` - 团队协作规范

#### 其他
- `PREVIEW_GUIDE.md` - 预览环境指南
- `REBUILDING PLAN.md` - 项目重构计划
- `ARCHITECTURE_SUMMARY.md` - ⚠️ 已过时，内容已迁移到本文件

## 文档维护协议 (Documentation Maintenance Protocol)

### 双轨并存原则

- **CLAUDE.md**: 架构真相源 (Source of Truth)
  - 供 AI Agent 导航使用
  - 同时供开发者理解系统结构
  - 必须保持精确和最新

- **.folder.md**: 团队内部文档
  - 供人类快速阅读
  - 与 CLAUDE.md 内容同步
  - 可选维护 (建议同步更新)

### 更新优先级 (回环检查)

```
代码变更
    ↓
1. 更新文件 L3 头部 ([INPUT]/[OUTPUT]/[POS])
    ↓
2. 检查 L3 [PROTOCOL] 字段 → 找到对应的 L2 CLAUDE.md
    ↓
3. 更新 L2 CLAUDE.md 成员清单 (如文件增删、接口变更)
    ↓
4. 如 L2 结构变化 → 更新 L1 CLAUDE.md 目录树
    ↓
5. (可选) 同步更新对应的 .folder.md
    ↓
提交 Git Commit (pre-commit hook 会验证)
```

### 强制规则 (FORBIDDEN)

#### 死罪 (立即中止提交)
- **FATAL-001 孤立代码变更**: 改代码不更新文档视为未完成，pre-commit hook 会阻止提交
- **FATAL-002 跳过 L3 头部**: 新建业务代码文件必须添加 L3 头部
- **FATAL-003 删文件不更新清单**: 删除文件必须同步更新 L2 CLAUDE.md 成员清单
- **FATAL-004 新模块不创建 L2**: 新增模块文件夹必须创建对应 CLAUDE.md

#### 重罪 (警告后修复)
- **SEVERE-001 L3 过时**: 文件头部与实际代码不符 (如依赖已变更但 INPUT 未更新)
- **SEVERE-002 L2 不完整**: 成员清单存在遗漏文件
- **SEVERE-003 L1 过时**: 目录结构变化未反映到本文件
- **SEVERE-004 父级链接断裂**: L2/L2.5 的父级链接指向错误路径

### L3 头部协议示例

每个 .ts/.tsx 文件顶部必须有:

```typescript
/**
 * [INPUT]: 依赖 {模块/文件} 的 {具体能力}
 * [OUTPUT]: 对外提供 {导出的函数/组件/类型/常量}
 * [POS]: {所属模块} 的 {角色定位}，{与兄弟文件的关系}
 * [PROTOCOL]: 变更时更新此头部，然后检查 {对应L2路径}/CLAUDE.md
 */
```

详见各 L2 模块文档中的具体示例。

## GEB 分形原则 (GEB Fractal Principles)

### 三相同构
- **代码相**: 机器执行的源代码
- **文档相**: AI Agent 理解的语义地图
- **同构性**: 代码变更 → 文档必须同步变更

### 分形自相似
- L1 是 L2 的折叠 (目录树折叠为模块清单)
- L2 是 L3 的折叠 (文件清单折叠为头部契约)
- L3 是代码的折叠 (头部契约折叠为实际 import/export)

### 回环检查
任何一相的变化必须在另一相显现:
- 代码变更 → L3 头部必须更新 → L2 成员清单必须更新 → L1 目录树可能更新
- 文档过时 = 系统失忆 = 技术债务

## 工具支持 (Tooling Support)

### VSCode Snippet
- 快捷键: 输入 `l3header` → 自动插入 L3 头部模板
- 位置: `.vscode/l3-header.code-snippets`

### Pre-commit Hook
- 功能: 检测 L3 头部缺失、CLAUDE.md 未同步
- 位置: `.git/hooks/pre-commit`
- 执行级别: 初期 WARNING (可跳过)，稳定后 ERROR (阻止提交)

### 验证命令
```bash
# 检查所有 CLAUDE.md 文件存在
find . -name "CLAUDE.md"

# 检查所有 .ts/.tsx 文件是否有 [PROTOCOL] 标记
grep -r "\[PROTOCOL\]" src --include="*.ts" --include="*.tsx"

# 统计已添加 L3 头部的文件数量
grep -r "\[PROTOCOL\]" src --include="*.ts" --include="*.tsx" -l | wc -l
```

---

## 版本历史 (Version History)

- **2026-01-18**: L1 项目宪法初始创建
  - 建立 GEB 分形文档系统基础架构
  - 定义技术栈版本清单 (精确到 patch 版本)
  - 确立架构约束和数据流向规则
  - 创建 L2 模块索引和文档维护协议

---

**The map IS the terrain. The terrain IS the map.**

代码是机器相，文档是语义相，两相必须同构。
任一相变化，必须在另一相显现，否则视为未完成。

Keep the map aligned with the terrain, or the terrain will be lost.
