terraform {
  backend "gcs" {
    bucket = "boxwood-weaver-467416-a9-terraform-state"
    prefix = "terraform/state"
  }
}