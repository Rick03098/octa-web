# Vertex AI Configuration (Optional - for future migration)
# Uncomment this file when ready to switch from Gemini API to Vertex AI

# Enable Vertex AI API
resource "google_project_service" "vertex_ai" {
  count   = var.enable_vertex_ai ? 1 : 0
  service = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

# Vertex AI permissions are now handled in main.tf cloud_run_sa_roles

# Vertex AI endpoint configuration for Gemini 2.5 Pro
resource "google_vertex_ai_endpoint" "gemini_pro_endpoint" {
  count        = var.enable_vertex_ai ? 1 : 0
  name         = "gemini-2-5-pro-${var.environment}"
  display_name = "Gemini 2.5 Pro Endpoint ${var.environment}"
  description  = "Endpoint for Gemini 2.5 Pro model inference"
  location     = var.region
  
  labels = merge(local.labels, {
    model = "gemini-2-5-pro"
  })
}

# Vertex AI endpoint configuration for Gemini 2.5 Flash Lite
resource "google_vertex_ai_endpoint" "gemini_flash_lite_endpoint" {
  count        = var.enable_vertex_ai ? 1 : 0
  name         = "gemini-2-5-flash-lite-${var.environment}"
  display_name = "Gemini 2.5 Flash Lite Endpoint ${var.environment}"
  description  = "Endpoint for Gemini 2.5 Flash Lite model inference"
  location     = var.region
  
  labels = merge(local.labels, {
    model = "gemini-2-5-flash-lite"
  })
}

# Output Vertex AI configuration
output "vertex_ai_config" {
  value = var.enable_vertex_ai ? {
    enabled           = true
    primary_endpoint  = try(google_vertex_ai_endpoint.gemini_pro_endpoint[0].name, "")
    secondary_endpoint = try(google_vertex_ai_endpoint.gemini_flash_lite_endpoint[0].name, "")
    project          = var.project_id
    location         = var.region
  } : {
    enabled = false
  }
  description = "Vertex AI configuration with dual endpoints"
}