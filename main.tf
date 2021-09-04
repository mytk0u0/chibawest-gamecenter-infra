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

resource "google_cloudbuild_trigger" "chibawest_gamecenter_apps" {
  name = "chibawest-gamecenter-apps-was-merged"
  trigger_template {
    branch_name = "main"
    repo_name   = "github_mytk0u0_chibawest-gamecenter-apps"
  }

  filename = "cloudbuild.yaml"
}
