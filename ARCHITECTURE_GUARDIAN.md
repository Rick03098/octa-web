# 分形架构守护者 - 工作流指南

本文档说明如何在 OCTA 项目中遵循"分形架构守护者"规范。

## 快速参考

### 修改代码前的检查清单

在修改任何代码前，请先：

1. ✅ 阅读根目录 `README.md` 了解项目整体架构
2. ✅ 阅读目标文件夹的 `.folder.md` 了解局部架构
3. ✅ 阅读相关文件的 IOP 注释了解文件职责

### 修改代码后的同步清单

完成代码修改后，请确认：

1. ✅ 更新了所有修改文件的 IOP 注释（如逻辑变化）
2. ✅ 更新了受影响文件夹的 `.folder.md`（如文件增删或职责变化）
3. ✅ 更新了根目录 `README.md`（如涉及全局架构变更）

## IOP 注释格式

每个文件的头部应包含三行注释：

```typescript
// [INPUT] 本文件依赖的外部接口、数据或环境变量
// [OUTPUT] 本文件对外的产出、副作用或返回对象
// [POS] 本文件在所属文件夹及系统全局中的定位
```

### 示例

**API 客户端文件**:
```typescript
// [INPUT] axios库, VITE_API_BASE_URL环境变量, localStorage中的auth_token, 后端API响应
// [OUTPUT] 配置好的axios客户端实例, 自动添加JWT token的请求拦截器, 统一错误处理的响应拦截器
// [POS] API层的核心入口，所有API调用必须通过此客户端，处理认证和错误
```

**Store 文件**:
```typescript
// [INPUT] zustand的create函数, types/models中的类型定义
// [OUTPUT] useOnboardingStore hook, 提供用户引导流程的状态管理和操作方法
// [POS] 状态管理层的核心Store，管理用户输入数据，连接UI组件和API调用
```

**View 组件文件**:
```typescript
// [INPUT] React hooks, stores中的状态管理hooks, 路由参数
// [OUTPUT] React组件JSX, 用户交互事件处理
// [POS] 特征层的UI组件，负责页面渲染和用户交互，从Stores获取数据并调用API
```

## .folder.md 格式

每个关键文件夹应包含 `.folder.md` 文件，包含以下部分：

### 地位（Role）
一句话说明该文件夹在系统中的角色。

### 逻辑（Logic）
描述该文件夹内部件如何协作，数据流向如何。

### 约束（Constraint）
说明此处严禁进行的调用或写法。

### 成员清单
列出关键文件及其"人设"（如：Gatekeeper, Translator, Logic Processor）。

## 文件夹地图位置

当前项目已创建的文件夹地图：

- `.cursorrules` - 核心规范定义
- `octa-web/.folder.md` - Web前端根目录
- `octa-web/src/.folder.md` - 源代码目录
- `octa-web/src/api/.folder.md` - API客户端层
- `octa-web/src/features/.folder.md` - 功能模块层
- `octa-web/src/stores/.folder.md` - 状态管理层
- `octa-web/src/types/.folder.md` - 类型定义层
- `octa-web/src/styles/.folder.md` - 样式系统层
- `octa-web/src/components/.folder.md` - 组件库层

## 工作流示例

### 场景1：添加新的API函数

1. **定位认知**:
   - 阅读 `octa-web/src/api/.folder.md` 了解API层规范
   - 查看现有API文件了解代码风格

2. **编写代码**:
   - 在相应的API文件中添加新函数
   - 确保使用 `client.ts` 导出的axios实例
   - 确保函数有TypeScript类型定义

3. **更新文档**:
   - 如果文件逻辑变化，更新文件头部的IOP注释
   - 如果添加了新文件，更新 `api/.folder.md` 的成员清单

### 场景2：创建新的Feature页面

1. **定位认知**:
   - 阅读 `octa-web/src/features/.folder.md` 了解Feature层规范
   - 查看现有Feature了解代码结构

2. **编写代码**:
   - 创建 `[Feature]View.tsx` 和 `[Feature]View.module.css`
   - 在 `App.tsx` 中添加路由
   - 确保使用CSS Modules和CSS变量

3. **更新文档**:
   - 为新文件添加IOP注释
   - 更新 `features/.folder.md` 的成员清单
   - 如路由变化，可能需要更新 `App.tsx` 的IOP注释

### 场景3：修改全局状态管理

1. **定位认知**:
   - 阅读 `octa-web/src/stores/.folder.md` 了解Store层规范
   - 查看现有Store了解代码模式

2. **编写代码**:
   - 修改或添加Store中的状态和方法
   - 确保类型定义正确

3. **更新文档**:
   - 更新Store文件的IOP注释
   - 如果添加了新Store文件，更新 `stores/.folder.md` 的成员清单
   - 如果状态管理架构有重大变化，可能需要更新 `src/.folder.md`

## 常见问题

### Q: 什么时候需要更新IOP注释？
A: 当文件的职责、输入或输出发生变化时。如果只是修复bug或优化代码，但职责不变，则不需要更新。

### Q: 什么时候需要更新.folder.md？
A: 当文件夹内文件增删，或文件夹的整体职责发生变化时。

### Q: 什么时候需要更新README.md？
A: 当系统整体架构发生变化时，如新增主要模块、改变技术栈等。

### Q: CSS文件也需要IOP注释吗？
A: 是的，所有文件都应该有IOP注释，包括CSS、TypeScript、配置文件等。

## 文档更新清单模板

完成任务后，请列出更新的文档：

```
## 本次更新的文档清单

- [ ] `octa-web/src/api/client.ts` - 添加IOP注释
- [ ] `octa-web/src/stores/onboardingStore.ts` - 添加IOP注释
- [ ] `octa-web/src/api/.folder.md` - 更新成员清单
```


