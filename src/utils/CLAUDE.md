# 工具函数层 | src/utils/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18

## 模块定位

工具函数层，提供纯函数工具集，不依赖外部状态，可复用于任何模块。

## 核心逻辑

- **纯函数**: 所有工具函数无副作用
- **单一职责**: 每个函数只做一件事
- **类型安全**: 完整的 TypeScript 类型定义

## 架构约束

### 严禁
- **严禁有副作用**: 不修改外部状态，不调用 API
- **严禁依赖 DOM**: 工具函数应可在 Node 环境运行
- **严禁业务逻辑**: 只提供通用工具函数

### 必须
- **必须纯函数**: 相同输入必须产生相同输出
- **必须类型安全**: 完整的参数和返回类型
- **必须可测试**: 易于单元测试

## 成员清单

### **gradients.ts** - Gradient Utilities
- **依赖**: src/styles/variables.css (渐变值来源)
- **导出**: `getGradient(pageName: string): string`
- **职责**: 根据页面名返回对应的 CSS 渐变字符串
- **支持页面**: login, onboarding, dashboard, tutorial, capture, report

### **imageUtils.ts** - Image Processing Utilities
- **依赖**: 无
- **导出**: 图片处理相关函数
- **职责**: 图片压缩、格式转换、尺寸调整

## 上游依赖

- src/styles/variables.css (部分工具函数引用 CSS 变量)

## 下游消费者

- src/features/* (功能页面使用工具函数)
- src/components/* (组件使用工具函数)

## 协议回环检查

变更此模块时必须检查:

### 1. 新增工具函数
- [ ] 创建或更新对应工具文件
- [ ] 添加完整类型定义
- [ ] 添加 JSDoc 注释
- [ ] 更新本文件成员清单

### 2. 修改函数签名
- [ ] 检查所有调用方 (TypeScript 会报错)
- [ ] 更新 JSDoc 注释
- [ ] 更新本文件成员清单

### 3. 删除工具函数
- [ ] 使用 `grep` 搜索所有调用方
- [ ] 确认无调用方后删除
- [ ] 更新本文件成员清单

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
