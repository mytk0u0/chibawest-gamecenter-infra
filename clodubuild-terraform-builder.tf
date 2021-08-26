resource "google_artifact_registry_repository" "app_cloudbuild_terraform_builder" {
  provider      = google-beta
  project       = local.project
  location      = local.region
  repository_id = "app-cloudbuild-terraform-builder"
  description   = "Container Repository of CloudBuild Terraform Builder"
  format        = "DOCKER"
}