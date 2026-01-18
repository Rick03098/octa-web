# 功能模块层 | src/features/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位

功能模块层，按页面/功能组织代码，每个功能模块包含 View 组件和相关样式文件。

## 核心逻辑

- **模块化**: 每个功能模块独立文件夹，包含 `[Feature]View.tsx` 和 `[Feature]View.module.css`
- **单一职责**: 每个 View 组件负责一个完整页面/功能的 UI 渲染
- **数据获取**: View 组件通过 Stores 获取数据，通过 API 函数提交数据
- **样式隔离**: 每个 View 使用独立的 CSS Module 文件

## 架构约束

### 严禁
- **严禁直接调用 API**: 必须通过 Stores
- **严禁业务逻辑**: 复杂的业务逻辑应在 Stores 中
- **严禁跨模块引用**: 不同 feature 之间不直接引用，通过 Stores 共享数据
- **严禁硬编码样式**: 必须使用 CSS Modules

### 必须
- **必须使用 CSS Modules**: 每个 View 必须有对应的 `.module.css` 文件
- **必须通过 Stores 获取数据**: 不直接调用 API
- **必须有 L3 头部**: 每个 View 文件必须有 [INPUT]/[OUTPUT]/[POS]/[PROTOCOL] 注释

## 成员清单

### 认证流程
- **Login/** - Login Gatekeeper → [详见 Login/CLAUDE.md](Login/CLAUDE.md)
  - 依赖: authStore, components/AppShell
  - 导出: LoginView 组件
  - 职责: 用户登录页面，认证流程入口

### 用户引导流程 (Onboarding)
- **NameEntry/** - Name Input Processor
  - 依赖: onboardingStore
  - 导出: NameEntryView
  - 职责: 姓名输入页面

- **BirthdayInput/** - Birthday Input Processor
  - 依赖: onboardingStore, components/DateWheelPicker
  - 导出: BirthdayInputView
  - 职责: 生日输入页面 (iOS风格滚轮)

- **BirthTimeInput/** - Birth Time Input Processor
  - 依赖: onboardingStore, components/StringWheelPicker
  - 导出: BirthTimeInputView
  - 职责: 出生时间输入页面 (时分滚轮)

- **BirthLocationInput/** - Location Input Processor
  - 依赖: onboardingStore, 地图API (待定)
  - 导出: BirthLocationInputView
  - 职责: 出生地输入页面

- **GenderSelection/** - Gender Selector
  - 依赖: onboardingStore
  - 导出: GenderSelectionView
  - 职责: 性别选择页面

- **BaziResult/** - Bazi Result Display → [详见 BaziResult/CLAUDE.md](BaziResult/CLAUDE.md)
  - 依赖: onboardingStore, profilesApi
  - 导出: BaziResultView
  - 职责: 八字结果展示页面 (4页滑动)

### 主应用流程
- **MainDashboard/** - Main Dashboard Controller
  - 依赖: authStore, appStore, components/BottomNavigation
  - 导出: MainDashboardView
  - 职责: 主界面仪表盘，显示环境卡片

- **MainDashboardEmpty/** - Empty State Dashboard
  - 依赖: authStore, components/BottomNavigation
  - 导出: MainDashboardEmptyView
  - 职责: 空状态主界面 (无数据时)

- **Tutorial/** - Capture Tutorial Display → [详见 Tutorial/CLAUDE.md](Tutorial/CLAUDE.md)
  - 依赖: components/LottieAnimation
  - 导出: TutorialView
  - 职责: 拍摄教程页面 (Lottie动画引导)

- **Capture/** - Camera Controller
  - 依赖: 浏览器 MediaDevices API
  - 导出: CaptureView
  - 职责: 相机拍摄页面

- **CaptureComplete/** - Capture Complete Display
  - 依赖: 无
  - 导出: CaptureCompleteView
  - 职责: 拍摄完成提示页面

- **OrientationCapture/** - Orientation Processor
  - 依赖: 罗盘API/设备方向API
  - 导出: OrientationCaptureView
  - 职责: 朝向捕捉页面

- **Preview/** - Report Preview Display
  - 依赖: analysisApi, components/ReportBottomTabBar
  - 导出: PreviewView
  - 职责: 环境报告预览页面

- **Report/** - Report Reader
  - 依赖: analysisApi, components/ReportBottomTabBar
  - 导出: ReportView
  - 职责: 环境报告阅读页面

- **Chat/** - Chat Interface (Phase 2)
  - 依赖: Chat API (待定)
  - 导出: ChatView
  - 职责: 聊天界面 (未来功能)

- **ChatIntro/** - Chat Introduction
  - 依赖: 无
  - 导出: ChatIntroView
  - 职责: 聊天引导页面

- **Loading/** - Loading State Display
  - 依赖: components/LottieAnimation
  - 导出: LoadingView
  - 职责: 全局加载状态页面

## 子模块索引 (L2.5)

核心模块详细文档:
- [Login/CLAUDE.md](Login/CLAUDE.md) - 登录页面
- [Tutorial/CLAUDE.md](Tutorial/CLAUDE.md) - 拍摄教程
- [BaziResult/CLAUDE.md](BaziResult/CLAUDE.md) - 八字结果展示

## 路由映射

在 App.tsx 中定义的路由:
- `/login` → Login/LoginView
- `/onboarding/name` → NameEntry/NameEntryView
- `/onboarding/birthday` → BirthdayInput/BirthdayInputView
- `/onboarding/time` → BirthTimeInput/BirthTimeInputView
- `/onboarding/location` → BirthLocationInput/BirthLocationInputView
- `/onboarding/gender` → GenderSelection/GenderSelectionView
- `/onboarding/result` → BaziResult/BaziResultView
- `/main` → MainDashboard/MainDashboardView
- `/tutorial` → Tutorial/TutorialView
- `/capture` → Capture/CaptureView
- `/capture/complete` → CaptureComplete/CaptureCompleteView
- `/capture/orientation` → OrientationCapture/OrientationCaptureView
- `/report/preview` → Preview/PreviewView
- `/report` → Report/ReportView
- `/chat` → Chat/ChatView
- `/chat/intro` → ChatIntro/ChatIntroView

## 上游依赖

- src/stores/* (状态管理)
- src/api/* (API客户端，通过Stores调用)
- src/components/* (通用组件)
- react-router-dom (路由)

## 下游消费者

- App.tsx (路由配置)
- 无 (Features 是叶子节点，不被其他 Features 使用)

## 协议回环检查

变更此模块时必须检查:

### 1. 新增 Feature 模块
- [ ] 创建新的 `src/features/NewFeature/` 文件夹
- [ ] 创建 `NewFeatureView.tsx` 和 `NewFeatureView.module.css`
- [ ] 添加 L3 头部到 NewFeatureView.tsx
- [ ] 更新本文件成员清单
- [ ] 在 App.tsx 中添加路由
- [ ] 如复杂度高，创建 L2.5 CLAUDE.md

### 2. 删除 Feature 模块
- [ ] 从 App.tsx 删除路由
- [ ] 删除文件夹
- [ ] 更新本文件成员清单
- [ ] 检查是否有其他模块引用 (应该没有)

### 3. Feature 依赖 Store 变更
- [ ] 更新 Feature 的 L3 头部 [INPUT]
- [ ] 如需要，更新对应 L2.5 CLAUDE.md
- [ ] 检查 Store 是否需要新增 action

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
