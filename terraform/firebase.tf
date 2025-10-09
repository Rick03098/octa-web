# Enable required Firebase APIs
resource "google_project_service" "firebase" {
  service = "firebase.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "identity_toolkit" {
  service = "identitytoolkit.googleapis.com"
  disable_on_destroy = false
}

# Firebase project
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
  
  depends_on = [
    google_project_service.firebase,
  ]
}

# Firestore Database
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"
  
  # Concurrency control
  concurrency_mode = "OPTIMISTIC"
  
  # App Engine integration (required for Firestore)
  app_engine_integration_mode = "DISABLED"
  
  depends_on = [
    google_project_service.firestore,
  ]
}

# Firestore Security Rules
resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta
  project  = var.project_id
  
  source {
    files {
      name    = "firestore.rules"
      content = file("../../firebase-rules/firestore.rules")
    }
  }
  
  depends_on = [
    google_firestore_database.default,
  ]
}

resource "google_firebaserules_release" "firestore" {
  provider     = google-beta
  project      = var.project_id
  ruleset_name = google_firebaserules_ruleset.firestore.name
  name         = "cloud.firestore"
  
  depends_on = [
    google_firebaserules_ruleset.firestore,
  ]
}

# iOS App Configuration
resource "google_firebase_apple_app" "ios_app" {
  provider     = google-beta
  project      = var.project_id
  display_name = "OCTA iOS App"
  bundle_id    = var.ios_bundle_id
  
  depends_on = [
    google_firebase_project.default,
  ]
}

# Generate Firebase config for iOS
data "google_firebase_apple_app_config" "ios_config" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_apple_app.ios_app.app_id
}

# Save Firebase config to local file (for reference)
resource "local_file" "firebase_ios_config" {
  content  = data.google_firebase_apple_app_config.ios_config.config_file_contents
  filename = "${path.module}/outputs/GoogleService-Info-${var.environment}.plist"
}