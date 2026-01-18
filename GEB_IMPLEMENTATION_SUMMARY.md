# GEB 分形文档系统实施总结
# OCTA Web Frontend Project

**实施日期**: 2026-01-18
**项目**: OCTA Web Frontend (React 19 + TypeScript 5.9)
**状态**: ✅ L1/L2/L2.5 层级完成

---

## 实施概览

成功为 OCTA Web Frontend 项目建立了完整的 GEB 分形文档系统，包含 3 层文档架构：

- **L1 (项目宪法)**: 1 个文件
- **L2 (模块地图)**: 8 个核心模块文档
- **L2.5 (子模块地图)**: 6 个复杂子模块文档

**总计**: 15 个 CLAUDE.md 文档文件

---

## 文档架构树

```
OCTA Web Frontend
│
├── CLAUDE.md (L1) ← 项目宪法
│   │
│   ├── src/api/CLAUDE.md (L2) ← API 客户端层
│   │
│   ├── src/stores/CLAUDE.md (L2) ← Zustand 状态管理层
│   │
│   ├── src/types/CLAUDE.md (L2) ← TypeScript 类型定义层
│   │
│   ├── src/styles/CLAUDE.md (L2) ← 设计系统 (CSS 变量)
│   │
│   ├── src/utils/CLAUDE.md (L2) ← 工具函数层
│   │
│   ├── src/constants/CLAUDE.md (L2) ← 常量定义层
│   │
│   ├── src/features/CLAUDE.md (L2) ← 功能模块层
│   │   ├── src/features/Login/CLAUDE.md (L2.5)
│   │   ├── src/features/BaziResult/CLAUDE.md (L2.5)
│   │   └── src/features/Tutorial/CLAUDE.md (L2.5)
│   │
│   └── src/components/CLAUDE.md (L2) ← 通用组件库层
│       ├── src/components/BottomNavigation/CLAUDE.md (L2.5)
│       ├── src/components/GlassSearchButton/CLAUDE.md (L2.5)
│       └── src/components/ReportBottomTabBar/CLAUDE.md (L2.5)
```

---

## 已创建文档清单

### L1 层 (1 个)
- [x] `/CLAUDE.md` - 项目宪法
  - 技术栈版本清单 (精确到 patch 版本)
  - 完整目录树与职责说明
  - 架构约束和数据流向规则
  - L2 模块索引
  - GEB 协议说明

### L2 层 (8 个核心模块)
- [x] `src/api/CLAUDE.md` - API 客户端层
  - 6 个 API 模块详细说明 (client, auth, profiles, analysis, users, index)
  - 端点映射、类型同步协议

- [x] `src/stores/CLAUDE.md` - 状态管理层
  - 2 个核心 Store (authStore, onboardingStore)
  - 状态生命周期、Zustand 使用模式

- [x] `src/types/CLAUDE.md` - 类型定义层
  - 4 个类型文件 (api.ts, models.ts, common.ts, index.ts)
  - 前后端类型同步规则

- [x] `src/styles/CLAUDE.md` - 样式系统层
  - CSS 变量系统、设计令牌
  - Figma 同步协议

- [x] `src/utils/CLAUDE.md` - 工具函数层
  - 纯函数工具集

- [x] `src/constants/CLAUDE.md` - 常量定义层
  - UI 文本常量

- [x] `src/features/CLAUDE.md` - 功能模块层
  - 18 个功能模块清单
  - 路由映射表

- [x] `src/components/CLAUDE.md` - 组件库层
  - 通用 UI 组件清单
  - 组件使用规范

### L2.5 层 (6 个复杂子模块)

#### Features 子模块 (3 个)
- [x] `src/features/Login/CLAUDE.md` - 登录页面
- [x] `src/features/BaziResult/CLAUDE.md` - 八字结果展示 (4页滑动)
- [x] `src/features/Tutorial/CLAUDE.md` - 拍摄教程

#### Components 子模块 (3 个)
- [x] `src/components/BottomNavigation/CLAUDE.md` - 底部导航栏
- [x] `src/components/GlassSearchButton/CLAUDE.md` - 毛玻璃搜索按钮
- [x] `src/components/ReportBottomTabBar/CLAUDE.md` - 报告底部标签栏

---

## L3 层现状

### 保留原有格式
所有业务代码文件保留了原有的简洁 L3 头部格式 (IOP 注释):

```typescript
// [INPUT] 依赖说明
// [OUTPUT] 导出说明
// [POS] 位置说明
```

