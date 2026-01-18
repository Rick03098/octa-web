# API 客户端层 | src/api/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位 (Module Position)

API 客户端层，负责封装所有与后端的 HTTP 通信，处理认证、错误和响应转换。

**架构定位**: 位于数据流的最上游，是前端与后端通信的唯一桥梁。所有网络请求必须通过此层，不允许在 Features 或 Components 中直接使用 axios。

## 核心逻辑 (Core Logic)

### 1. 统一入口 (Single Entry Point)
- `client.ts` 提供配置好的 axios 实例 (`api` 对象)
- 所有 HTTP 方法 (GET/POST/PUT/PATCH/DELETE) 统一封装
- 自动处理请求头、超时、响应格式

### 2. 模块化划分 (Domain-Driven Organization)
- 按后端 API 模块划分：auth (认证)、profiles (档案)、analysis (分析)、users (用户)
- 每个模块独立文件，职责单一
- 通过 `index.ts` 统一导出，简化导入路径

### 3. 类型安全 (Type Safety)
- 所有 API 函数使用 TypeScript 类型标注
- 请求参数类型与后端 Pydantic 模型对应
- 响应类型明确，支持 IDE 智能提示

### 4. 自动处理 (Automatic Handling)
- **请求拦截器**: 自动从 `localStorage` 读取 `auth_token`，添加到 `Authorization` 头部
- **响应拦截器**: 统一处理 401 错误 (清除 token，重定向到登录页)
- **响应数据提取**: 自动返回 `response.data`，简化调用方代码

## 架构约束 (Constraints)

### 严禁 (FORBIDDEN)
1. **严禁直接使用 axios**: 所有请求必须通过 `client.ts` 导出的 `api` 实例
   - ❌ `import axios from 'axios'; axios.get(...)`
   - ✅ `import { api } from './api/client'; api.get(...)`

2. **严禁在组件中直接调用**: Components/Features 必须通过 Stores 调用 API
   - ❌ `const data = await authApi.login(credentials);` (在组件中)
   - ✅ `const { login } = useAuthStore(); await login(credentials);` (通过 Store)

3. **严禁硬编码 URL**: 使用 `VITE_API_BASE_URL` 环境变量
   - ❌ `baseURL: 'http://localhost:8000'`
   - ✅ `baseURL: import.meta.env.VITE_API_BASE_URL`

4. **严禁无类型 API 调用**: 所有 API 响应必须有对应的 TypeScript 类型
   - ❌ `api.get('/users/me')`
   - ✅ `api.get<UserProfile>('/users/me')`

### 必须 (MUST)
1. **必须类型化**: 所有 API 函数必须定义请求参数类型和返回类型
2. **必须处理错误**: 所有 API 调用必须在 Store 层 try-catch，不在此层处理业务错误
3. **必须保持同步**: API 类型定义必须与后端 Pydantic 模型同步

## 成员清单 (Member Inventory)

### 核心基础设施

#### **client.ts** - HTTP Gatekeeper
- **依赖**:
  - axios@1.13.2 (AxiosInstance, AxiosError, InternalAxiosRequestConfig)
  - import.meta.env.VITE_API_BASE_URL (环境变量)
  - localStorage.auth_token (JWT 访问令牌)
  - localStorage.refresh_token (JWT 刷新令牌)
  - src/types/api.ts (ApiError 类型)

- **导出**:
  - `api` 对象: 包含 `get<T>()`, `post<T>()`, `put<T>()`, `patch<T>()`, `delete<T>()` 方法
  - `apiClient`: axios 实例 (默认导出，向后兼容)

- **职责**:
  - Axios 客户端配置 (baseURL, timeout, headers)
  - 请求拦截器: 自动添加 `Authorization: Bearer {token}` 头部
  - 响应拦截器: 提取 `response.data`，处理 401 错误

- **参数**:
  - baseURL: `VITE_API_BASE_URL || 'http://localhost:8000'`
  - timeout: 30000ms (30秒)
  - headers: `{ 'Content-Type': 'application/json' }`

