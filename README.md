# Octa-v1 风水分析平台

基于八字命理的AI风水分析平台，为用户提供个性化的工位、户型和环境风水建议。

## 项目概述

Octa-v1 是一个现代化的风水分析SaaS平台，结合传统八字命理学和AI视觉分析技术，为用户提供：

- **工位风水分析** - 分析办公环境与个人八字的匹配度
- **户型风水分析** - 评估住宅户型的风水格局
- **环境环扫分析** - 八方位全方位环境风水评估
- **个性化建议** - 基于用户八字提供定制化改善方案

## 技术栈

- **后端**: Python 3.11+ / FastAPI
- **数据库**: Google Firestore
- **存储**: Google Cloud Storage
- **AI**: Vertex AI (Gemini)
- **订阅**: RevenueCat
- **部署**: Google Cloud Run

## 项目结构

```
Octa-v1/
├── backend-v1/          # FastAPI 后端服务
│   ├── app/
│   │   ├── api/         # API 路由层
│   │   ├── services/    # 业务逻辑层
│   │   ├── repositories/# 数据访问层
│   │   ├── models/      # 数据模型
│   │   ├── prompts/     # AI 提示词管理
│   │   ├── core/        # 核心配置
│   │   └── utils/       # 工具函数
│   └── main.py
├── octa-frontend-v1/    # iOS 前端（SwiftUI）
├── octa-web/            # Web 前端（React + TypeScript）
│   ├── src/
│   │   ├── api/         # API 客户端层
│   │   ├── features/    # 功能模块（按页面组织）
│   │   ├── components/  # 通用组件
│   │   ├── stores/      # 状态管理（Zustand）
│   │   ├── types/       # TypeScript 类型定义
│   │   ├── styles/      # CSS Modules + 设计令牌
│   │   └── utils/       # 工具函数
│   └── package.json
├── terraform/           # 基础设施代码
├── .cursorrules         # 分形架构守护者规范
└── ARCHITECTURE_GUARDIAN.md  # 架构规范工作流指南
```

## 架构规范

本项目采用"分形架构守护者"规范，确保文档与代码同步：

- **IOP 契约**: 每个文件头部包含 `[INPUT]`、`[OUTPUT]`、`[POS]` 注释
- **文件夹地图**: 每个关键文件夹包含 `.folder.md` 说明文件
- **文档同步**: 代码变更时同步更新相关文档

详细规范请参考：
- [.cursorrules](.cursorrules) - 核心规范定义
- [ARCHITECTURE_GUARDIAN.md](ARCHITECTURE_GUARDIAN.md) - 工作流指南

## API 端点文档

### 健康检查

#### `GET /healthz`
**作用**: 服务存活检查，用于Kubernetes/Cloud Run健康探针

**返回示例**:
```json
{
  "status": "healthy",
  "version": "v1"
}
```

#### `GET /readyz`
**作用**: 服务就绪检查，验证数据库连接和依赖服务

**返回示例**:
```json
{
  "status": "ready",
  "checks": {
    "firestore": "ok",
    "gcs": "ok"
  }
}
```

---

### 1. 身份认证模块 (`/v1/auth`)

#### `POST /v1/auth/register`
**作用**: 用户注册，创建新账号并发送邮箱验证

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "language": "zh",
  "timezone": "Asia/Shanghai"
}
```

**返回**:
```json
{
  "user_id": "user_xxx",
  "email": "user@example.com",
  "verification_token": "token_xxx"
}
```

#### `POST /v1/auth/verify`
**作用**: 验证用户邮箱，激活账号

**请求体**:
```json
{
  "token": "verification_token"
}
```

**返回**:
```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

#### `POST /v1/auth/login`
**作用**: 用户登录，获取访问令牌

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**返回**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

#### `POST /v1/auth/login-oauth`
**作用**: OAuth第三方登录（Google/Apple）

**请求体**:
```json
{
  "provider": "google",
  "id_token": "google_id_token_xxx"
}
```

**返回**: 同上login接口

