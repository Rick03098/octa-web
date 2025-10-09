#!/bin/bash
# Complete deployment script for OCTA with Vertex AI
# Usage: ./deploy.sh [ENVIRONMENT]

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ID="boxwood-weaver-467416-a9"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../environments/$ENVIRONMENT"

echo "🚀 Starting OCTA deployment for environment: $ENVIRONMENT"
echo "📍 Project: $PROJECT_ID"
echo "📂 Terraform directory: $TERRAFORM_DIR"

# Check prerequisites
echo ""
echo "🔍 Checking prerequisites..."

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo "   Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
    echo "❌ Error: Not authenticated with gcloud. Please run:"
    echo "   gcloud auth application-default login"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed"
    echo "   Install from: https://www.terraform.io/downloads"
    exit 1
fi

# Check if environment directory exists
if [[ ! -d "$TERRAFORM_DIR" ]]; then
    echo "❌ Error: Environment directory not found: $TERRAFORM_DIR"
    echo "   Available environments: dev, staging, prod"
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Set gcloud project
echo ""
echo "🔧 Setting up gcloud project..."
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo ""
echo "🔌 Enabling required Google Cloud APIs..."
gcloud services enable \
    cloudresourcemanager.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    firebase.googleapis.com \
    firestore.googleapis.com \
    aiplatform.googleapis.com \
    storage-api.googleapis.com \
    --project="$PROJECT_ID"

echo "✅ APIs enabled successfully!"

# Deploy infrastructure with Terraform
echo ""
echo "🏗️  Deploying infrastructure with Terraform..."
cd "$TERRAFORM_DIR"

echo "🔄 Initializing Terraform..."
terraform init

echo "📋 Planning deployment..."
terraform plan

echo "🚀 Applying Terraform configuration..."
terraform apply -auto-approve

echo "✅ Infrastructure deployed successfully!"

# Set up Mapbox secret
echo ""
echo "🔐 Setting up Mapbox secret..."
"$SCRIPT_DIR/setup-mapbox-secret.sh" "$ENVIRONMENT" "$PROJECT_ID"

# Show deployment summary
echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "=========================================="
terraform output setup_instructions
echo ""
echo "🔗 Next steps:"
echo "   1. Build and deploy your application container"
echo "   2. Test the API endpoints"
echo "   3. Configure your iOS app with the new backend URL"
echo ""
echo "📱 iOS Configuration:"
echo "   Update your API base URL to the Cloud Run URL shown above"
echo ""
echo "🛠️  Development:"
echo "   View logs: gcloud run logs tail --service=octa-backend-$ENVIRONMENT --project=$PROJECT_ID"
echo "   Update code: Deploy new container to Artifact Registry"
echo ""
echo "✅ Happy coding! 🎯"