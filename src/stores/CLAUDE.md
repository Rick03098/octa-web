# 状态管理层 | src/stores/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位 (Module Position)

状态管理层，使用 Zustand 管理应用的全局状态，连接 API 客户端层和 UI 组件层。

**架构定位**: 位于 API 层和 UI 层之间，是数据流的中间层。所有跨组件共享的状态必须在此层管理，Features/Components 通过 hooks 订阅状态。

## 核心逻辑 (Core Logic)

### 1. 状态集中 (Centralized State)
- 所有需要跨组件共享的状态放在 Stores 中
- 避免 prop drilling (跨多层组件传递 props)
- 提供单一数据源 (Single Source of Truth)

### 2. 数据同步 (Data Synchronization)
- Stores 负责从 API 获取数据并更新状态
- Stores 处理异步逻辑 (async/await)
- Stores 统一错误处理 (try-catch)

### 3. 响应式更新 (Reactive Updates)
- UI 组件通过 `useAuthStore()` 等 hooks 订阅状态
- 状态变更时自动触发组件重新渲染
- 支持细粒度订阅 (只订阅需要的状态字段)

### 4. 类型安全 (Type Safety)
- 所有 Store 接口使用 TypeScript 定义
- 状态字段类型明确
- Action 方法参数类型化

## 架构约束 (Constraints)

### 严禁 (FORBIDDEN)
1. **严禁在 Store 中直接操作 DOM**: Store 只管理数据状态，不涉及 UI
   - ❌ `document.getElementById(...)`
   - ❌ `element.classList.add(...)`

2. **严禁在 Store 中写 UI 逻辑**: UI 渲染逻辑应在组件中
   - ❌ 在 Store 中返回 JSX
   - ❌ 在 Store 中处理事件对象 (Event)

3. **严禁 Stores 之间循环依赖**:
   - ❌ `authStore` 导入 `onboardingStore`，同时 `onboardingStore` 导入 `authStore`
   - ✅ 通过共享 API 层避免循环依赖

4. **严禁绕过 Store 直接调用 API** (在组件中):
   - ❌ `const data = await authApi.login(credentials);` (在组件中)
   - ✅ `const { login } = useAuthStore(); await login(credentials);`

### 必须 (MUST)
1. **必须使用 Zustand**: 不使用 React Context API 或其他状态管理方案
2. **必须类型化**: 所有 Store 必须定义 TypeScript 接口
3. **必须处理错误**: 所有 async action 必须 try-catch，并提供错误状态
4. **必须持久化关键状态**: 如 token 需要存储到 localStorage

## 成员清单 (Member Inventory)

### **authStore.ts** - Auth State Manager
- **依赖**:
  - zustand@5.0.9 (`create` 函数)
  - ../api/auth.ts (`authApi.login`, `authApi.register`, `authApi.logout`)
  - ../types/api.ts (`UserSession`, `LoginRequest`, `RegisterRequest`)
  - localStorage (`auth_token`, `refresh_token` 持久化)

- **导出**:
  - `useAuthStore`: Zustand hook
    - **状态**:
      - `isAuthenticated: boolean` - 用户是否已登录
      - `user: UserSession | null` - 当前用户信息
      - `token: string | null` - JWT 访问令牌
    - **方法**:
      - `login(credentials: LoginRequest): Promise<void>` - 用户登录
      - `register(data: RegisterRequest): Promise<void>` - 用户注册
      - `logout(): Promise<void>` - 用户登出
      - `checkAuth(): Promise<void>` - 检查认证状态
      - `setUser(user: UserSession | null): void` - 设置用户信息

- **职责**: 管理用户认证状态，处理登录/注册/登出逻辑

- **副作用**:
  - `login()` 成功后自动设置 `isAuthenticated = true`
  - `logout()` 清除所有状态并调用 `authApi.logout()`
  - 初始化时从 localStorage 读取 `auth_token`

- **状态生命周期**:
  ```
  初始化
    ↓
  从 localStorage 读取 token → 设置 token 状态
    ↓
  用户登录 → login() → 调用 authApi.login() → 设置 isAuthenticated/token
    ↓
  用户登出 → logout() → 调用 authApi.logout() → 清除状态
  ```

---

### **onboardingStore.ts** - Onboarding State Manager
- **依赖**:
  - zustand@5.0.9 (`create` 函数)
  - ../api/profiles.ts (`profilesApi.createProfile`)
  - ../api/analysis.ts (`analysisApi.submitAnalysis`)
  - ../types/models.ts (`BaziProfile`, `AnalysisRequest`)

