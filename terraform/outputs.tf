output "cloud_run_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_service.octa_backend.status[0].url
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.cloud_run_sa.email
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.octa_backend.repository_id}"
}

output "terraform_state_bucket" {
  description = "GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state.name
}

output "octa_storage_bucket" {
  description = "GCS bucket for OCTA application storage"
  value       = google_storage_bucket.octa_storage.name
}

output "firebase_config" {
  description = "Firebase configuration"
  value = {
    project_id   = var.project_id
    database_url = "https://${var.project_id}-default-rtdb.firebaseio.com/"
    ios_app_id   = google_firebase_apple_app.ios_app.app_id
  }
}

output "setup_instructions" {
  description = "Next steps to complete setup"
  value = <<-EOT
    
    ========================================
    DEPLOYMENT COMPLETE - VERTEX AI READY
    ========================================
    
    1. Cloud Run service URL:
       ${google_cloud_run_service.octa_backend.status[0].url}
    
    2. GCS Storage bucket:
       ${google_storage_bucket.octa_storage.name}
    
    3. Firestore database:
       https://console.firebase.google.com/project/${var.project_id}/firestore
    
    4. Vertex AI console:
       https://console.cloud.google.com/vertex-ai?project=${var.project_id}
    
    5. Service account (with all permissions):
       ${google_service_account.cloud_run_sa.email}
    
    ✅ No API keys needed - using service account authentication
    ========================================
  EOT
}