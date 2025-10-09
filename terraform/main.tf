# Enable IAM API first (required for service account creation)
resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

locals {
  service_name_env = "${var.service_name}-${var.environment}"
  labels = {
    environment = var.environment
    app         = "octa"
    managed_by  = "terraform"
  }
}

# Create GCS bucket for Terraform state if it doesn't exist
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
  
  labels = local.labels
}

# Create GCS bucket for application storage
resource "google_storage_bucket" "octa_storage" {
  name          = "${var.project_id}-octa-storage"
  location      = var.region
  force_destroy = false
  
  # Enable versioning for important data
  versioning {
    enabled = true
  }
  
  # CORS configuration for web uploads
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  # Lifecycle rule for old versions
  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }
  
  labels = local.labels
}

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "octa_backend" {
  repository_id = "octa-backend"
  description   = "Docker repository for OCTA backend"
  format        = "DOCKER"
  location      = var.region
  
  labels = local.labels
}

# Service Account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${local.service_name_env}-sa"
  display_name = "Service Account for ${local.service_name_env}"
  description  = "Service account for Cloud Run service ${local.service_name_env}"
}

# IAM permissions for the service account
resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset([
    # Basic Cloud Run permissions
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter", 
    "roles/cloudtrace.agent",
    
    # Vertex AI permissions
    "roles/aiplatform.user",           # Vertex AI access
    
    # Storage permissions
    "roles/storage.objectAdmin",       # GCS read/write access
    
    # Firestore permissions
    "roles/datastore.user",           # Firestore read/write
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud Run Service
resource "google_cloud_run_service" "octa_backend" {
  name     = local.service_name_env
  location = var.region
  
  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email
      
      containers {
        image = var.container_image != "" ? var.container_image : "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.octa_backend.repository_id}/api:latest"
        
        resources {
          limits = {
            memory = var.cloud_run_memory
            cpu    = var.cloud_run_cpu
          }
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }
        
        env {
          name  = "GCS_BUCKET_NAME"
          value = "${var.project_id}-octa-storage"
        }
        
        env {
          name  = "USE_GCS" 
          value = "true"
        }
        
        # Optional Mapbox token for address resolution
        dynamic "env" {
          for_each = var.mapbox_access_token != "" && var.enable_secret_manager ? [1] : []
          content {
            name = "MAPBOX_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = google_secret_manager_secret.mapbox_token[0].secret_id
                key  = "latest"
              }
            }
          }
        }
        
        # Vertex AI configuration
        env {
          name  = "AI_MODEL_PROVIDER"
          value = var.ai_model_provider
        }
        
        dynamic "env" {
          for_each = var.enable_vertex_ai ? [1] : []
          content {
            name  = "VERTEX_AI_PROJECT"
            value = var.project_id
          }
        }
        
        dynamic "env" {
          for_each = var.enable_vertex_ai ? [1] : []
          content {
            name  = "VERTEX_AI_LOCATION"
            value = var.region
          }
        }
        
        dynamic "env" {
          for_each = var.enable_vertex_ai ? [1] : []
          content {
            name  = "VERTEX_AI_GEMINI_PRO_ENDPOINT"
            value = google_vertex_ai_endpoint.gemini_pro_endpoint[0].name
          }
        }
        
        dynamic "env" {
          for_each = var.enable_vertex_ai ? [1] : []
          content {
            name  = "VERTEX_AI_GEMINI_FLASH_LITE_ENDPOINT"
            value = google_vertex_ai_endpoint.gemini_flash_lite_endpoint[0].name
          }
        }
        
        # Gemini API key removed - using Vertex AI instead
        
        # Qwen API key removed - using Vertex AI instead
        
        # Gemini secret removed - using Vertex AI instead
        
        # Qwen secret removed - using Vertex AI instead
        
        # RevenueCat integration (optional - only if enabled)
        dynamic "env" {
          for_each = var.enable_revenuecat && var.enable_secret_manager ? [1] : []
          content {
            name = "REVENUECAT_API_KEY"
            value_from {
              secret_key_ref {
                name = google_secret_manager_secret.revenuecat_api_key[0].secret_id
                key  = "latest"
              }
            }
          }
        }
        
        dynamic "env" {
          for_each = var.enable_revenuecat && var.enable_secret_manager ? [1] : []
          content {
            name = "REVENUECAT_WEBHOOK_AUTH"
            value_from {
              secret_key_ref {
                name = google_secret_manager_secret.revenuecat_webhook_auth[0].secret_id
                key  = "latest"
              }
            }
          }
        }
        
        ports {
          container_port = 8000
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = tostring(var.min_instances)
        "autoscaling.knative.dev/maxScale"      = tostring(var.max_instances)
      }
      labels = local.labels
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  metadata {
    labels = local.labels
  }
  
  depends_on = []
}

# IAM policy for Cloud Run (allow unauthenticated access if specified)
resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  count = var.allow_unauthenticated ? 1 : 0
  
  service  = google_cloud_run_service.octa_backend.name
  location = google_cloud_run_service.octa_backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}