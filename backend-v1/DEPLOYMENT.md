# Octa Backend 部署指南

## 部署前准备

### 1. GCP项目设置

```bash
# 设置项目ID
export PROJECT_ID=octa-v1
gcloud config set project $PROJECT_ID

# 启用必要的API
gcloud services enable \
  run.googleapis.com \
  firestore.googleapis.com \
  storage.googleapis.com \
  cloudtasks.googleapis.com \
  secretmanager.googleapis.com \
  containerregistry.googleapis.com
```

### 2. Firestore设置

```bash
# 创建Firestore数据库（Native模式）
gcloud firestore databases create --region=asia-southeast1

# 创建必要的集合（会在首次使用时自动创建）
# - users
# - bazi_profiles
# - media
# - analysis_jobs
# - analysis_results
# - reports
# - subscriptions
```

### 3. Cloud Storage设置

```bash
# 创建媒体文件bucket
gsutil mb -l asia-southeast1 gs://octa-v1-media

# 设置CORS（允许前端直接上传）
cat > cors.json <<EOF
[
  {
    "origin": ["https://app.octa.ai", "http://localhost:3000"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "responseHeader": ["Content-Type"],
    "maxAgeSeconds": 3600
  }
]
EOF

gsutil cors set cors.json gs://octa-v1-media
```

### 4. Secret Manager设置

```bash
# 创建JWT密钥
echo -n "$(openssl rand -base64 32)" | \
  gcloud secrets create jwt-secret-key --data-file=-

# 创建RevenueCat API密钥
echo -n "your_revenuecat_api_key" | \
  gcloud secrets create revenuecat-api-key --data-file=-

# 创建RevenueCat Webhook密钥
echo -n "your_revenuecat_webhook_secret" | \
  gcloud secrets create revenuecat-webhook-secret --data-file=-
```

## 本地开发部署

### 使用Docker Compose（推荐）

```bash
# 创建docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./app:/app/app
    environment:
      - ENVIRONMENT=development
      - DEBUG=true
EOF

# 启动服务
docker-compose up --build
```

### 直接运行

```bash
# 使用开发脚本
./run_dev.sh

# 或手动运行
source venv/bin/activate
python app/main.py
```

## 生产部署（Cloud Run）

### 方式1: 使用gcloud CLI

```bash
# 1. 构建Docker镜像
docker build -t gcr.io/$PROJECT_ID/octa-backend:latest .

# 2. 推送到Container Registry
docker push gcr.io/$PROJECT_ID/octa-backend:latest

# 3. 部署到Cloud Run
gcloud run deploy octa-backend \
  --image gcr.io/$PROJECT_ID/octa-backend:latest \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 10 \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --set-env-vars ENVIRONMENT=production,DEBUG=false \
  --set-env-vars GOOGLE_CLOUD_PROJECT=$PROJECT_ID \
  --set-env-vars GCS_BUCKET=octa-v1-media \
  --set-secrets JWT_SECRET_KEY=jwt-secret-key:latest \
  --set-secrets REVENUECAT_API_KEY=revenuecat-api-key:latest \
  --set-secrets REVENUECAT_WEBHOOK_SECRET=revenuecat-webhook-secret:latest
```

### 方式2: 使用Cloud Build

```bash
# 创建cloudbuild.yaml
cat > cloudbuild.yaml <<EOF
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/\$PROJECT_ID/octa-backend:latest', '.']

  # Push the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/\$PROJECT_ID/octa-backend:latest']

  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'octa-backend'
      - '--image=gcr.io/\$PROJECT_ID/octa-backend:latest'
      - '--region=asia-southeast1'
      - '--platform=managed'
      - '--allow-unauthenticated'

images:
  - 'gcr.io/\$PROJECT_ID/octa-backend:latest'
EOF

# 触发构建
gcloud builds submit --config cloudbuild.yaml
```

## 环境变量配置

### 生产环境必需变量

```bash
# 核心配置
ENVIRONMENT=production
DEBUG=false
API_VERSION=v1

# Google Cloud
GOOGLE_CLOUD_PROJECT=octa-v1
GCS_BUCKET=octa-v1-media
FIRESTORE_DATABASE=(default)

# 安全（从Secret Manager获取）
JWT_SECRET_KEY=${jwt-secret-key}
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# RevenueCat（从Secret Manager获取）
REVENUECAT_API_KEY=${revenuecat-api-key}
REVENUECAT_WEBHOOK_SECRET=${revenuecat-webhook-secret}

# 速率限制
RATE_LIMIT_PER_MINUTE=60
RATE_LIMIT_PER_HOUR=1000

# 分析设置
MAX_IMAGE_SIZE_MB=10
ANALYSIS_TIMEOUT_SECONDS=300

# CORS
CORS_ORIGINS=["https://app.octa.ai"]
```

## CI/CD设置（GitHub Actions）

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloud Run

