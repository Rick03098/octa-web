project_id            = "boxwood-weaver-467416-a9"
environment           = "dev"
region               = "us-central1"
cloud_run_memory     = "512Mi"
cloud_run_cpu        = "1"
min_instances        = 0
max_instances        = 10
allow_unauthenticated = true
container_image      = "us-central1-docker.pkg.dev/boxwood-weaver-467416-a9/octa-backend/api:v3"

# Vertex AI configuration
enable_vertex_ai     = true
ai_model_provider    = "vertex"

# Secret Manager configuration
enable_secret_manager = true

# Mapbox configuration - token will be set via Secret Manager
mapbox_access_token = "placeholder-token" # Will be replaced with actual token in Secret Manager

# Vertex AI endpoints
vertex_ai_primary_endpoint   = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-pro"
vertex_ai_secondary_endpoint = "projects/boxwood-weaver-467416-a9/locations/us-central1/publishers/google/models/gemini-2.5-flash-lite"