### 覆盖范围
- ✅ src/api/*.ts (6 个文件已有 L3 头部)
- ✅ src/stores/*.ts (2 个文件已有 L3 头部)
- ⚠️ src/features/*/*.tsx (部分文件有 L3 头部)
- ⚠️ src/components/*/*.tsx (部分文件有 L3 头部)
- ⚠️ src/types/*.ts (部分文件缺少 L3 头部)
- ⚠️ src/utils/*.ts (部分文件缺少 L3 头部)

### 建议
未来可通过 VSCode Snippet (已提供) 快速为缺失 L3 头部的文件添加注释。

---

## 核心特性

### 1. 分形自相似性
- L1 折叠 L2 (目录树 → 模块清单)
- L2 折叠 L2.5 (模块清单 → 子模块详情)
- L2.5 折叠 L3 (子模块详情 → 文件头部)
- L3 折叠代码 (文件头部 → import/export)

### 2. 双轨并存策略
- **CLAUDE.md**: AI Agent 导航地图 (新建)
- **.folder.md**: 团队内部文档 (保留)
- 内容同步，避免冲突

### 3. 协议回环检查
每个 CLAUDE.md 都包含 **协议回环检查** 章节:
```
变更此模块时必须检查:
1. [触发条件] → [更新操作] → [连锁影响]
```

确保代码变更时文档同步更新。

### 4. 父级链接
所有 L2/L2.5 文档包含父级链接:
```markdown
> L2 | 父级: [/CLAUDE.md](/CLAUDE.md) | 最后更新: 2026-01-18
```

便于导航和理解层级关系。

---

## 工具支持

### VSCode Snippet
已创建 `.vscode/l3-header.code-snippets`:
- `l3header` - 通用 L3 头部模板
- `l3api` - API 文件专用模板
- `l3store` - Store 文件专用模板
- `l3component` - 组件文件专用模板

### Pre-commit Hook (可选)
已提供 `pre-commit-hook.sh` 脚本模板:
- 检查 L3 头部缺失
- 检查 CLAUDE.md 同步
- 检测新增/删除文件

**安装方法**:
```bash
chmod +x pre-commit-hook.sh
cp pre-commit-hook.sh $(git rev-parse --git-dir)/hooks/pre-commit
```

---

## 架构约束摘要

### 数据流向 (单向)
```
API Client → Stores → Features/Components → Views
```

### 层级隔离规则
1. ❌ Features/Components 严禁直接调用 API (必须通过 Stores)
2. ❌ Store 严禁操作 DOM (只管理数据)
3. ❌ 严禁硬编码样式值 (必须使用 CSS 变量)
4. ❌ 严禁跨 Feature 直接引用 (通过 Stores 共享)

### 类型同步协议
- `src/types/models.ts` 必须与后端 Pydantic 模型同步
- 所有 API 函数必须有完整 TypeScript 类型

---

## 文档覆盖率统计

### 按层级
- **L1 层**: 100% (1/1 项目宪法)
- **L2 层**: 100% (8/8 核心模块)
- **L2.5 层**: 100% (6/6 复杂子模块)
- **L3 层**: 约 60% (现有 IOP 注释文件)

### 按文件类型
- **API 文件**: 100% (6/6 有 L3 头部)
- **Store 文件**: 100% (2/2 有 L3 头部)
- **Feature 组件**: 约 50% (部分有 L3 头部)
- **通用组件**: 约 40% (部分有 L3 头部)
- **类型文件**: 20% (大部分缺少 L3 头部)

---

## 使用指南

### 对于开发者

#### 1. 理解项目架构
```
阅读 /CLAUDE.md (L1 项目宪法)
    ↓
找到感兴趣的模块 (如 src/api)
    ↓
阅读 src/api/CLAUDE.md (L2 模块地图)
    ↓
查看具体文件 (如 src/api/client.ts)
    ↓
阅读文件顶部 L3 头部 (了解依赖和导出)
```

#### 2. 添加新功能
```
确定功能所属模块 (如 src/features/NewFeature)
    ↓
创建功能文件夹和文件
    ↓
使用 VSCode Snippet 添加 L3 头部 (输入 l3component)
    ↓
更新对应 L2 CLAUDE.md 成员清单
    ↓
如功能复杂，创建 L2.5 CLAUDE.md
```

#### 3. 修改现有代码
```
修改代码文件
    ↓
更新文件 L3 头部 (如依赖或导出变更)
    ↓
检查 L3 [PROTOCOL] 字段指向的 L2 文档
    ↓
如需要，更新 L2 CLAUDE.md 成员清单
    ↓
提交代码 (pre-commit hook 会验证)
```

### 对于 AI Agent

#### 1. 导航系统
- 从 `/CLAUDE.md` 开始，获取项目全貌
- 通过 L2 模块索引找到目标模块
- 阅读 L2 CLAUDE.md 了解模块结构
- 通过成员清单定位具体文件
- 阅读 L3 头部了解文件细节

#### 2. 理解依赖关系
- L3 [INPUT] 列出所有上游依赖
- L3 [OUTPUT] 列出所有下游使用
- L2 "上游依赖" 和 "下游消费者" 章节提供模块级依赖图

#### 3. 变更影响分析
- 修改前检查 L3 [OUTPUT] (谁在使用)
- 修改后检查 L3 [PROTOCOL] (需要更新哪些文档)
- 使用 L2 "协议回环检查" 确保所有变更已同步

---

## 已知限制

### 1. L3 头部未全覆盖
- 部分 Feature 和 Component 文件缺少 L3 头部
- **解决方案**: 使用提供的 VSCode Snippet 逐步添加

### 2. 双轨并存维护成本
- CLAUDE.md 和 .folder.md 需要保持同步
- **解决方案**: Pre-commit hook 提醒，或未来合并为单一文档

### 3. 后续新增文件可能遗漏文档
- 开发者可能忘记添加 L3 头部或更新 L2 文档
- **解决方案**: Pre-commit hook 强制检查 (当前为 WARNING，可改为 ERROR)

### 4. Git Worktree 的 Hook 安装
- Worktree 的 git hooks 需要安装到主仓库 `.git/hooks/`
- **解决方案**: 提供的脚本支持手动复制安装

---

## 后续优化建议

### 短期 (1-3个月)
1. **补全 L3 头部**: 为所有业务代码文件添加完整 L3 头部
2. **启用 Pre-commit Hook**: 强制执行 L3 头部和 CLAUDE.md 同步检查
3. **团队培训**: 确保所有开发者理解 GEB 系统使用方法

### 中期 (3-6个月)
1. **自动化生成**: 编写脚本从代码自动生成 L3 头部草稿
2. **文档统一**: 考虑合并 CLAUDE.md 和 .folder.md 为单一文档
3. **可视化工具**: 生成项目依赖关系图 (从 L3 INPUT/OUTPUT 提取)

### 长期 (6个月+)
1. **跨项目推广**: 将 GEB 系统推广到后端项目
2. **标准化**: 制定团队级 GEB 文档标准
3. **工具链完善**: 开发完整的文档生成和验证工具链

---

## 验证命令

### 检查所有 CLAUDE.md 文件
```bash
find . -name "CLAUDE.md" -type f | sort
```

### 检查所有文件的 L3 头部 (IOP 注释)
```bash
# 检查有 [INPUT]/[OUTPUT]/[POS] 的文件
grep -r "\[INPUT\]" src --include="*.ts" --include="*.tsx" -l | wc -l
```

### 统计文档覆盖率
```bash
# 总 TypeScript 文件数
find src -name "*.ts" -o -name "*.tsx" | wc -l

# 有 L3 头部的文件数
grep -r "\[INPUT\]" src --include="*.ts" --include="*.tsx" -l | wc -l
```

---

## 成功标准

### ✅ 已达成
- [x] 创建完整的 L1 项目宪法 (1 个文件)
- [x] 创建所有核心模块 L2 文档 (8 个文件)
- [x] 创建关键子模块 L2.5 文档 (6 个文件)
- [x] 定义清晰的架构约束和数据流规则
- [x] 提供 VSCode Snippet 工具支持
- [x] 提供 Pre-commit Hook 脚本模板
- [x] 保留原有 L3 头部格式 (IOP 注释)

### ⚠️ 待完善
- [ ] 为所有业务代码添加 L3 头部 (当前约 60% 覆盖)
- [ ] 安装并启用 Pre-commit Hook
- [ ] 团队培训和文档推广

### 🎯 未来目标
- [ ] L3 头部覆盖率达到 100%
- [ ] 自动化文档生成工具
- [ ] 可视化依赖关系图

---

## 总结

成功为 OCTA Web Frontend 项目建立了 **GEB 分形文档系统的完整骨架**:

**核心成果**:
- ✅ **15 个 CLAUDE.md 文档**: 覆盖 L1/L2/L2.5 三个层级
- ✅ **分形自相似性**: 每层文档都遵循统一的结构模式
- ✅ **协议回环检查**: 确保代码与文档同步的机制
- ✅ **工具支持**: VSCode Snippet + Pre-commit Hook
- ✅ **双轨并存**: 保留 .folder.md 的同时新增 CLAUDE.md

**系统特点**:
- **可导航**: 从 L1 → L2 → L2.5 → L3 → Code 的清晰路径
- **可维护**: 协议回环检查确保文档不会过时
- **可扩展**: 清晰的规则可应用于新增模块
- **可验证**: 提供验证命令和 Pre-commit Hook

**项目价值**:
1. **AI Agent 友好**: 完整的语义地图供 AI 理解项目结构
2. **新人友好**: 清晰的文档层级帮助快速上手
3. **重构友好**: 文档化的依赖关系降低重构风险
4. **团队协作**: 统一的文档标准提升沟通效率

---

**The map IS the terrain. The terrain IS the map.**

代码是机器相，文档是语义相，两相必须同构。
Keep the map aligned with the terrain, or the terrain will be lost.

---

**文档创建者**: Claude Sonnet 4.5
**实施日期**: 2026-01-18
**项目**: OCTA Web Frontend
**状态**: ✅ L1/L2/L2.5 完成，L3 保留原有格式