- **副作用**:
  - 401 错误时清除 `auth_token` 和 `refresh_token`
  - 401 错误时重定向到 `/login` (如当前不在登录页)

#### **index.ts** - Module Aggregator
- **依赖**: 本模块所有 API 文件 (client.ts, auth.ts, profiles.ts, analysis.ts, users.ts)
- **导出**: `api`, `apiClient`, `authApi`, `profilesApi`, `analysisApi`, `usersApi`
- **职责**: 聚合导出所有 API 客户端，简化导入路径
- **用途**: 允许 `import { authApi, profilesApi } from '@/api'` 而非 `from '@/api/auth'`

---

### 领域 API 模块

#### **auth.ts** - Auth API Translator
- **依赖**:
  - ./client.ts (api 对象)
  - ../types/api.ts (RegisterRequest, LoginRequest, AuthRegisterResponse, AuthLoginResponse, AuthRefreshResponse, TokenResponse)
  - localStorage (存储 token)

- **导出**:
  - `authApi` 对象:
    - `register(data: RegisterRequest): Promise<AuthRegisterResponse>` - 用户注册
    - `login(data: LoginRequest): Promise<AuthLoginResponse>` - 用户登录
    - `refresh(refreshToken: string): Promise<AuthRefreshResponse>` - 刷新 token
    - `logout(): Promise<void>` - 用户登出

- **职责**: 封装所有认证相关的 API 调用

- **端点**:
  - `POST /v1/auth/register` - 注册新用户
  - `POST /v1/auth/login` - 用户登录
  - `POST /v1/auth/refresh` - 刷新访问令牌
  - `POST /v1/auth/logout` - 用户登出

- **副作用**:
  - `login()` 成功后自动保存 `access_token` 和 `refresh_token` 到 localStorage
  - `logout()` 成功后自动清除 localStorage 中的 token

#### **profiles.ts** - Profiles API Translator
- **依赖**:
  - ./client.ts (api 对象)
  - ../types/models.ts (BaziProfile, CreateProfileRequest, UpdateProfileRequest)

- **导出**:
  - `profilesApi` 对象:
    - `createProfile(data: CreateProfileRequest): Promise<BaziProfile>` - 创建八字档案
    - `getProfiles(): Promise<BaziProfile[]>` - 获取当前用户所有档案
    - `getProfile(id: string): Promise<BaziProfile>` - 获取单个档案详情
    - `updateProfile(id: string, data: UpdateProfileRequest): Promise<BaziProfile>` - 更新档案
    - `deleteProfile(id: string): Promise<void>` - 删除档案

- **职责**: 封装八字档案相关的 CRUD 操作

- **端点**:
  - `POST /v1/profiles` - 创建档案
  - `GET /v1/profiles` - 获取档案列表
  - `GET /v1/profiles/{id}` - 获取档案详情
  - `PUT /v1/profiles/{id}` - 更新档案
  - `DELETE /v1/profiles/{id}` - 删除档案

#### **analysis.ts** - Analysis API Translator
- **依赖**:
  - ./client.ts (api 对象)
  - ../types/models.ts (AnalysisResult, AnalysisRequest, AnalysisStatus)

- **导出**:
  - `analysisApi` 对象:
    - `submitAnalysis(data: AnalysisRequest): Promise<AnalysisResult>` - 提交风水分析请求
    - `getAnalysis(id: string): Promise<AnalysisResult>` - 获取分析结果
    - `getAnalysisList(profileId?: string): Promise<AnalysisResult[]>` - 获取分析历史
    - `retryAnalysis(id: string): Promise<AnalysisResult>` - 重试失败的分析

- **职责**: 封装风水分析相关的 API 调用

- **端点**:
  - `POST /v1/analysis` - 提交分析
  - `GET /v1/analysis/{id}` - 获取分析结果
  - `GET /v1/analysis` - 获取分析列表
  - `POST /v1/analysis/{id}/retry` - 重试分析