#### `POST /v1/auth/logout`
**作用**: 登出，撤销刷新令牌

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

#### `POST /v1/auth/refresh`
**作用**: 刷新访问令牌

**请求体**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**返回**:
```json
{
  "access_token": "new_access_token",
  "token_type": "Bearer",
  "expires_in": 900
}
```

---

### 2. 用户资料模块 (`/v1/users`)

#### `GET /v1/users/me`
**作用**: 获取当前用户的个人资料

**需要**: Bearer Token

**返回**:
```json
{
  "user_id": "user_xxx",
  "email": "user@example.com",
  "email_verified": true,
  "language": "zh",
  "timezone": "Asia/Shanghai",
  "subscription_tier": "free",
  "created_at": "2025-01-15T10:00:00Z"
}
```

#### `PATCH /v1/users/me`
**作用**: 更新个人资料（语言、时区、头像等）

**需要**: Bearer Token

**请求体**:
```json
{
  "language": "en",
  "timezone": "America/New_York",
  "display_name": "John Doe"
}
```

**返回**: 更新后的用户信息

#### `POST /v1/users/me/deletion`
**作用**: 发起账号删除请求（30天宽限期）

**需要**: Bearer Token

**返回**:
```json
{
  "deletion_requested_at": "2025-01-15T10:00:00Z",
  "deletion_scheduled_at": "2025-02-14T10:00:00Z",
  "grace_period_days": 30
}
```

#### `GET /v1/users/me/deletion`
**作用**: 查询账号删除进度

**需要**: Bearer Token

**返回**:
```json
{
  "deletion_pending": true,
  "deletion_scheduled_at": "2025-02-14T10:00:00Z",
  "days_remaining": 25
}
```

#### `DELETE /v1/users/me/deletion`
**作用**: 撤回账号删除请求

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Account deletion cancelled"
}
```

---

### 3. 八字档案模块 (`/v1/profiles/bazi`)

#### `POST /v1/profiles/bazi`
**作用**: 创建八字档案，自动计算四柱、五行、喜忌神

**需要**: Bearer Token

**请求体**:
```json
{
  "name": "主档案",
  "birth_date": "1990-05-15",
  "birth_time": "14:30:00",
  "birth_location": "北京市",
  "gender": "male"
}
```

**返回**:
```json
{
  "profile_id": "bazi_xxx",
  "name": "主档案",
  "birth_date": "1990-05-15",
  "birth_time": "14:30:00",
  "chart": {
    "year_pillar": {"gan": "庚", "zhi": "午"},
    "month_pillar": {"gan": "辛", "zhi": "巳"},
    "day_pillar": {"gan": "甲", "zhi": "寅"},
    "hour_pillar": {"gan": "辛", "zhi": "未"},
    "day_master": "甲"
  },
  "elements": {
    "wood": 37.5,
    "fire": 25.0,
    "earth": 12.5,
    "metal": 25.0,
    "water": 0.0
  },
  "lucky_elements": ["water", "wood"],
  "unlucky_elements": ["fire", "earth"],
  "lucky_directions": ["north", "east"],
  "lucky_colors": ["black", "blue", "green"],
  "is_active": true,
  "created_at": "2025-01-15T10:00:00Z"
}
```

#### `GET /v1/profiles/bazi`
**作用**: 获取用户的所有八字档案列表

**需要**: Bearer Token

**返回**:
```json
{
  "profiles": [
    {
      "profile_id": "bazi_xxx",
      "name": "主档案",
      "is_active": true,
      "created_at": "2025-01-15T10:00:00Z"
    }
  ],
  "total": 1,
  "max_allowed": 1
}
```

**限制**: Free用户最多1个档案，Pro用户最多5个

#### `GET /v1/profiles/bazi/{id}`
**作用**: 查看指定档案的详细信息

**需要**: Bearer Token

**返回**: 完整档案详情（同创建接口）

#### `PATCH /v1/profiles/bazi/{id}`
**作用**: 修改档案名称或状态（24小时冷却期）

**需要**: Bearer Token

**请求体**:
```json
{
  "name": "新名称",
  "is_active": true
}
```

**返回**: 更新后的档案

**注意**: 档案修改有24小时冷却期

#### `DELETE /v1/profiles/bazi/{id}`
**作用**: 删除八字档案

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Profile deleted"
}
```

