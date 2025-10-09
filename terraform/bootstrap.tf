# Bootstrap Terraform deployer service account
# This file creates the service account needed for subsequent Terraform operations

resource "google_service_account" "terraform_deployer" {
  account_id   = "terraform-deployer"
  display_name = "Terraform Deployer Service Account"
  description  = "Service account for Terraform deployments and CI/CD"
  project      = var.project_id
}

# Grant all necessary permissions to the terraform deployer service account
resource "google_project_iam_member" "terraform_deployer_roles" {
  for_each = toset([
    "roles/editor",
    "roles/storage.admin",
    "roles/run.admin", 
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin",
    "roles/aiplatform.admin",
    "roles/firebase.admin",
    "roles/cloudbuild.builds.editor",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_deployer.email}"
}

# Generate service account key
resource "google_service_account_key" "terraform_deployer_key" {
  service_account_id = google_service_account.terraform_deployer.name
}

# Output the service account key (base64 encoded)
output "terraform_deployer_key" {
  value = google_service_account_key.terraform_deployer_key.private_key
  sensitive = true
}

output "terraform_deployer_email" {
  value = google_service_account.terraform_deployer.email
}