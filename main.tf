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

resource "google_cloudbuild_trigger" "chibawest_gamecenter_manifest" {
  name = "chibawest-gamecenter-manifest-was-merged"
  trigger_template {
    branch_name = "main"
    repo_name   = "github_mytk0u0_chibawest-gamecenter-manifest"
  }

  filename = "cloudbuild.yaml"
}

resource "google_pubsub_topic" "chibawest_gamecenter_apps_was_built" {
  name = "chibawest-gamecenter-apps-was-built"
}

/*
2021/08/26現在、pub/subによって特定リポジトリのcloudconfig.yamlによるビルドを実行することはできなさそう。
なので以下に相当するトリガーは↓から手動で作成する必要がある。
https://console.cloud.google.com/cloud-build/builds?project=chibawest-gamecenter

resource "google_cloudbuild_trigger" "chibawest_gamecenter_apps_was_built" {
  name = "chibawest-gamecenter-apps-was-built"
  pubsub_config {
    topic = google_pubsub_topic.chibawest_gamecenter_apps_was_built.id
    branch_name = "main"  # これが対応してない
    repo_name = "github_mytk0u0_chibawest-gamecenter-manifest"  # これが対応してない
  }

  filename = "cloudbuild.yaml"
}
*/