#### `POST /v1/profiles/bazi/{id}:activate`
**作用**: 切换激活的档案（用于分析时选择使用哪个档案）

**需要**: Bearer Token

**返回**: 激活后的档案信息

---

### 4. 媒体上传模块 (`/v1/media`)

#### `POST /v1/media/:init`
**作用**: 申请上传URL，获取GCS签名链接

**需要**: Bearer Token

**请求体**:
```json
{
  "file_type": "image/jpeg",
  "file_size": 2048000,
  "file_name": "workspace.jpg"
}
```

**返回**:
```json
{
  "media_id": "media_xxx",
  "upload_url": "https://storage.googleapis.com/bucket/path?signature=xxx",
  "method": "PUT",
  "headers": {
    "Content-Type": "image/jpeg"
  },
  "expires_in": 900
}
```

**使用流程**:
1. 调用此接口获取upload_url
2. 使用PUT方法上传文件到upload_url
3. 调用commit接口确认上传完成

#### `POST /v1/media/:commit`
**作用**: 确认上传完成，验证文件存在

**需要**: Bearer Token

**请求体**:
```json
{
  "media_id": "media_xxx"
}
```

**返回**:
```json
{
  "media_id": "media_xxx",
  "status": "ready"
}
```

#### `GET /v1/media/{media_id}`
**作用**: 获取媒体下载URL（签名链接）

**需要**: Bearer Token

**返回**:
```json
{
  "media_id": "media_xxx",
  "download_url": "https://storage.googleapis.com/bucket/path?signature=xxx",
  "expires_in": 3600
}
```