on:
  push:
    branches:
      - main

env:
  PROJECT_ID: octa-v1
  SERVICE_NAME: octa-backend
  REGION: asia-southeast1

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ env.PROJECT_ID }}

      - name: Configure Docker
        run: gcloud auth configure-docker

      - name: Build Docker image
        run: |
          docker build -t gcr.io/$PROJECT_ID/$SERVICE_NAME:$GITHUB_SHA .
          docker tag gcr.io/$PROJECT_ID/$SERVICE_NAME:$GITHUB_SHA \
                     gcr.io/$PROJECT_ID/$SERVICE_NAME:latest

      - name: Push Docker image
        run: |
          docker push gcr.io/$PROJECT_ID/$SERVICE_NAME:$GITHUB_SHA
          docker push gcr.io/$PROJECT_ID/$SERVICE_NAME:latest

      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy $SERVICE_NAME \
            --image gcr.io/$PROJECT_ID/$SERVICE_NAME:$GITHUB_SHA \
            --region $REGION \
            --platform managed
```

## 监控和日志

### 设置日志查询

```bash
# 查看应用日志
gcloud logging read "resource.type=cloud_run_revision AND \
  resource.labels.service_name=octa-backend" \
  --limit 50 \
  --format json

# 查看错误日志
gcloud logging read "resource.type=cloud_run_revision AND \
  resource.labels.service_name=octa-backend AND \
  severity>=ERROR" \
  --limit 50
```

### 设置告警

```bash
# 创建错误率告警
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Octa Backend Error Rate" \
  --condition-display-name="Error rate > 1%" \
  --condition-threshold-value=0.01 \
  --condition-threshold-duration=300s
```

## 健康检查

部署后验证：

```bash
# 获取服务URL
SERVICE_URL=$(gcloud run services describe octa-backend \
  --region asia-southeast1 \
  --format 'value(status.url)')

# 健康检查
curl $SERVICE_URL/healthz
# 预期: {"status":"healthy","service":"octa-backend","version":"v1"}

# 就绪检查
curl $SERVICE_URL/readyz
# 预期: {"status":"ready","checks":{...},"version":"v1"}

# API文档（仅开发环境）
# open $SERVICE_URL/docs
```

## 回滚策略

```bash
# 查看历史版本
gcloud run revisions list --service octa-backend --region asia-southeast1

# 回滚到特定版本
gcloud run services update-traffic octa-backend \
  --to-revisions REVISION_NAME=100 \
  --region asia-southeast1
```

## 性能优化

### 1. 预热实例

```bash
# 设置最小实例数（避免冷启动）
gcloud run services update octa-backend \
  --min-instances 1 \
  --region asia-southeast1
```

### 2. 调整资源配置

```bash
# 增加内存和CPU
gcloud run services update octa-backend \
  --memory 1Gi \
  --cpu 2 \
  --region asia-southeast1
```

### 3. 并发设置

```bash
# 设置最大并发请求数
gcloud run services update octa-backend \
  --concurrency 80 \
  --region asia-southeast1
```

## 安全加固

### 1. 启用VPC连接器（可选）

```bash
# 创建VPC连接器
gcloud compute networks vpc-access connectors create octa-connector \
  --region asia-southeast1 \
  --range 10.8.0.0/28

# 连接Cloud Run到VPC
gcloud run services update octa-backend \
  --vpc-connector octa-connector \
  --region asia-southeast1
```

### 2. 限制入站流量（可选）

```bash
# 仅允许内部流量或通过负载均衡
gcloud run services update octa-backend \
  --ingress internal-and-cloud-load-balancing \
  --region asia-southeast1
```

## 故障排查

### 常见问题

1. **服务无法启动**
   ```bash
   # 查看日志
   gcloud logging read "resource.type=cloud_run_revision" --limit 50
   ```

2. **数据库连接失败**
   - 检查Firestore是否已启用
   - 验证服务账号权限

3. **存储访问失败**
   - 检查GCS bucket权限
   - 验证CORS配置

4. **环境变量缺失**
   - 确认Secret Manager设置
   - 检查Cloud Run环境变量配置

## 成本优化

1. **使用最小实例**: 开发环境设为0，生产环境根据流量调整
2. **合理设置超时**: 避免长时间运行的请求
3. **启用请求缓存**: 使用Redis缓存常见请求
4. **优化镜像大小**: 使用multi-stage build

---

**部署检查清单**

- [ ] GCP项目已创建
- [ ] Firestore已启用
- [ ] GCS bucket已创建
- [ ] Secret Manager密钥已设置
- [ ] Docker镜像已构建
- [ ] Cloud Run服务已部署
- [ ] 健康检查通过
- [ ] 日志正常输出
- [ ] 告警已配置
- [ ] CI/CD已设置

**下一步**: 配置自定义域名和SSL证书（可选）