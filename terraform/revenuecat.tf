# RevenueCat Integration Configuration
# Note: RevenueCat API keys are managed in Secret Manager

# Create secrets for RevenueCat API keys (only if enabled)
resource "google_secret_manager_secret" "revenuecat_api_key" {
  count     = var.enable_revenuecat ? 1 : 0
  secret_id = "revenuecat-api-key-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(local.labels, {
    service = "revenuecat"
  })
}

resource "google_secret_manager_secret" "revenuecat_webhook_auth" {
  count     = var.enable_revenuecat ? 1 : 0
  secret_id = "revenuecat-webhook-auth-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(local.labels, {
    service = "revenuecat"
  })
}

# Grant Cloud Run access to RevenueCat secrets (only if enabled)
resource "google_secret_manager_secret_iam_member" "revenuecat_api_access" {
  count     = var.enable_revenuecat ? 1 : 0
  secret_id = google_secret_manager_secret.revenuecat_api_key[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "revenuecat_webhook_access" {
  count     = var.enable_revenuecat ? 1 : 0
  secret_id = google_secret_manager_secret.revenuecat_webhook_auth[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Firestore collections for subscription data
# (Actual collections will be created by the application)
# This is just documentation of the structure
locals {
  firestore_collections = {
    users = {
      description = "User profiles with subscription status"
      fields = {
        email           = "string"
        created_at      = "timestamp"
        is_premium      = "boolean"
        subscription_id = "string (RevenueCat subscription ID)"
        expires_at      = "timestamp"
      }
    }
    subscriptions = {
      description = "Detailed subscription records from RevenueCat"
      fields = {
        user_id         = "string"
        product_id      = "string"
        purchase_date   = "timestamp"
        expiry_date     = "timestamp"
        status          = "string (active, expired, cancelled)"
        platform        = "string (ios, android)"
        revenuecat_id   = "string"
      }
    }
    premium_features = {
      description = "Track premium feature usage"
      fields = {
        user_id      = "string"
        feature      = "string (floorplan_analysis, advanced_bazi, etc)"
        used_at      = "timestamp"
        credits_used = "number"
      }
    }
  }
}