#### `DELETE /v1/media/{media_id}`
**作用**: 删除已上传的媒体文件

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Media deleted"
}
```

#### `POST /v1/media/sets`
**作用**: 创建媒体集（用于环扫8方位分析）

**需要**: Bearer Token

**请求体**:
```json
{
  "media_ids": [
    "media_1",
    "media_2",
    "media_3",
    "media_4",
    "media_5",
    "media_6",
    "media_7",
    "media_8"
  ],
  "set_type": "lookaround8"
}
```

**返回**:
```json
{
  "set_id": "mediaset_xxx",
  "media_count": 8,
  "set_type": "lookaround8"
}
```

**注意**: lookaround8类型需要恰好8张图片

#### `GET /v1/media/sets/{set_id}`
**作用**: 获取媒体集详情及所有图片下载链接

**需要**: Bearer Token

**返回**:
```json
{
  "set_id": "mediaset_xxx",
  "set_type": "lookaround8",
  "media_count": 8,
  "media_urls": [
    "https://storage.googleapis.com/...",
    "https://storage.googleapis.com/...",
    "..."
  ]
}
```

---

### 5. 风水分析模块 (`/v1/analysis`) ⭐️ 核心功能

#### `POST /v1/analysis/jobs`
**作用**: 创建风水分析任务（支持3种场景类型）

**需要**: Bearer Token

**请求体** (multipart/form-data):
```
scene_type: "workspace" | "floorplan" | "lookaround8"
bazi_profile_id: "bazi_xxx"
media_file: [文件] (可选，直接上传)
media_ids: "media_1,media_2" (可选，使用已上传的媒体ID)
media_set_id: "mediaset_xxx" (可选，用于lookaround8)
```

**返回**:
```json
{
  "job_id": "job_xxx",
  "status": "pending",
  "scene_type": "workspace",
  "created_at": "2025-01-15T10:00:00Z"
}
```

**场景类型说明**:

##### 1. `workspace` - 工位风水分析 ✅ MVP已实现
分析办公桌位置、朝向、五行平衡，提供个性化摆放建议

**分析维度**:
- 办公桌位置（朝向、命令位、背后支撑）
- 五行平衡（环境五行分布与八字适配度）
- 能量流动（门窗对冲、尖角煞、光线）
- 风水建议（按优先级排序的改善方案）

**输入**: 1张工位照片

##### 2. `floorplan` - 户型风水分析 🚧 Phase 2
分析房屋格局、房间位置，评估财位、文昌位

**计划分析维度**:
- 布局结构（房间位置、财位、文昌位、主卧位置）
- 五行平衡（房间五行分布）
- 能量流动（门的对冲、窗户位置、气流路径）
- 空间和谐（房间比例、对称性、吉祥形状）

**输入**: 1张户型图

##### 3. `lookaround8` - 环扫分析 🚧 Phase 2
八方位全方位环境风水评估，分析周边建筑、山水格局

**计划分析维度**:
- 方位分析（每个方向的山水特征、建筑结构）
- 五行分布（各方位的五行元素、整体平衡）
- 环境质量（山环水抱、天斩煞、路冲等）
- 方位建议（最佳活动方位、需要增强/化解的方向）

**输入**: 8张照片（北、东北、东、东南、南、西南、西、西北）

**配额限制**:
- Free用户: 3次分析/月
- Pro用户: 无限次

#### `GET /v1/analysis/jobs/{job_id}`
**作用**: 查询分析任务状态

**需要**: Bearer Token

**返回**:
```json
{
  "job_id": "job_xxx",
  "status": "completed",
  "scene_type": "workspace",
  "result_id": "result_xxx",
  "created_at": "2025-01-15T10:00:00Z",
  "completed_at": "2025-01-15T10:02:30Z"
}
```

**状态值**:
- `pending` - 等待处理
- `running` - 分析中
- `completed` - 已完成
- `failed` - 失败

#### `GET /v1/analysis/results/{result_id}`
**作用**: 获取分析结果详情

**需要**: Bearer Token

**返回**:
```json
{
  "result_id": "result_xxx",
  "overall_score": 75,
  "summary": "您的工位风水整体良好，建议优化几个关键点以提升运势。",
  "key_findings": [
    "办公桌位置基本合理",
    "光线充足但需要调节",
    "缺少火元素装饰"
  ],
  "recommendations": [
    {
      "category": "placement",
      "priority": "high",
      "title": "添加背后支撑",
      "description": "在座椅后方放置书柜或高大植物，形成靠山格局",
      "expected_improvement": "提升事业稳定性和安全感",
      "implementation_tips": [
        "选择稳固的家具作为背后支撑",
        "避免使用镜子，防止气场反射"
      ]
    },
    {
      "category": "element",
      "priority": "medium",
      "title": "增加火元素",
      "description": "添加红色或橙色装饰品以平衡五行",
      "expected_improvement": "激发创造力和热情",
      "implementation_tips": [
        "可选择红色台灯或笔筒",
        "橙色抱枕或画作"
      ]
    }
  ],
  "details": {
    "desk_position": {
      "score": 70,
      "facing_direction": "southeast",
      "command_position_score": 80,
      "back_support_score": 60
    },
    "element_balance": {
      "compatibility_score": 65,
      "current_elements": {
        "wood": 40,
        "fire": 10,
        "earth": 20,
        "metal": 20,
        "water": 10
      },
      "missing_elements": ["fire"],
      "excess_elements": ["wood"]
    }
  },
  "lucky_elements_analysis": {
    "user_lucky_elements": ["water", "wood"],
    "present_in_workspace": ["wood"],
    "missing_in_workspace": ["water"],
    "recommendations": "建议添加水元素装饰（如小型流水摆件）"
  }
}
```

**订阅限制**:
- **Free用户**: 仅查看summary、overall_score和前2条recommendations
- **Pro用户**: 完整报告，包括details和lucky_elements_analysis

---

### 6. 报告管理模块 (`/v1/reports`)

#### `GET /v1/reports`
**作用**: 获取用户的所有分析报告列表（分页）

**需要**: Bearer Token

**查询参数**: `?limit=20&offset=0`

**返回**:
```json
{
  "reports": [
    {
      "report_id": "result_xxx",
      "scene_type": "workspace",
      "title": "工位风水分析报告",
      "overall_score": 75,
      "created_at": "2025-01-15T10:00:00Z"
    }
  ],
  "total": 10,
  "limit": 20,
  "offset": 0
}
```

#### `GET /v1/reports/{report_id}`
**作用**: 查看报告详情（按订阅等级过滤内容）

**需要**: Bearer Token

**返回**: 同 `/v1/analysis/results/{result_id}` 接口

#### `DELETE /v1/reports/{report_id}`
**作用**: 删除报告（软删除）

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Report deleted"
}
```

