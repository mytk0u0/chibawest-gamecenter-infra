terraform {
  backend "gcs" {
    bucket = "chibawest-gamecenter-minecraft"
    prefix = "terraform/state"
  }
}

locals {
  project = "chibawest-gamecenter"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}

resource "google_cloudbuild_trigger" "chibawest_gamecenter_infra" {
  name = "chibawest-gamecenter-infra-was-merged"
  trigger_template {
    branch_name = "main"
    repo_name   = "github_mytk0u0_chibawest-gamecenter-infra"
  }

  filename = "cloudbuild.yaml"
}

# Cloud Build
resource "google_artifact_registry_repository" "app_cloudbuild_terraform_builder" {
  provider      = google-beta
  project       = local.project
  location      = local.region
  repository_id = "app-cloudbuild-terraform-builder"
  description   = "Container Repository of CloudBuild Terraform Builder"
  format        = "DOCKER"
}
