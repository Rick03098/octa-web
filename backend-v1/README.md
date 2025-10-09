# Octa-v1 Backend

风水分析平台后端服务，基于 FastAPI 构建，采用分层架构设计。

## 项目结构

```
backend-v1/
├── app/
│   ├── api/               # Controller层 - API路由和请求处理
│   │   ├── deps.py        # 依赖注入（认证、限流等）
│   │   └── v1/            # v1版本API
│   │       ├── router.py  # 主路由
│   │       ├── auth.py    # 认证接口
│   │       ├── analysis.py # 分析接口（核心）
│   │       └── ...
│   ├── services/          # Service层 - 业务逻辑
│   │   ├── bazi_service.py # 八字计算服务
│   │   └── analysis/      # 分析服务
│   │       ├── dispatcher.py          # 场景分发
│   │       └── workspace_pipeline.py  # 工位分析（MVP重点）
│   ├── repositories/      # Repository层 - 数据访问
│   │   └── users_repo.py  # 用户数据访问
│   ├── models/            # 数据模型（Pydantic）
│   │   ├── auth.py        # 认证模型
│   │   ├── analysis.py    # 分析模型
│   │   └── profiles.py    # 八字档案模型
│   ├── prompts/           # AI提示词管理
│   │   ├── base.py        # 基础提示词框架
│   │   └── workspace_prompts.py # 工位分析提示词
│   ├── core/              # 核心配置和工具
│   │   ├── config.py      # 应用配置
│   │   ├── security.py    # JWT和安全
│   │   ├── logging.py     # 日志配置
│   │   └── errors.py      # 错误处理
│   ├── utils/             # 工具函数
│   │   └── ids.py         # ID生成
│   ├── middlewares/       # 中间件
│   │   └── request_id.py  # 请求ID追踪
│   └── main.py           # FastAPI应用入口
├── tests/                # 测试文件
├── requirements.txt      # Python依赖
├── .env.example         # 环境变量示例
└── README.md            # 本文件
```

## 核心功能

### 当前实现（MVP）

1. **健康检查**
   - `GET /healthz` - 服务健康状态
   - `GET /readyz` - 服务就绪状态

2. **工位风水分析**（重点功能）
   - `POST /v1/analysis/jobs` - 创建分析任务
   - `GET /v1/analysis/jobs/{job_id}` - 查询任务状态
   - `GET /v1/analysis/results/{result_id}` - 获取分析结果

3. **八字计算服务**
   - 完整的八字计算逻辑
   - 五行分析和喜忌神判定
   - 幸运方位和颜色推荐

4. **Prompt管理系统**
   - 多语言支持（中/英）
   - 模板化管理
   - 变量注入

### 待实现功能

- 用户认证系统（JWT）
- 八字档案管理
- 媒体上传（GCS）
- 报告生成和分享
- 订阅管理
- 聊天功能（Pro用户）

## 技术栈

- **框架**: FastAPI
- **数据库**: Google Firestore
- **存储**: Google Cloud Storage
- **缓存**: Redis（可选）
- **AI服务**: Vertex AI / Gemini
- **部署**: Google Cloud Run

## 快速开始

### 1. 环境准备

```bash
# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填写必要的配置
# 特别是 JWT_SECRET_KEY 和 Google Cloud 相关配置
```

### 3. 运行服务

```bash
# 开发模式（自动重载）
python app/main.py

# 或使用 uvicorn
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. 访问文档

开发模式下可访问：
- API文档: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API示例

### 创建工位分析任务

```bash
curl -X POST "http://localhost:8000/v1/analysis/jobs" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "scene_type=workspace" \
  -F "bazi_profile_id=profile_xxx" \
  -F "media_file=@workspace.jpg"
```

### 查询分析结果

```bash
curl -X GET "http://localhost:8000/v1/analysis/results/result_xxx" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 开发指南

### 添加新的分析场景

1. 在 `app/prompts/` 创建新的提示词管理类
2. 在 `app/services/analysis/` 创建新的分析管道
3. 在 `dispatcher.py` 注册新管道
4. 更新 API 文档

### 集成AI模型

当前AI调用是模拟的，实际集成步骤：

1. 配置 Vertex AI 凭证
2. 在 `workspace_pipeline.py` 的 `_call_ai_model` 方法中：
   ```python
   # 替换 mock_response 为实际调用
   from app.services.vertex_ai_service import get_vertex_ai_service
   vertex_service = get_vertex_ai_service()
   response = vertex_service.generate_content(...)
   ```

## 部署

### Google Cloud Run

```bash
# 构建 Docker 镜像
docker build -t gcr.io/octa-v1/backend:latest .

# 推送到 Container Registry
docker push gcr.io/octa-v1/backend:latest

# 部署到 Cloud Run
gcloud run deploy octa-backend \
  --image gcr.io/octa-v1/backend:latest \
  --platform managed \
  --region asia-southeast1
```

## 注意事项

1. **安全性**
   - 生产环境必须更改 JWT_SECRET_KEY
   - 启用 HTTPS
   - 配置 CORS 白名单

2. **性能优化**
   - 使用 Redis 缓存频繁查询
   - 异步处理分析任务
   - 实施速率限制

3. **监控**
   - 配置 Cloud Logging
   - 设置错误告警
   - 监控 API 响应时间

## 贡献指南

1. 代码风格遵循 PEP 8
2. 所有函数需要 docstring
3. 编写单元测试
4. 提交前运行 `black` 格式化

## License

Private - Octa Project