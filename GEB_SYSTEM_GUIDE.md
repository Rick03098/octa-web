# GEB 分形文档系统 - 使用指南
# OCTA Web Frontend Project

**版本**: 1.0
**更新日期**: 2026-01-18
**适用对象**: 开发者 & AI Agent

---

## 📚 目录

1. [什么是 GEB 分形文档系统](#什么是-geb-分形文档系统)
2. [快速开始](#快速开始)
3. [文档层级说明](#文档层级说明)
4. [开发者指南](#开发者指南)
5. [AI Agent 指南](#ai-agent-指南)
6. [维护规范](#维护规范)
7. [工具使用](#工具使用)
8. [常见问题](#常见问题)

---

## 什么是 GEB 分形文档系统

### 核心理念

**GEB = Gödel, Escher, Bach (哥德尔、埃舍尔、巴赫)**

借鉴《GEB：一条永恒的金带》中的递归和自指思想，GEB 分形文档系统是一个**自相似、多层级、自我验证**的文档架构：

```
代码是机器相 (Code)     ← 供计算机执行
文档是语义相 (Docs)     ← 供人类/AI理解
两相必须同构 (Isomorphic) ← 任一相变化，另一相必须同步
```

### 分形特性

**分形自相似性** - 每一层都遵循相同的结构模式：

```
L1 (项目宪法)
  ↓ 折叠 (Fold)
L2 (模块地图)
  ↓ 折叠
L2.5 (子模块地图)
  ↓ 折叠
L3 (文件契约)
  ↓ 折叠
Code (源代码)
```

### 三大原则

1. **同构性 (Isomorphism)**
   - 代码变更 → 文档必须更新
   - 文档过时 = 系统失忆 = 技术债务

2. **可导航性 (Navigability)**
   - 从 L1 开始，任何人都能找到任何代码
   - 从任何代码，都能追溯到 L1

3. **自验证性 (Self-verification)**
   - 文档中嵌入协议检查规则
   - 工具自动验证文档与代码同步

---

## 快速开始

### 5 分钟理解项目架构

```bash
# Step 1: 阅读 L1 项目宪法
cat CLAUDE.md

# Step 2: 查看所有模块
ls -la src/*/CLAUDE.md

# Step 3: 深入某个模块 (例如 API 层)
cat src/api/CLAUDE.md

# Step 4: 查看具体文件
head -20 src/api/client.ts  # 查看 L3 头部注释
```

### 文档导航路径

```
想了解项目整体？
  → 阅读 /CLAUDE.md (L1)

想了解某个模块？
  → 阅读 src/[module]/CLAUDE.md (L2)

想了解复杂功能？
  → 阅读 src/features/[Feature]/CLAUDE.md (L2.5)

想了解某个文件？
  → 查看文件顶部 L3 头部注释
```

---

## 文档层级说明

### L1: 项目宪法 (`/CLAUDE.md`)

**作用**: 项目的"操作系统手册"

**包含内容**:
- 项目本质和核心价值
- 技术栈版本清单 (精确到 patch 版本)
- 完整目录树与职责说明
- 配置文件用途
- 架构约束和数据流规则
- L2 模块索引
- GEB 协议说明

**何时阅读**:
- 新加入项目时
- 进行架构级别重构时
- 需要理解技术栈选型时

**何时更新**:
- 技术栈版本升级
- 新增/删除顶层模块
- 架构约束变更

---

### L2: 模块地图 (`src/*/CLAUDE.md`)

**作用**: 模块的"使用说明书"

**包含内容**:
- 模块定位 (在架构中的位置和职责)
- 核心逻辑 (工作原理)
- 架构约束 (严禁/必须规则)
- 成员清单 (模块内所有文件详细说明)
- 上游依赖和下游消费者
- 协议回环检查规则

**何时阅读**:
- 需要使用该模块时
- 需要修改该模块时
- 需要理解模块间依赖时

**何时更新**:
- 新增/删除模块内文件
- 文件职责变更
- 依赖关系变更

**本项目的 L2 模块** (8 个):
1. `src/api/CLAUDE.md` - API 客户端层
2. `src/stores/CLAUDE.md` - 状态管理层
3. `src/types/CLAUDE.md` - 类型定义层
4. `src/styles/CLAUDE.md` - 样式系统
5. `src/utils/CLAUDE.md` - 工具函数层
6. `src/constants/CLAUDE.md` - 常量定义层
7. `src/features/CLAUDE.md` - 功能模块层
8. `src/components/CLAUDE.md` - 组件库层

---

### L2.5: 子模块地图 (`src/[module]/[SubModule]/CLAUDE.md`)

**作用**: 复杂子模块的"详细说明"

**创建标准** (满足任一):
- 文件数量 ≥ 4 个
- 有内部子文件夹结构
- 已有 README.md
- 复杂度高 (如多页滑动、相机控制)

**何时阅读**:
- 需要理解复杂功能实现时
- 需要修改子模块内部逻辑时

**何时更新**:
- 子模块内文件变更
- 内部逻辑重构

**本项目的 L2.5 模块** (6 个):
1. `src/features/Login/CLAUDE.md` - 登录页面
2. `src/features/BaziResult/CLAUDE.md` - 八字结果展示
3. `src/features/Tutorial/CLAUDE.md` - 拍摄教程
4. `src/components/BottomNavigation/CLAUDE.md` - 底部导航栏
5. `src/components/GlassSearchButton/CLAUDE.md` - 毛玻璃搜索按钮
6. `src/components/ReportBottomTabBar/CLAUDE.md` - 报告底部标签栏

---

### L3: 文件契约 (文件头部注释)

**作用**: 文件的"API 文档"

**格式** (本项目采用简洁 IOP 格式):
```typescript
// [INPUT] 依赖说明
// [OUTPUT] 导出说明
// [POS] 位置说明
```

**包含信息**:
- **[INPUT]**: 该文件依赖什么 (npm包、内部模块、API、浏览器功能)
- **[OUTPUT]**: 该文件导出什么 (函数、组件、类型、常量)
- **[POS]**: 该文件在架构中的位置 (模块名、角色、与兄弟文件关系)

**何时阅读**:
- 需要使用该文件导出的功能时
- 需要理解该文件依赖关系时

**何时更新**:
- 新增/删除 import
- 新增/删除 export
- 文件职责变更

**示例**:
```typescript
// [INPUT] zustand的create函数, api/auth中的authApi, types中的认证相关类型
// [OUTPUT] useAuthStore hook, 提供用户认证状态管理和操作方法(login, logout, checkAuth等)
// [POS] 状态管理层的认证Store, 管理用户登录状态和token, 与认证API交互

import { create } from 'zustand';
import { authApi } from '../api';
// ...
```

---

## 开发者指南

### 场景 1: 理解现有代码

**目标**: 想知道某个功能是如何实现的

**步骤**:
```
1. 从 /CLAUDE.md 找到该功能所属模块
   例如: "登录功能" → src/features/

2. 阅读模块 L2 文档
   cat src/features/CLAUDE.md
   找到: Login/ - Login Gatekeeper → [详见 Login/CLAUDE.md]

3. 阅读子模块 L2.5 文档 (如果有)
   cat src/features/Login/CLAUDE.md
   找到: LoginView.tsx 文件说明

4. 打开源文件查看 L3 头部
   head -10 src/features/Login/LoginView.tsx
   了解: 依赖 authStore, 导出 LoginView 组件

5. 阅读源代码
   理解具体实现逻辑
```

---

### 场景 2: 添加新功能

**目标**: 添加一个新的功能模块

**步骤**:
```
1. 确定功能位置
   新功能 → src/features/NewFeature/

2. 创建文件和文件夹
   mkdir src/features/NewFeature
   touch src/features/NewFeature/NewFeatureView.tsx
   touch src/features/NewFeature/NewFeatureView.module.css
   touch src/features/NewFeature/index.ts

3. 添加 L3 头部 (使用 VSCode Snippet)
   打开 NewFeatureView.tsx
   输入: l3component <Tab>
   填写: 依赖、导出、位置信息

4. 更新 L2 文档
   编辑 src/features/CLAUDE.md
   在成员清单中添加:
   - **NewFeature/** - New Feature Processor
     - 依赖: [依赖列表]
     - 导出: NewFeatureView
     - 职责: [功能说明]

5. (可选) 如功能复杂，创建 L2.5 文档
   cp src/features/Login/CLAUDE.md src/features/NewFeature/CLAUDE.md
   修改内容为新功能的详细说明

6. 添加路由
   在 App.tsx 中添加路由配置

7. 提交代码
   git add .
   git commit -m "feat: 添加新功能 NewFeature"
   # pre-commit hook 会验证文档同步
```

---

### 场景 3: 修改现有模块

**目标**: 修改 API 模块，添加新的 API 函数

**步骤**:
```
1. 修改代码文件
   编辑 src/api/newmodule.ts
   添加新的 API 函数

2. 更新文件 L3 头部
   修改 [OUTPUT] 部分，添加新函数说明

3. 检查 L3 [PROTOCOL] 字段
   // [PROTOCOL] 指向: src/api/CLAUDE.md
   提示你需要更新 L2 文档

4. 更新 L2 文档
   编辑 src/api/CLAUDE.md
   在成员清单中更新 newmodule.ts 的导出说明

5. 如新增文件，更新 L2
   在成员清单中添加新文件条目

6. 提交代码
   git add src/api/newmodule.ts src/api/CLAUDE.md
   git commit -m "feat: 添加新API函数 xxx"
```

---

### 场景 4: 大规模重构

**目标**: 重构整个模块，改变架构

**步骤**:
```
1. 更新 L1 架构约束 (如有变化)
   编辑 /CLAUDE.md
   更新架构约束、数据流规则

2. 更新受影响的 L2 文档
   编辑所有受影响模块的 CLAUDE.md
   更新模块定位、核心逻辑、依赖关系

3. 更新 L2.5 文档 (如有)
   更新子模块文档

4. 批量更新 L3 头部
   使用编辑器的查找替换功能
   或编写脚本批量更新

5. 验证文档一致性
   ./pre-commit-hook.sh  # 手动运行验证脚本

6. 提交重构
   git add .
   git commit -m "refactor: 重构XXX模块架构"
```

---

## AI Agent 指南

### 理解项目架构

**第一步: 读取 L1**
```
1. 读取 /CLAUDE.md
2. 提取关键信息:
   - 技术栈版本
   - 目录树结构
   - 架构约束
   - L2 模块索引
```

**第二步: 定位目标模块**
```
根据任务需求，从 L2 模块索引找到目标模块
例如: "修改登录逻辑" → src/features/
```

**第三步: 读取 L2 模块文档**
```
1. 读取 src/features/CLAUDE.md
2. 提取:
   - 模块定位和职责
   - 架构约束 (严禁/必须)
   - 成员清单 (找到 Login/)
   - 协议回环检查规则
```

**第四步: 读取 L2.5 子模块文档 (如有)**
```
1. 读取 src/features/Login/CLAUDE.md
2. 提取:
   - 详细文件列表
   - 数据流说明
   - 路由映射
```

**第五步: 读取 L3 文件头部**
```
1. 打开 src/features/Login/LoginView.tsx
2. 读取前 10 行的 L3 头部
3. 提取:
   - [INPUT]: 依赖列表
   - [OUTPUT]: 导出内容
   - [POS]: 架构位置
```

**第六步: 阅读源代码**
```
基于以上理解，阅读具体实现逻辑
```

---

### 依赖关系分析

**向上追溯 (谁依赖我)**:
```
1. 查看文件 L3 [OUTPUT]
   例如: authApi 导出 login, register, logout

2. 在 L2 文档中查找 "下游消费者"
   src/api/CLAUDE.md → 下游: src/stores/authStore.ts

3. 读取下游文件的 L3 [INPUT]
   确认具体使用方式
```

**向下追溯 (我依赖谁)**:
```
1. 查看文件 L3 [INPUT]
   例如: 依赖 zustand@5.0.9, api/auth.ts

2. 在 L2 文档中查找 "上游依赖"
   src/stores/CLAUDE.md → 上游: src/api/*, zustand

3. 读取上游文件的 L3 [OUTPUT]
   确认提供的功能
```

---

### 变更影响评估

**问题**: 修改某个函数，会影响哪些地方？

**方法**:
```
1. 查看该函数所在文件的 L2 文档
   找到 "下游消费者" 列表

2. 逐一检查下游文件的 L3 [INPUT]
   确认是否使用了该函数

3. 使用 grep 全局搜索函数名
   grep -r "functionName" src/

4. 评估影响范围
   列出所有需要同步修改的地方
```

---

## 维护规范

### 文档同步检查清单

#### 修改代码时

**文件级别**:
- [ ] 更新文件 L3 头部的 [INPUT] (如新增/删除依赖)
- [ ] 更新文件 L3 头部的 [OUTPUT] (如新增/删除导出)
- [ ] 更新文件 L3 头部的 [POS] (如职责变更)

**模块级别**:
- [ ] 检查文件 L3 头部的 [PROTOCOL] 指向的 L2 文档
- [ ] 更新 L2 CLAUDE.md 的成员清单 (如文件增删、职责变更)
- [ ] 更新 L2 CLAUDE.md 的依赖关系 (如上游/下游变化)

**项目级别**:
- [ ] 如新增/删除顶层模块，更新 /CLAUDE.md 目录树
- [ ] 如技术栈升级，更新 /CLAUDE.md 技术栈版本
- [ ] 如架构约束变更，更新 /CLAUDE.md 架构约束章节

---

### 新增模块流程

**新增 L2 模块** (罕见):
```
1. 创建模块文件夹
   mkdir src/newmodule

2. 创建 L2 文档
   cp src/api/CLAUDE.md src/newmodule/CLAUDE.md
   修改内容为新模块说明

3. 更新 L1 文档
   编辑 /CLAUDE.md
   在目录树中添加新模块
   在 L2 模块索引中添加链接

4. 创建模块文件并添加 L3 头部
```

**新增 L2.5 子模块** (常见):
```
1. 创建子模块文件夹
   mkdir src/features/NewFeature

2. 创建 L2.5 文档
   cp src/features/Login/CLAUDE.md src/features/NewFeature/CLAUDE.md
   修改内容

3. 更新 L2 文档
   编辑 src/features/CLAUDE.md
   在成员清单中添加新子模块，并添加 L2.5 链接
   在子模块索引中添加条目

4. 创建功能文件并添加 L3 头部
```

---

### 删除模块流程

**删除文件**:
```
1. 删除源文件
   rm src/api/oldfile.ts

2. 更新 L2 文档
   编辑 src/api/CLAUDE.md
   从成员清单中删除该文件条目

3. 检查下游影响
   grep -r "oldfile" src/
   确认无其他文件引用
```

**删除子模块**:
```
1. 删除子模块文件夹
   rm -rf src/features/OldFeature

2. 删除 L2.5 文档
   rm src/features/OldFeature/CLAUDE.md

3. 更新 L2 文档
   编辑 src/features/CLAUDE.md
   从成员清单和子模块索引中删除条目

4. 更新路由
   从 App.tsx 删除对应路由
```

---

## 工具使用

### VSCode Snippet

**安装**: 已自动安装到 `.vscode/l3-header.code-snippets`

**使用方法**:
```
1. 打开 .ts 或 .tsx 文件
2. 在文件开头输入触发词
3. 按 Tab 键
4. 填写占位符
```

**可用的 Snippet**:

#### 1. `l3header` - 通用 L3 头部
```typescript
// 输入: l3header <Tab>
// 生成:
/**
 * [INPUT]:
 *   - [光标停留，填写依赖]
 *
 * [OUTPUT]:
 *   - [填写导出]
 *
 * [POS]:
 *   - [填写位置]
 *
 * [PROTOCOL]: 变更时更新此头部，然后检查 [填写路径]/CLAUDE.md
 */
```

#### 2. `l3api` - API 文件专用
```typescript
// 输入: l3api <Tab>
// 生成带有 API 模块特定结构的头部
```

#### 3. `l3store` - Store 文件专用
```typescript
// 输入: l3store <Tab>
// 生成带有 Zustand Store 特定结构的头部
```

#### 4. `l3component` - 组件文件专用
```typescript
// 输入: l3component <Tab>
// 生成带有 React 组件特定结构的头部
```

---

### Pre-commit Hook

**文件**: `pre-commit-hook.sh`

**功能**:
- ✅ 检查所有 staged .ts/.tsx 文件是否有 L3 头部
- ⚠️  检查 src/api/* 变更时是否更新了 src/api/CLAUDE.md
- ⚠️  检查 src/stores/* 变更时是否更新了 src/stores/CLAUDE.md
- ⚠️  检查 src/features/* 变更时是否更新了 src/features/CLAUDE.md
- ⚠️  检测新增/删除文件，提醒更新成员清单

**安装方法** (可选):
```bash
# 对于普通 git 仓库
chmod +x pre-commit-hook.sh
cp pre-commit-hook.sh .git/hooks/pre-commit

# 对于 git worktree (本项目)
chmod +x pre-commit-hook.sh
# 找到主仓库的 .git 目录
MAIN_REPO=$(git rev-parse --git-common-dir)
cp pre-commit-hook.sh $MAIN_REPO/hooks/pre-commit
```

**手动运行** (不安装hook也可用):
```bash
chmod +x pre-commit-hook.sh
./pre-commit-hook.sh
```

**输出示例**:
```
🔍 GEB Fractal Protocol - Pre-commit Validation
================================================

[Rule 1] Checking L3 protocol headers...
✓ All staged TypeScript files have L3 headers

[Rule 2] Checking CLAUDE.md synchronization...
✓ src/api/CLAUDE.md is being updated

[Rule 3] Checking for new/deleted files...
⚠️  New files detected:
   + src/api/newmodule.ts

   Remember to:
   1. Add L3 headers to new files
   2. Update corresponding L2 CLAUDE.md member list

================================================
⚠️  GEB Protocol Validation passed with warnings
   Warnings: 1

Continue with commit? (y/N)
```

---

## 常见问题

### Q1: CLAUDE.md 和 .folder.md 有什么区别？

**A**: 双轨并存策略

- **CLAUDE.md**: AI Agent 导航地图
  - 格式统一，结构固定
  - 包含完整的架构信息 (依赖、导出、协议检查)
  - 供 AI Agent 理解项目结构

- **.folder.md**: 团队内部文档
  - 格式灵活，人类友好
  - 保留团队原有的文档风格
  - 供团队成员快速阅读

**内容同步**: 两者内容应保持一致，但格式可不同。

---

### Q2: 为什么 L3 头部采用简洁格式而非多行格式？

**A**: 权衡可读性和信息密度

**简洁格式** (当前采用):
```typescript
// [INPUT] zustand的create函数, api/auth中的authApi
// [OUTPUT] useAuthStore hook
// [POS] 状态管理层的认证Store
```

**多行格式** (未采用):
```typescript
/**
 * [INPUT]:
 *   - zustand@5.0.9 (create)
 *   - ../api/auth.ts (authApi.login, authApi.register)
 *   ...
 */
```

**选择理由**:
- 简洁格式已足够清晰
- 减少代码视觉噪音
- 保持与项目现有风格一致
- 如需详细信息，可查看 L2 文档

**未来可选**: 使用 VSCode Snippet 逐步升级为多行格式

---

### Q3: 如何处理文档与代码不同步的情况？

**A**: 使用协议回环检查机制

**问题**: 代码已修改，但文档未更新

**解决方案**:

1. **手动检查**:
   - 修改代码后，查看文件 L3 头部的 [PROTOCOL] 字段
   - 按照提示更新对应的 L2 CLAUDE.md

2. **工具检查**:
   - 运行 pre-commit hook: `./pre-commit-hook.sh`
   - 工具会提示哪些文档需要更新

3. **定期审计**:
   - 每月审计一次文档完整性
   - 使用验证命令检查覆盖率

**预防措施**:
- 安装 pre-commit hook 自动提醒
- 在 code review 中检查文档同步
- 团队培训，强化文档意识

---

### Q4: L2.5 何时需要创建？

**A**: 满足以下任一标准时创建

**必须创建**:
- 文件数量 ≥ 4 个 (不含 index.ts)
- 有内部子文件夹结构

**建议创建**:
- 已有 README.md 或 .folder.md
- 复杂度高 (如多页滑动、相机控制、复杂状态管理)
- 需要详细说明数据流或业务逻辑

**不需要创建**:
- 简单的 2 文件模块 (View + CSS)
- 功能单一，无复杂逻辑
- L2 文档已足够说明

**示例**:
- ✅ 需要: BaziResult (4页滑动，复杂状态)
- ✅ 需要: Login (3个CSS文件，已有README)
- ❌ 不需要: NameEntry (简单的姓名输入，2个文件)

---

### Q5: 如何验证文档系统的完整性？

**A**: 使用验证命令

**检查文档数量**:
```bash
# 应该有 15 个 CLAUDE.md 文件
find . -name "CLAUDE.md" -type f | wc -l
```

**检查 L3 头部覆盖率**:
```bash
# 总 TypeScript 文件数
find src -name "*.ts" -o -name "*.tsx" | wc -l

# 有 L3 头部的文件数
grep -r "\[INPUT\]" src --include="*.ts" --include="*.tsx" -l | wc -l

# 计算覆盖率 = (有L3头部的文件数 / 总文件数) * 100%
```

**检查文档链接**:
```bash
# 检查 L2 文档中的父级链接
grep -r "父级:" src --include="CLAUDE.md"

# 应该都指向正确的父级文档
```

**运行 pre-commit hook**:
```bash
./pre-commit-hook.sh
# 会显示所有不合规的地方
```

---

### Q6: 团队新成员如何快速上手？

**A**: 5 步学习路径

**Step 1: 阅读本指南** (30分钟)
- 理解 GEB 系统的核心理念
- 了解文档层级结构

**Step 2: 浏览项目宪法** (15分钟)
```bash
cat CLAUDE.md
```
- 理解项目整体架构
- 了解技术栈和架构约束

**Step 3: 深入一个模块** (30分钟)
```bash
# 选择感兴趣的模块，例如 API 层
cat src/api/CLAUDE.md

# 查看一个具体文件
head -20 src/api/client.ts
cat src/api/auth.ts
```
- 理解 L2 → L3 → Code 的对应关系

**Step 4: 实践添加功能** (1小时)
- 尝试添加一个简单的新功能
- 使用 VSCode Snippet 添加 L3 头部
- 更新对应的 L2 文档

**Step 5: Review 实施总结** (15分钟)
```bash
cat GEB_IMPLEMENTATION_SUMMARY.md
```
- 了解系统的实施历史和后续计划

**总计**: 约 2.5 小时即可掌握基本使用

---

### Q7: 如何处理遗留代码缺少 L3 头部？

**A**: 渐进式补充策略

**原则**: 不强制全面补充，按需添加

**策略 1: 修改时添加**
- 修改某个文件时，顺便添加 L3 头部
- 使用 VSCode Snippet 快速生成

**策略 2: 模块化补充**
- 每次专注一个模块 (如 src/api/)
- 批量为该模块所有文件添加 L3 头部
- 提高该模块的文档覆盖率

**策略 3: 新功能强制**
- 新增文件必须有 L3 头部
- 通过 pre-commit hook 强制检查

**工具辅助**:
```bash
# 找出所有缺少 L3 头部的文件
find src -name "*.ts" -o -name "*.tsx" | while read file; do
  if ! grep -q "\[INPUT\]" "$file"; then
    echo "$file"
  fi
done
```

---

## 附录

### 文档模板

#### L2 CLAUDE.md 模板
```markdown
# [模块名] | src/[module]/CLAUDE.md (L2)

> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: YYYY-MM-DD

## 模块定位
[一段话说明模块在架构中的位置和职责]

## 核心逻辑
[关键工作原理，3-5 个要点]

## 架构约束
### 严禁
- [禁止项]

### 必须
- [必须遵守项]

## 成员清单
- **文件名.ts** - 隐喻名称
  - 依赖: [具体依赖]
  - 导出: [具体导出]
  - 职责: [一句话]

## 上游依赖
[本模块依赖的外部包和内部模块]

## 下游消费者
[哪些模块使用本模块]

## 协议回环检查
变更此模块时必须检查:
1. [触发条件] → [更新操作] → [连锁影响]

---

**[PROTOCOL]: 变更此模块时必须检查本文件的协议回环检查章节**
```

#### L2.5 CLAUDE.md 模板
```markdown
# [子模块名] | src/[module]/[SubModule]/CLAUDE.md (L2.5)

> L2.5 | 父级: [src/[module]/CLAUDE.md](../CLAUDE.md) | 最后更新: YYYY-MM-DD

## 模块定位
[子模块说明]

## 成员清单
- **文件名.tsx** - [职责]
  - 依赖: [依赖列表]
  - 导出: [导出内容]

## 路由/使用方式
[如何使用该子模块]

## 协议回环检查
- [ ] 更新 L3 头部
- [ ] 更新 ../CLAUDE.md

---

**[PROTOCOL]: 变更时更新此头部，然后检查 src/[module]/CLAUDE.md**
```

---

### 参考资源

#### 内部文档
- `/CLAUDE.md` - L1 项目宪法
- `GEB_IMPLEMENTATION_SUMMARY.md` - 实施总结
- 各模块 `CLAUDE.md` - L2/L2.5 文档

#### 工具文件
- `.vscode/l3-header.code-snippets` - VSCode 代码片段
- `pre-commit-hook.sh` - Git Hook 脚本

#### 外部参考
- 《GEB: 一条永恒的金带》- 分形和递归思想来源
- TypeScript Handbook - 类型系统参考
- React Documentation - React 19 最新特性

---

## 总结

GEB 分形文档系统是一个**自相似、可导航、可验证**的文档架构：

**核心价值**:
- 🧭 **可导航**: 从任何层级都能找到任何代码
- 🔄 **同构性**: 代码与文档必须同步
- 🔍 **可验证**: 工具自动检查文档完整性
- 📚 **分形性**: 每层遵循相同结构模式

**使用建议**:
- 新人从 L1 开始逐层理解
- 开发者修改代码时同步更新文档
- AI Agent 通过文档快速理解项目
- 定期审计确保文档质量

**记住**:
> The map IS the terrain. The terrain IS the map.

代码是机器相，文档是语义相，两相必须同构。
任一相变化，必须在另一相显现，否则视为未完成。

---

**文档版本**: 1.0
**创建日期**: 2026-01-18
**维护者**: OCTA Web Frontend Team
**联系方式**: 项目内部沟通渠道
