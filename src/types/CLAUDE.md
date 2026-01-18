# 类型定义层 | src/types/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位

TypeScript 类型定义层，提供前端应用所有的类型声明，与后端 Pydantic 模型保持同步。

## 核心逻辑

- **类型安全**: 为所有 API 调用、状态管理提供 TypeScript 类型
- **前后端同步**: 与后端 Pydantic 模型一一对应
- **IDE 支持**: 提供完整的智能提示和类型检查

## 架构约束

### 严禁
- **严禁定义与后端不一致的类型**: 必须与后端 Pydantic 模型同步
- **严禁使用 `any` 类型**: 必须明确类型定义
- **严禁在类型文件中写实现代码**: 只允许 type/interface 定义

### 必须
- **必须与后端同步**: 后端模型变更时必须同步更新
- **必须导出所有类型**: 供其他模块使用
- **必须注释复杂类型**: 说明字段含义

## 成员清单

### **api.ts** - API Communication Types
- **依赖**: 无 (纯类型定义)
- **导出**:
  - `ApiError` - API 错误响应结构
  - `LoginRequest` - 登录请求体
  - `RegisterRequest` - 注册请求体
  - `AuthLoginResponse` - 登录响应
  - `AuthRegisterResponse` - 注册响应
  - `AuthRefreshResponse` - Token 刷新响应
  - `TokenResponse` - Token 结构
  - `UserSession` - 用户会话信息
  - `UserProfile` - 用户资料
  - `UpdateUserProfileRequest` - 更新用户资料请求
- **职责**: 定义所有 API 通信相关类型
- **同步源**: 后端 `schemas/auth.py`, `schemas/user.py`

### **models.ts** - Business Domain Models
- **依赖**: 无 (纯类型定义)
- **导出**:
  - `BaziProfile` - 八字档案模型
  - `CreateProfileRequest` - 创建档案请求
  - `UpdateProfileRequest` - 更新档案请求
  - `AnalysisResult` - 风水分析结果
  - `AnalysisRequest` - 分析请求
  - `AnalysisStatus` - 分析状态枚举
  - `BaziElement` - 八字五行元素
  - `BaziGan` - 天干
  - `BaziZhi` - 地支
- **职责**: 定义所有业务领域模型
- **同步源**: 后端 `schemas/bazi.py`, `schemas/analysis.py`

### **common.ts** - Common Types & Enums
- **依赖**: 无 (纯类型定义)
- **导出**:
  - `Gender` - 性别枚举
  - `Language` - 语言枚举
  - `Theme` - 主题枚举
  - `LoadingState` - 加载状态
  - `Coordinates` - 地理坐标
- **职责**: 定义通用类型和枚举
- **同步源**: 前端自定义

### **index.ts** - Type Aggregator
- **依赖**: 本模块所有类型文件
- **导出**: 聚合导出所有类型
- **职责**: 简化导入路径

## 上游依赖

- 后端 Pydantic 模型 (schemas/*)

## 下游消费者

- src/api/* (API 函数参数和返回类型)
- src/stores/* (Store 状态类型)
- src/features/* (组件 props 类型)
- src/components/* (组件 props 类型)

## 类型同步协议

### 同步规则
1. 后端 Pydantic 模型变更 → 必须同步更新前端类型
2. 字段名必须完全一致 (camelCase vs snake_case 遵循各自语言规范)
3. 可选字段使用 `?` 标记
4. 枚举值必须一致

### 同步检查清单
- [ ] `schemas/bazi.py` → `types/models.ts` (BaziProfile)
- [ ] `schemas/analysis.py` → `types/models.ts` (AnalysisResult)
- [ ] `schemas/auth.py` → `types/api.ts` (LoginRequest, TokenResponse)
- [ ] `schemas/user.py` → `types/api.ts` (UserProfile)

## 协议回环检查

变更此模块时必须检查:

### 1. 新增类型
- [ ] 添加到对应文件 (api.ts/models.ts/common.ts)
- [ ] 在 index.ts 中导出
- [ ] 更新本文件成员清单
- [ ] 检查是否需要同步后端

### 2. 修改类型
- [ ] 检查所有使用该类型的代码 (TypeScript 会报错)
- [ ] 更新本文件成员清单
- [ ] 确认与后端同步

### 3. 删除类型
- [ ] 使用 `grep` 搜索所有引用
- [ ] 确认无引用后删除
- [ ] 从 index.ts 删除导出
- [ ] 更新本文件成员清单

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