- **导出**:
  - `useOnboardingStore`: Zustand hook
    - **状态**:
      - `name: string` - 用户姓名
      - `birthday: string` - 生日 (YYYY-MM-DD)
      - `birthTime: string` - 出生时间 (HH:mm)
      - `birthLocation: { lat: number, lng: number, address: string } | null` - 出生地
      - `gender: 'male' | 'female' | null` - 性别
      - `orientation: number | null` - 拍摄朝向 (0-359度)
      - `baziResult: BaziProfile | null` - 八字计算结果
    - **方法**:
      - `setName(name: string): void` - 设置姓名
      - `setBirthday(birthday: string): void` - 设置生日
      - `setBirthTime(time: string): void` - 设置出生时间
      - `setLocation(location: { lat, lng, address }): void` - 设置出生地
      - `setGender(gender: 'male' | 'female'): void` - 设置性别
      - `setOrientation(degrees: number): void` - 设置朝向
      - `submitProfile(): Promise<BaziProfile>` - 提交档案到后端
      - `submitAnalysis(): Promise<void>` - 提交风水分析请求
      - `reset(): void` - 重置所有状态

- **职责**: 管理用户引导流程中的所有输入数据

- **数据流**:
  ```
  用户输入 → setState 方法 → Store 状态更新
    ↓
  引导完成 → submitProfile() → 调用 profilesApi.createProfile() → 获取 profileId
    ↓
  拍摄完成 → submitAnalysis() → 调用 analysisApi.submitAnalysis() → 跳转到结果页
  ```

- **页面对应关系**:
  - `NameEntryView` → 调用 `setName()`
  - `BirthdayInputView` → 调用 `setBirthday()`
  - `BirthTimeInputView` → 调用 `setBirthTime()`
  - `BirthLocationInputView` → 调用 `setLocation()`
  - `GenderSelectionView` → 调用 `setGender()`
  - `OrientationCaptureView` → 调用 `setOrientation()`
  - `BaziResultView` → 调用 `submitProfile()`

---

### **index.ts** - Module Aggregator
- **依赖**: 本模块所有 Store 文件 (authStore.ts, onboardingStore.ts)
- **导出**: `useAuthStore`, `useOnboardingStore`
- **职责**: 聚合导出所有 Stores，简化导入路径
- **用途**: 允许 `import { useAuthStore, useOnboardingStore } from '@/stores'`

---

### **appStore.ts** - App State Manager (未来计划)
> ⚠️ **注意**: 此文件当前不存在，但在 `.folder.md` 中提及，计划用于管理应用全局 UI 状态。

**计划功能**:
- **状态**:
  - `theme: 'light' | 'dark'` - 主题模式
  - `language: 'zh' | 'en'` - 语言设置
  - `navigationState: object` - 导航状态
  - `currentRoute: string` - 当前路由

- **方法**:
  - `setTheme(theme): void` - 切换主题
  - `setLanguage(lang): void` - 切换语言
  - `setNavigationState(state): void` - 更新导航状态

**创建时机**: 当需要管理全局 UI 状态时 (如主题切换、语言切换)

---

## 上游依赖 (Dependencies)

### 外部依赖
- **zustand@5.0.9**: 轻量级状态管理库 (`create` 函数)