#### **users.ts** - Users API Translator
- **依赖**:
  - ./client.ts (api 对象)
  - ../types/api.ts (UserProfile, UpdateUserProfileRequest)

- **导出**:
  - `usersApi` 对象:
    - `getProfile(): Promise<UserProfile>` - 获取当前用户资料
    - `updateProfile(data: UpdateUserProfileRequest): Promise<UserProfile>` - 更新用户资料

- **职责**: 封装用户资料相关的 API 调用

- **端点**:
  - `GET /v1/users/me` - 获取当前用户信息
  - `PUT /v1/users/me` - 更新当前用户信息

---

## 上游依赖 (Dependencies)

### 外部依赖
- **axios@1.13.2**: HTTP 客户端库
- **import.meta.env.VITE_API_BASE_URL**: 环境变量 (后端 API 基础 URL)

### 内部依赖
- **src/types/api.ts**: API 通信类型定义 (请求、响应、错误)
- **src/types/models.ts**: 业务模型类型定义 (与后端 Pydantic 模型同步)

### 浏览器 API
- **localStorage**: 存储和读取 JWT token

---

## 下游消费者 (Consumers)

### 直接消费者 (Stores)
- **src/stores/authStore.ts**: 调用 `authApi` (login, register, logout, refresh)
- **src/stores/onboardingStore.ts**: 调用 `profilesApi` (createProfile) 和 `analysisApi` (submitAnalysis)
- **src/stores/appStore.ts**: 调用 `usersApi` (getProfile, updateProfile)

### 间接消费者 (通过 Stores)
- **src/features/Login/LoginView.tsx**: 通过 `authStore` 调用登录 API
- **src/features/NameEntry/NameEntryView.tsx**: 通过 `onboardingStore` 保存姓名
- **src/features/MainDashboard/MainDashboardView.tsx**: 通过 `appStore` 获取用户信息
- **其他所有 Features**: 均通过 Stores 间接使用 API

---

## 数据流示意图 (Data Flow)

```
后端 API (http://localhost:8000)
    ↕
client.ts (axios 实例 + 拦截器)
    ↕
auth.ts / profiles.ts / analysis.ts / users.ts (领域 API 模块)
    ↕
index.ts (统一导出)
    ↕
src/stores/* (Zustand stores)
    ↕
src/features/* / src/components/* (UI 组件)
```

**约束**: 箭头只能单向流动，不允许 Features/Components 直接调用 API。

---

## 错误处理策略 (Error Handling Strategy)

### API 层职责
- ✅ 处理 HTTP 错误 (401 自动登出)
- ✅ 统一响应格式 (提取 response.data)
- ❌ 不处理业务错误 (如"用户名已存在"等)

### Store 层职责
- ✅ 使用 try-catch 捕获 API 错误
- ✅ 处理业务错误，更新状态或显示错误消息
- ✅ 提供错误状态给 UI 组件

### UI 层职责
- ✅ 显示错误消息给用户
- ✅ 提供重试机制 (如点击重新加载)

---

## 类型同步协议 (Type Sync Protocol)

### 与后端同步规则
1. **后端 Pydantic 模型变更** → 必须同步更新 `src/types/models.ts`
2. **后端 API 端点变更** → 必须同步更新对应 API 模块函数
3. **后端响应格式变更** → 必须同步更新 TypeScript 类型定义

### 同步检查清单
- [ ] 后端 `schemas/bazi.py` → 前端 `types/models.ts` (BaziProfile)
- [ ] 后端 `schemas/analysis.py` → 前端 `types/models.ts` (AnalysisResult)
- [ ] 后端 `schemas/auth.py` → 前端 `types/api.ts` (LoginRequest, RegisterRequest, TokenResponse)
- [ ] 后端 `schemas/user.py` → 前端 `types/api.ts` (UserProfile)

### 同步工具
- 手动对照后端 Pydantic 模型更新 (当前方式)
- 未来可考虑: 自动生成工具 (如 openapi-typescript)

---

## 协议回环检查 (Protocol Loop Check)

变更此模块时必须检查:

### 1. 新增 API 函数
- [ ] 更新对应 API 模块文件 (如 `auth.ts`)
- [ ] 更新本文件 **成员清单** (添加新函数说明)
- [ ] 检查 `src/types/` 是否需要新增类型
- [ ] 检查下游 Stores 是否需要新增 action
- [ ] 更新 L3 文件头部 [OUTPUT] 部分

### 2. 修改 API 类型
- [ ] 更新 `src/types/api.ts` 或 `src/types/models.ts`
- [ ] 检查所有调用方 (使用 TypeScript 编译器发现类型错误)
- [ ] 更新本文件 **成员清单** 中的类型说明
- [ ] 更新 L3 文件头部 [INPUT] 部分

### 3. 修改 baseURL 或环境变量
- [ ] 更新 `.env` 文件
- [ ] 通知团队更新本地配置
- [ ] 更新 `/CLAUDE.md` 环境变量章节
- [ ] 更新 `DEPLOYMENT_GUIDE.md` (如有生产环境变更)

### 4. 新增拦截器逻辑
- [ ] 更新 `client.ts`
- [ ] 更新本文件 **client.ts 成员说明** (副作用部分)
- [ ] 考虑影响: 所有 API 调用都会经过新拦截器
- [ ] 在 Stores 中测试相关场景

### 5. 删除 API 函数
- [ ] 检查所有调用方 (使用 `grep` 搜索函数名)
- [ ] 从对应 API 模块文件删除
- [ ] 更新本文件 **成员清单** (删除说明)
- [ ] 更新 L3 文件头部 [OUTPUT] 部分

---

## 测试建议 (Testing Recommendations)

### 单元测试 (未来实施)
- 测试 `client.ts` 拦截器逻辑 (401 处理、token 添加)
- 测试各 API 模块函数的请求参数和响应格式
- Mock axios 避免实际网络请求

### 集成测试
- 在 Stores 中测试 API 调用的完整流程
- 测试错误处理 (网络错误、401 错误、业务错误)
- 测试 token 刷新机制

### 手动测试
- 使用浏览器 DevTools 网络面板查看请求/响应
- 验证 Authorization 头部正确添加
- 验证 401 错误时正确重定向到登录页

---

## 环境变量配置 (Environment Variables)

### 开发环境 (.env.local)
```bash
VITE_API_BASE_URL=http://localhost:8000
```

### 生产环境 (.env.production)
```bash
VITE_API_BASE_URL=https://api.octa.example.com
```

### Vercel 部署
在 Vercel 项目设置中配置环境变量:
- Key: `VITE_API_BASE_URL`
- Value: `https://api.octa.example.com`

---

## 常见问题 (FAQ)

### Q1: 为什么不能在组件中直接调用 API?
**A**: 违反架构约束。数据流必须是 `API → Store → Component`，这样可以:
- 集中管理状态
- 统一错误处理
- 避免组件直接依赖后端接口
- 便于测试和重构

### Q2: 如何处理 token 过期?
**A**: 当前策略是 401 错误时清除 token 并重定向登录。未来可实现:
- 自动使用 `refresh_token` 刷新 `access_token`
- 在请求失败时重试一次 (刷新 token 后)

### Q3: 如何添加新的 API 模块?
**A**: 按照以下步骤:
1. 创建 `src/api/newmodule.ts`
2. 定义 API 函数和类型
3. 在 `src/api/index.ts` 中导出
4. 更新本文件成员清单
5. 在对应 Store 中调用

### Q4: 如何调试 API 调用?
**A**:
- 浏览器 DevTools → Network 面板查看请求/响应
- 在 `client.ts` 拦截器中添加 `console.log` (调试完后删除)
- 使用 Postman/Insomnia 测试后端 API

---

## 版本历史 (Version History)

- **2026-01-18**: L2 API 客户端层文档初始创建
  - 定义 6 个 API 模块 (client, auth, profiles, analysis, users, index)
  - 确立 API 层架构约束和数据流规则
  - 创建详细的成员清单和类型同步协议

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
