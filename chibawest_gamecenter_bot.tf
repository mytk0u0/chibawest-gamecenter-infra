resource "google_service_account" "app_chibawest_gamecenter_bot" {
  account_id   = "app-chibawest-gamecenter-bot"
  display_name = "Chibawest Gamecenter Bot"
}

resource "google_project_iam_custom_role" "app_chibawest_gamecenter_bot" {
  role_id     = "app_chibawest_gamecenter_bot_role"
  title       = "Chibawest Gamecenter Bot's Role"
  description = "Can do Bot required action."
  permissions = [
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.get",
  ]
}

resource "google_project_iam_member" "bot_user" {
  role   = google_project_iam_custom_role.app_chibawest_gamecenter_bot.id
  member = "serviceAccount:${google_service_account.app_chibawest_gamecenter_bot.email}"
}

resource "google_project_iam_member" "artifact_reader" {
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.app_chibawest_gamecenter_bot.email}"
}

resource "google_project_iam_member" "secret_accessor" {
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.app_chibawest_gamecenter_bot.email}"
}

resource "google_artifact_registry_repository" "app_chibawest_gamecenter_bot" {
  provider      = google-beta
  project       = local.project
  location      = local.region
  repository_id = "app-chibawest-gamecenter-bot"
  description   = "Container Repository of Chibawest Gamecenter Bot"
  format        = "DOCKER"
}

resource "google_container_node_pool" "app_chibawest_gamecenter_bot" {
  name     = "app-chibawest-gamecenter-bot-node-pool"
  location = local.region
  cluster  = google_container_cluster.chibawest_gamecenter.name

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  node_config {
    preemptible  = true
    machine_type = "e2-micro"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.app_chibawest_gamecenter_bot.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