#### `POST /v1/reports/{report_id}/share`
**作用**: 生成报告公开分享链接

**需要**: Bearer Token

**返回**:
```json
{
  "share_token": "share_xxx",
  "share_url": "https://app.octa.ai/shared/share_xxx",
  "expires_at": null
}
```

#### `DELETE /v1/reports/{report_id}/share`
**作用**: 撤销报告分享，使链接失效

**需要**: Bearer Token

**返回**:
```json
{
  "success": true,
  "message": "Share link revoked"
}
```

#### `GET /v1/reports/shared/{share_token}`
**作用**: 访问公开分享的报告（无需登录）

**无需认证**

**返回**:
```json
{
  "report_id": "result_xxx",
  "title": "工位风水分析报告",
  "summary": "这是一个分享的风水分析报告",
  "overall_score": 75,
  "key_findings": [
    "办公桌位置基本合理",
    "光线充足但需要调节"
  ],
  "created_at": "2025-01-15T10:00:00Z",
  "is_shared": true,
  "disclaimer": "本报告仅供参考，不构成专业建议"
}
```

**注意**: 分享的报告内容受限，不包含完整详情

---

### 7. 订阅管理模块 (`/v1/entitlements`)

#### `GET /v1/entitlements/me`
**作用**: 获取当前用户的订阅状态和配额

**需要**: Bearer Token

**返回**:
```json
{
  "is_active": true,
  "plan": "pro",
  "expires_at": "2025-12-31T23:59:59Z",
  "limits": {
    "analysis_per_month": -1,
    "chat_messages_per_day": -1,
    "max_bazi_profiles": 5,
    "max_media_storage_mb": 1000,
    "advanced_features": true,
    "priority_support": true
  },
  "usage": {
    "analysis_this_month": 15,
    "chat_messages_today": 0,
    "bazi_profiles": 2,
    "media_storage_used_mb": 120
  },
  "features": [
    "unlimited_analysis",
    "ai_chat",
    "detailed_reports",
    "priority_processing",
    "export_pdf",
    "historical_comparison"
  ]
}
```

**说明**: `-1` 表示无限配额

#### `POST /v1/entitlements/refresh`
**作用**: 从支付服务商（RevenueCat）同步最新订阅状态

**需要**: Bearer Token

**返回**:
```json
{
  "message": "Entitlements refreshed successfully",
  "synced_at": "2025-01-15T10:00:00Z"
}
```

#### `GET /v1/entitlements/offerings`
**作用**: 获取可用的订阅套餐列表

**需要**: Bearer Token（可选）

**返回**:
```json
{
  "offerings": [
    {
      "identifier": "monthly_pro",
      "plan": "pro",
      "billing_period": "monthly",
      "price": {
        "amount": 9.99,
        "currency": "USD",
        "formatted": "$9.99/month"
      },
      "features": [
        "Unlimited workspace analysis",
        "Unlimited floorplan analysis",
        "AI-powered chat assistant",
        "Detailed PDF reports",
        "Priority processing",
        "Historical trend analysis",
        "Multiple Bazi profiles"
      ],
      "trial": {
        "available": true,
        "duration_days": 7
      }
    },
    {
      "identifier": "yearly_pro",
      "plan": "pro",
      "billing_period": "yearly",
      "price": {
        "amount": 99.99,
        "currency": "USD",
        "formatted": "$99.99/year"
      },
      "discount": {
        "percentage": 17,
        "description": "Save $20 compared to monthly"
      },
      "features": [
        "All monthly features",
        "17% discount",
        "Extended cloud storage"
      ],
      "trial": {
        "available": true,
        "duration_days": 7
      }
    },
    {
      "identifier": "free",
      "plan": "free",
      "billing_period": null,
      "price": {
        "amount": 0,
        "currency": "USD",
        "formatted": "Free"
      },
      "features": [
        "3 workspace analyses per month",
        "Basic reports",
        "Community support"
      ],
      "trial": null
    }
  ]
}
```

