# Enable Secret Manager API
resource "google_project_service" "secret_manager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Secret Manager secrets for API keys
# Gemini API key secret removed - using Vertex AI instead

# Qwen API key secret removed - using Vertex AI instead

# Mapbox access token for address resolution (optional)
resource "google_secret_manager_secret" "mapbox_token" {
  count     = var.mapbox_access_token != "" && var.enable_secret_manager ? 1 : 0
  secret_id = "mapbox-access-token-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(local.labels, {
    service = "mapbox"
  })
  
  depends_on = [google_project_service.secret_manager]
}

# Create the secret version with the token value
resource "google_secret_manager_secret_version" "mapbox_token_version" {
  count       = var.mapbox_access_token != "" && var.enable_secret_manager ? 1 : 0
  secret      = google_secret_manager_secret.mapbox_token[0].id
  secret_data = var.mapbox_access_token
}

# Grant Cloud Run access to Mapbox secret
resource "google_secret_manager_secret_iam_member" "mapbox_secret_access" {
  count     = var.mapbox_access_token != "" && var.enable_secret_manager ? 1 : 0
  secret_id = google_secret_manager_secret.mapbox_token[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Note: The actual secret values will be created manually or via script
# Terraform will only create the secret containers, not the values

# Grant Cloud Run service account access to read secrets
# Gemini secret access removed - using Vertex AI instead

# Qwen secret access removed - using Vertex AI instead

# Data sources to read existing secret versions (if they exist)
# Gemini key data source removed - using Vertex AI instead

# Qwen key data source removed - using Vertex AI instead