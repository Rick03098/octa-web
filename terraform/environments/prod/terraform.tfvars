project_id            = "boxwood-weaver-467416-a9"
environment           = "prod"
region               = "us-central1"
cloud_run_memory     = "2Gi"
cloud_run_cpu        = "2"
min_instances        = 2
max_instances        = 100
allow_unauthenticated = true

# Vertex AI configuration
enable_vertex_ai     = true
ai_model_provider    = "vertex"

# Mapbox configuration - token will be set via Secret Manager
# mapbox_access_token = "" # Set manually in Secret Manager

# Vertex AI endpoints
vertex_ai_primary_endpoint   = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-pro"
vertex_ai_secondary_endpoint = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-flash-lite"