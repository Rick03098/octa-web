project_id            = "boxwood-weaver-467416-a9"
environment           = "staging"
region               = "us-central1"
cloud_run_memory     = "1Gi"
cloud_run_cpu        = "1"
min_instances        = 1
max_instances        = 50
allow_unauthenticated = true

# Vertex AI configuration
enable_vertex_ai     = true
ai_model_provider    = "vertex"

# Mapbox configuration - token will be set via Secret Manager
# mapbox_access_token = "" # Set manually in Secret Manager

# Vertex AI endpoints
vertex_ai_primary_endpoint   = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-pro"
vertex_ai_secondary_endpoint = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-flash-lite"