**订阅等级对比**:

| 功能 | Free | Pro |
|------|------|-----|
| 工位分析 | 3次/月 | 无限 |
| 户型分析 | ❌ | ✅ |
| 环扫分析 | ❌ | ✅ |
| AI聊天 | ❌ | ✅ |
| 八字档案 | 1个 | 5个 |
| 报告详情 | 基础 | 完整 |
| PDF导出 | ❌ | ✅ |
| 云存储 | 50MB | 1GB |
| 客服支持 | 社区 | 优先 |

---

### 8. Webhooks (`/v1/entitlements/webhooks`)

#### `POST /v1/entitlements/webhooks/revenuecat`
**作用**: 接收RevenueCat订阅事件回调

**无需认证**（通过签名验证）

**请求体示例**:
```json
{
  "event": {
    "type": "INITIAL_PURCHASE",
    "app_user_id": "user_xxx",
    "product_id": "monthly_pro",
    "purchased_at_ms": 1673798400000
  }
}
```

**事件类型**:
- `INITIAL_PURCHASE` - 首次购买
- `RENEWAL` - 订阅续费
- `CANCELLATION` - 取消订阅
- `BILLING_ISSUE` - 付款问题
- `PRODUCT_CHANGE` - 套餐变更

**返回**:
```json
{
  "received": true
}
```

#### `POST /v1/entitlements/webhooks/stripe`
**作用**: 接收Stripe支付事件回调（占位）

**无需认证**（通过签名验证）

**返回**:
```json
{
  "received": true
}
```

---

### 9. 聊天对话模块 (`/v1/chat`) - Phase 2

> **注意**: 聊天功能计划在Phase 2实现，当前仅为占位接口

#### `POST /v1/chat/sessions`
**作用**: 创建新的聊天会话

**需要**: Bearer Token（Pro用户）

**计划功能**:
- 基于用户八字的个性化对话
- 风水问题解答
- 改善建议详解

#### `GET /v1/chat/sessions`
**作用**: 获取历史聊天会话列表

**需要**: Bearer Token（Pro用户）

#### `POST /v1/chat/messages`
**作用**: 发送聊天消息

**需要**: Bearer Token（Pro用户）

**计划功能**: 流式返回AI回复

#### `GET /v1/chat/messages`
**作用**: 拉取会话历史消息

**需要**: Bearer Token（Pro用户）

---

## 认证方式

所有需要认证的API使用JWT Bearer Token：

```bash
Authorization: Bearer <access_token>
```

**Token有效期**:
- Access Token: 15分钟
- Refresh Token: 30天

**获取Token**: 调用 `POST /v1/auth/login` 或 `POST /v1/auth/register`

**刷新Token**: 调用 `POST /v1/auth/refresh`

---

## 错误响应格式

所有错误响应遵循统一格式：

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "issue": "Invalid email format"
    }
  }
}
```

**常见错误码**:

| 错误码 | HTTP状态码 | 说明 |
|--------|-----------|------|
| `VALIDATION_ERROR` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未认证或Token无效 |
| `FORBIDDEN` | 403 | 无权限访问资源 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `CONFLICT` | 409 | 资源冲突（如邮箱已存在） |
| `QUOTA_EXCEEDED` | 429 | 配额超限 |
| `RATE_LIMITED` | 429 | 请求过于频繁 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

---

## 快速开始

### 本地开发

```bash
# 进入后端目录
cd backend-v1

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件填入必要配置

