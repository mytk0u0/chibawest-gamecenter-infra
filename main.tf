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

resource "google_container_cluster" "chibawest_gamecenter" {
  name     = "chibawest-gamecenter"
  location = local.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_cloudbuild_trigger" "chibawest_gamecenter" {
  trigger_template {
    branch_name = "master"
    repo_name   = "chibawest-gamecenter"
  }

  filename = "cloudbuild.yaml"
}
