variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "octa-backend"
}

variable "container_image" {
  description = "Container image URL"
  type        = string
  default     = ""
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "1Gi"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service"
  type        = string
  default     = "1"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access to Cloud Run service"
  type        = bool
  default     = true
}

variable "enable_secret_manager" {
  description = "Enable Secret Manager for API keys"
  type        = bool
  default     = true
}

variable "gemini_api_key" {
  description = "Gemini API key (only used if Secret Manager is disabled)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "qwen_api_key" {
  description = "Qwen API key (only used if Secret Manager is disabled)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "firestore_location" {
  description = "Location for Firestore database"
  type        = string
  default     = "us-central1"
}

variable "ios_bundle_id" {
  description = "iOS app bundle identifier"
  type        = string
  default     = "com.octa.fengshuiapp"
}

variable "enable_vertex_ai" {
  description = "Enable Vertex AI instead of Gemini API"
  type        = bool
  default     = false
}

variable "ai_model_provider" {
  description = "AI model provider: gemini or vertex"
  type        = string
  default     = "gemini"
  validation {
    condition     = contains(["gemini", "vertex"], var.ai_model_provider)
    error_message = "AI model provider must be either 'gemini' or 'vertex'"
  }
}

variable "enable_revenuecat" {
  description = "Enable RevenueCat integration (for subscription management)"
  type        = bool
  default     = false
}

variable "mapbox_access_token" {
  description = "Mapbox access token for address resolution (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vertex_ai_primary_endpoint" {
  description = "Primary Vertex AI model endpoint"
  type        = string
  default     = ""
}

variable "vertex_ai_secondary_endpoint" {
  description = "Secondary Vertex AI model endpoint"
  type        = string
  default     = ""
}