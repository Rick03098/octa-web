#!/bin/bash
# Setup Mapbox Secret in Google Secret Manager
# Usage: ./setup-mapbox-secret.sh [ENVIRONMENT] [PROJECT_ID]

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ID=${2:-boxwood-weaver-467416-a9}
MAPBOX_TOKEN="${MAPBOX_ACCESS_TOKEN:-}"  # Set via environment variable

echo "🔐 Setting up Mapbox secret for environment: $ENVIRONMENT"
echo "📍 Project: $PROJECT_ID"

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
    echo "❌ Error: Not authenticated with gcloud. Please run:"
    echo "   gcloud auth login"
    exit 1
fi

# Function to create or update secret
create_or_update_secret() {
    local secret_name="$1"
    local secret_value="$2"
    
    echo "🔍 Checking if secret exists: $secret_name"
    
    # Check if secret exists
    if gcloud secrets describe "$secret_name" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo "🔄 Updating existing secret: $secret_name"
        echo -n "$secret_value" | gcloud secrets versions add "$secret_name" --data-file=- --project="$PROJECT_ID"
        echo "✅ Secret updated successfully"
    else
        echo "🆕 Creating new secret: $secret_name"
        echo -n "$secret_value" | gcloud secrets create "$secret_name" --data-file=- --project="$PROJECT_ID" --replication-policy="automatic"
        echo "✅ Secret created successfully"
    fi
}

# Create MAPBOX secret
SECRET_NAME="mapbox-access-token-${ENVIRONMENT}"
create_or_update_secret "$SECRET_NAME" "$MAPBOX_TOKEN"

echo ""
echo "🎉 Mapbox secret setup completed!"
echo "📝 Secret name: $SECRET_NAME"
echo "🔗 View in console: https://console.cloud.google.com/security/secret-manager/secret/$SECRET_NAME?project=$PROJECT_ID"
echo ""
echo "✅ Your Cloud Run service can now access the Mapbox token securely!"