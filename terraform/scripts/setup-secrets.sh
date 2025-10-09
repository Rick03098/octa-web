#!/bin/bash

# Script to set up Secret Manager secrets for OCTA application
# Usage: ./setup-secrets.sh <environment> <project-id>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 <environment> <project-id>${NC}"
    echo "Example: $0 dev my-gcp-project"
    exit 1
fi

ENVIRONMENT=$1
PROJECT_ID=$2

echo -e "${GREEN}Setting up secrets for environment: ${ENVIRONMENT}${NC}"
echo -e "${GREEN}Project ID: ${PROJECT_ID}${NC}"

# Set the project
gcloud config set project ${PROJECT_ID}

# Function to create or update a secret
create_or_update_secret() {
    local SECRET_NAME=$1
    local SECRET_VALUE=$2
    
    # Check if secret exists
    if gcloud secrets describe ${SECRET_NAME} >/dev/null 2>&1; then
        echo -e "${YELLOW}Secret ${SECRET_NAME} exists, creating new version...${NC}"
        echo -n "${SECRET_VALUE}" | gcloud secrets versions add ${SECRET_NAME} --data-file=-
    else
        echo -e "${GREEN}Creating secret ${SECRET_NAME}...${NC}"
        echo -n "${SECRET_VALUE}" | gcloud secrets create ${SECRET_NAME} --data-file=- --replication-policy="automatic"
    fi
}

# Prompt for API keys
echo ""
read -sp "Enter Gemini API Key: " GEMINI_API_KEY
echo ""
read -sp "Enter Qwen API Key: " QWEN_API_KEY
echo ""
read -sp "Enter RevenueCat API Key: " REVENUECAT_API_KEY
echo ""
read -sp "Enter RevenueCat Webhook Auth Token: " REVENUECAT_WEBHOOK_AUTH
echo ""

# Create secrets
echo -e "\n${GREEN}Creating secrets in Secret Manager...${NC}"
create_or_update_secret "gemini-api-key-${ENVIRONMENT}" "${GEMINI_API_KEY}"
create_or_update_secret "qwen-api-key-${ENVIRONMENT}" "${QWEN_API_KEY}"
create_or_update_secret "revenuecat-api-key-${ENVIRONMENT}" "${REVENUECAT_API_KEY}"
create_or_update_secret "revenuecat-webhook-auth-${ENVIRONMENT}" "${REVENUECAT_WEBHOOK_AUTH}"

echo -e "\n${GREEN}✓ Secrets successfully created/updated!${NC}"

# Verify secrets
echo -e "\n${GREEN}Verifying secrets...${NC}"
gcloud secrets list --filter="name:gemini-api-key-${ENVIRONMENT} OR name:qwen-api-key-${ENVIRONMENT}" --format="table(name,createTime)"

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}Note: The Cloud Run service will automatically access these secrets when deployed.${NC}"