### 内部依赖
- **src/api/***: 所有 API 客户端模块
  - `authApi` (认证 API)
  - `profilesApi` (档案 API)
  - `analysisApi` (分析 API)
- **src/types/***: 类型定义
  - `UserSession`, `LoginRequest`, `RegisterRequest` (from types/api.ts)
  - `BaziProfile`, `AnalysisRequest` (from types/models.ts)

### 浏览器 API
- **localStorage**: 持久化 token

---

## 下游消费者 (Consumers)

### Features (功能页面)
- **src/features/Login/LoginView.tsx**: 使用 `useAuthStore().login()`
- **src/features/NameEntry/NameEntryView.tsx**: 使用 `useOnboardingStore().setName()`
- **src/features/BirthdayInput/BirthdayInputView.tsx**: 使用 `useOnboardingStore().setBirthday()`
- **src/features/BirthTimeInput/BirthTimeInputView.tsx**: 使用 `useOnboardingStore().setBirthTime()`
- **src/features/BirthLocationInput/BirthLocationInputView.tsx**: 使用 `useOnboardingStore().setLocation()`
- **src/features/GenderSelection/GenderSelectionView.tsx**: 使用 `useOnboardingStore().setGender()`
- **src/features/BaziResult/BaziResultView.tsx**: 使用 `useOnboardingStore().submitProfile()`
- **src/features/MainDashboard/MainDashboardView.tsx**: 使用 `useAuthStore().user`
- **src/App.tsx**: 使用 `useAuthStore().isAuthenticated` (路由守卫)

### Components (通用组件)
- 部分组件可能订阅全局状态 (如 `useAuthStore().user` 显示用户头像)

---

## Store 状态生命周期详解 (State Lifecycle)

### authStore 生命周期

```
[应用启动]
    ↓
初始化 authStore → 从 localStorage 读取 auth_token → 设置 token 状态
    ↓
检查认证状态 → checkAuth() (如有 token) → 验证 token 有效性
    ↓
┌─────────────────────────────────────────┐
│  [用户未登录]            [用户已登录]    │
│      ↓                        ↓          │
│  显示登录页              显示主应用      │
│      ↓                        ↓          │
│  输入账号密码            浏览/使用功能   │
│      ↓                        ↓          │
│  调用 login()            点击登出         │
│      ↓                        ↓          │
│  后端验证成功            调用 logout()    │
│      ↓                        ↓          │
│  设置 isAuthenticated   清除状态          │
│      ↓                        ↓          │
│  跳转到主界面            跳转到登录页     │
│      └────────────────────────┘          │
└───────────────────────────────────────────┘
```

### onboardingStore 生命周期

```
[用户引导开始]
    ↓
初始化 onboardingStore → 所有状态为空/null
    ↓
NameEntryView → setName('张三')
    ↓
BirthdayInputView → setBirthday('1990-01-01')
    ↓
BirthTimeInputView → setBirthTime('08:30')
    ↓
BirthLocationInputView → setLocation({ lat: 39.9, lng: 116.4, address: '北京' })
    ↓
GenderSelectionView → setGender('male')
    ↓
[提交档案]
    ↓
submitProfile() → 调用 profilesApi.createProfile() → 后端计算八字
    ↓
后端返回 BaziProfile → 设置 baziResult 状态
    ↓
BaziResultView 显示八字结果 (4页滑动展示)
    ↓
[进入拍摄流程]
    ↓
OrientationCaptureView → setOrientation(180)
    ↓
[提交分析]
    ↓
submitAnalysis() → 调用 analysisApi.submitAnalysis()
    ↓
跳转到报告预览页
    ↓
[分析完成] → reset() → 清空所有状态 (准备下一次引导)
```

---

## Zustand 使用模式 (Usage Patterns)

### 1. 基本订阅 (订阅所有状态)
```typescript
function LoginView() {
  const { isAuthenticated, login } = useAuthStore();
  // 组件会在 isAuthenticated 或 login 变化时重新渲染
}
```

### 2. 细粒度订阅 (只订阅特定状态)
```typescript
function UserAvatar() {
  const user = useAuthStore((state) => state.user);
  // 只在 user 变化时重新渲染，login/logout 变化不触发渲染
}
```

### 3. 订阅多个字段
```typescript
function ProfileSummary() {
  const { name, birthday, gender } = useOnboardingStore((state) => ({
    name: state.name,
    birthday: state.birthday,
    gender: state.gender,
  }));
  // 只在这三个字段变化时重新渲染
}
```

### 4. 仅调用方法 (不订阅状态)
```typescript
function LogoutButton() {
  const logout = useAuthStore((state) => state.logout);
  // 不订阅状态，logout 方法引用不变，组件不会因状态变化重新渲染
}
```

---

## 错误处理策略 (Error Handling Strategy)

### Store 层职责
- ✅ 使用 try-catch 捕获 API 错误
- ✅ 提供错误状态给 UI 组件
- ✅ 记录错误日志 (console.error)

### 错误状态模式
```typescript
interface StoreWithError {
  error: string | null;
  isLoading: boolean;

  someAction: async () => {
    set({ isLoading: true, error: null });
    try {
      await apiCall();
      set({ isLoading: false });
    } catch (error) {
      set({
        isLoading: false,
        error: error.message || '操作失败'
      });
    }
  };
}
```

### UI 层处理
```typescript
function LoginView() {
  const { login, error } = useAuthStore();

  const handleLogin = async () => {
    try {
      await login(credentials);
      navigate('/main');
    } catch (error) {
      // 显示错误提示
      alert('登录失败，请检查账号密码');
    }
  };
}
```

---

## 持久化策略 (Persistence Strategy)

### 当前实现
- `authStore`: token 手动存储到 localStorage
- `onboardingStore`: 不持久化 (用户引导流程一次性)

### 未来增强
可使用 Zustand 的 `persist` 中间件:
```typescript
import { persist } from 'zustand/middleware';

export const useAuthStore = create(
  persist(
    (set) => ({
      // store 定义
    }),
    {
      name: 'auth-storage', // localStorage key
      partialize: (state) => ({ token: state.token }), // 只持久化 token
    }
  )
);
```

---

## 协议回环检查 (Protocol Loop Check)

变更此模块时必须检查:

### 1. 新增 Store
- [ ] 创建新的 `src/stores/newStore.ts` 文件
- [ ] 添加 L3 头部 ([INPUT]/[OUTPUT]/[POS]/[PROTOCOL])
- [ ] 在 `src/stores/index.ts` 中导出
- [ ] 更新本文件 **成员清单** (添加新 Store 说明)
- [ ] 更新 `/CLAUDE.md` L2 模块索引 (如有重大变更)
- [ ] 在对应 Features 中使用新 Store

### 2. Store 新增 Action
- [ ] 更新对应 Store 文件 (如 `authStore.ts`)
- [ ] 更新文件 L3 头部 [OUTPUT] 部分 (添加新方法)
- [ ] 更新本文件 **成员清单** 中的方法列表
- [ ] 检查所有调用方是否需要使用新 Action
- [ ] 考虑是否需要新增类型定义 (src/types/*)

### 3. Store 依赖新 API
- [ ] 在 Store 文件中导入新 API 模块
- [ ] 更新文件 L3 头部 [INPUT] 部分
- [ ] 更新本文件 **成员清单** 中的依赖列表
- [ ] 检查 `src/api/CLAUDE.md` 是否已文档化新 API

### 4. 状态结构变更
- [ ] 更新 Store 接口定义 (如 `AuthState`)
- [ ] 更新 `src/types/` 中的相关类型 (如需要)
- [ ] 检查所有使用该状态的组件 (TypeScript 会报错)
- [ ] 更新本文件 **成员清单** 中的状态字段列表

### 5. 删除 Store 或 Action
- [ ] 使用 `grep` 搜索所有调用方
- [ ] 确认无调用方后删除
- [ ] 从 `src/stores/index.ts` 删除导出
- [ ] 更新本文件 **成员清单** (删除说明)
- [ ] 更新文件 L3 头部 [OUTPUT] 部分

---

## 测试建议 (Testing Recommendations)

### 单元测试 (未来实施)
- 测试 Store 的 action 逻辑 (mock API 调用)
- 测试状态更新是否正确
- 测试错误处理逻辑

### 集成测试
- 在组件中测试 Store hook 的完整流程
- 测试多个组件订阅同一 Store 的状态同步
- 测试 Store 调用 API 的完整流程

### 手动测试
- 使用 React DevTools 查看 Store 状态变化
- 使用浏览器控制台手动调用 Store 方法
- 验证 localStorage 持久化是否正确

---

## 常见问题 (FAQ)

### Q1: 为什么使用 Zustand 而不是 Redux?
**A**: Zustand 更轻量级，API 更简洁:
- 不需要 actions/reducers 模板代码
- 支持 TypeScript 类型推断
- 不需要 Provider 包裹
- 性能更好 (更少的重新渲染)

### Q2: 如何避免 Stores 之间循环依赖?
**A**:
- 方案 1: 通过共享 API 层通信 (Store A → API → Store B 订阅)
- 方案 2: 将共享逻辑提取到独立的 utils 函数
- 方案 3: 考虑是否 Store 划分不合理，需要重构

### Q3: 何时应该创建新的 Store?
**A**: 满足以下任一条件:
- 状态需要跨多个不相关的组件共享
- 状态需要持久化 (localStorage/sessionStorage)
- 状态需要与 API 交互
- 状态逻辑复杂，不适合放在组件内部

### Q4: 如何调试 Store 状态?
**A**:
- React DevTools → Components 面板 → 找到使用 Store 的组件 → 查看 hooks 状态
- 在 Store 的 `set()` 方法中添加 `console.log`
- 使用 Zustand DevTools 中间件 (可选)

---

## 版本历史 (Version History)

- **2026-01-18**: L2 状态管理层文档初始创建
  - 定义 2 个核心 Store (authStore, onboardingStore)
  - 确立 Store 层架构约束和数据流规则
  - 创建详细的状态生命周期和使用模式说明
  - 备注 appStore.ts 为未来计划功能

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