# 启动开发服务器
uvicorn app.main:app --reload --port 8000
```

访问 http://localhost:8000/docs 查看交互式API文档（Swagger UI）

访问 http://localhost:8000/redoc 查看ReDoc文档

### 环境变量配置

必需的环境变量（`.env`文件）:

```bash
# 应用配置
ENVIRONMENT=development
JWT_SECRET_KEY=your-secret-key-here

# Google Cloud
GOOGLE_CLOUD_PROJECT=your-project-id
GCS_BUCKET=your-bucket-name

# 数据库
FIRESTORE_COLLECTION_PREFIX=dev_

# RevenueCat（可选）
REVENUECAT_API_KEY=your-revenuecat-key

# Vertex AI（可选）
VERTEX_AI_LOCATION=us-central1
```

### 部署到Google Cloud Run

使用Terraform自动化部署：

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

或使用gcloud命令行：

```bash
# 构建容器镜像
gcloud builds submit --tag gcr.io/PROJECT_ID/octa-backend

# 部署到Cloud Run
gcloud run deploy octa-backend \
  --image gcr.io/PROJECT_ID/octa-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

---

## 开发进度

### 已完成 ✅
- 核心架构设计
- 身份认证模块（6个端点）
- 用户管理模块（5个端点）
- 八字计算引擎
- 八字档案管理（6个端点）
- 媒体上传系统（6个端点）
- 工位分析管道（MVP核心）
- 报告管理系统（6个端点）
- 订阅管理（3个端点）
- Webhooks（2个端点）

### 占位实现 🚧
- 户型分析管道（API已实现，返回占位响应）
- 环扫分析管道（API已实现，返回占位响应）

### 待实现 📋
- AI聊天功能（4个端点，Phase 2）
- PDF报告生成
- 实际数据库集成（Firestore）
- 实际AI模型调用（Vertex AI）
- 邮件发送服务
- OAuth实现（Google/Apple登录）

---

## API使用示例

### 完整工作流示例

#### 1. 注册并登录
```bash
# 注册
curl -X POST http://localhost:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123",
    "language": "zh",
    "timezone": "Asia/Shanghai"
  }'

# 登录
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123"
  }'
```

#### 2. 创建八字档案
```bash
curl -X POST http://localhost:8000/v1/profiles/bazi \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "主档案",
    "birth_date": "1990-05-15",
    "birth_time": "14:30:00",
    "birth_location": "北京市",
    "gender": "male"
  }'
```

#### 3. 上传工位照片
```bash
# 获取上传URL
curl -X POST http://localhost:8000/v1/media/:init \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "file_type": "image/jpeg",
    "file_size": 2048000,
    "file_name": "my_workspace.jpg"
  }'

# 上传文件到返回的upload_url
curl -X PUT "SIGNED_UPLOAD_URL" \
  -H "Content-Type: image/jpeg" \
  --data-binary @my_workspace.jpg

# 确认上传
curl -X POST http://localhost:8000/v1/media/:commit \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"media_id": "media_xxx"}'
```

#### 4. 创建分析任务
```bash
curl -X POST http://localhost:8000/v1/analysis/jobs \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "scene_type=workspace" \
  -F "bazi_profile_id=bazi_xxx" \
  -F "media_ids=media_xxx"
```

#### 5. 查询结果
```bash
# 查询任务状态
curl -X GET http://localhost:8000/v1/analysis/jobs/job_xxx \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 获取分析结果
curl -X GET http://localhost:8000/v1/analysis/results/result_xxx \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 技术文档

详细的技术文档请查看：

- [API完整文档](backend-v1/API_OVERVIEW.md)
- [服务层设计](backend-v1/app/services/README.md)
- [部署指南](backend-v1/DEPLOYMENT.md)
- [API实现清单](backend-v1/API_CHECKLIST.md)

---

## License

Proprietary - All Rights Reserved

Copyright © 2025 Octa AI
