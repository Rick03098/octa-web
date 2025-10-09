#!/bin/bash
# 一键创建Terraform/CI-CD Service Account脚本
# 使用方法: ./create-service-account.sh

set -e

# 项目配置
PROJECT_ID="boxwood-weaver-467416-a9"
SA_NAME="terraform-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="terraform-deployer-key.json"

echo "🚀 创建Terraform部署Service Account"
echo "📍 项目: ${PROJECT_ID}"
echo "👤 Service Account: ${SA_EMAIL}"
echo ""

# 检查是否已登录gcloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
    echo "❌ 请先登录gcloud:"
    echo "   gcloud auth login"
    echo "   gcloud config set project ${PROJECT_ID}"
    exit 1
fi

# 设置项目
echo "🔧 设置项目..."
gcloud config set project ${PROJECT_ID}

# 检查service account是否已存在
if gcloud iam service-accounts describe ${SA_EMAIL} --project=${PROJECT_ID} >/dev/null 2>&1; then
    echo "✅ Service Account 已存在: ${SA_EMAIL}"
else
    echo "🆕 创建Service Account..."
    gcloud iam service-accounts create ${SA_NAME} \
        --display-name="Terraform Deployer Service Account" \
        --description="Service account for Terraform deployments and CI/CD" \
        --project=${PROJECT_ID}
    echo "✅ Service Account 创建成功"
fi

# 权限列表
ROLES=(
    "roles/editor"
    "roles/storage.admin"
    "roles/run.admin"
    "roles/artifactregistry.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/iam.serviceAccountUser"
    "roles/secretmanager.admin"
    "roles/aiplatform.admin"
    "roles/firebase.admin"
    "roles/cloudbuild.builds.editor"
    "roles/serviceusage.serviceUsageAdmin"
    "roles/resourcemanager.projectIamAdmin"
)

echo ""
echo "🔐 分配权限..."
for role in "${ROLES[@]}"; do
    echo "   添加权限: ${role}"
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="${role}" \
        --quiet
done

echo "✅ 权限分配完成"

# 创建密钥文件
echo ""
echo "🔑 生成密钥文件..."
gcloud iam service-accounts keys create ${KEY_FILE} \
    --iam-account=${SA_EMAIL} \
    --project=${PROJECT_ID}

echo "✅ 密钥文件已生成: ${KEY_FILE}"

# 显示结果
echo ""
echo "🎉 Service Account 创建完成!"
echo "=================================================="
echo "Service Account Email: ${SA_EMAIL}"
echo "Key File: ${KEY_FILE}"
echo ""
echo "📋 密钥文件内容:"
echo "=================================================="
cat ${KEY_FILE}
echo ""
echo "=================================================="
echo ""
echo "🔧 接下来的步骤:"
echo "1. 复制上面的JSON内容"
echo "2. 保存为环境变量或文件"
echo "3. 运行Terraform部署"
echo ""
echo "💡 使用方法:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/${KEY_FILE}"
echo "   terraform init && terraform plan && terraform apply"
echo ""
echo "🔒 安全提醒:"
echo "   - 请妥善保管密钥文件"
echo "   - 不要提交到版本控制系统"
echo "   - 定期轮换密钥 (建议90天)"