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

resource "google_compute_network" "app_chibawest_gamecenter_bot" {
  name = "app-chibawest-gamecenter-bot"
}

resource "google_compute_firewall" "app_chibawest_gamecenter_bot" {
  name    = "app-chibawest-gamecenter-bot"
  network = google_compute_network.app_chibawest_gamecenter_bot.name

  # ICMP (ping)
  allow {
    protocol = "icmp"
  }

  # SSH (for RCON-CLI access)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["app-chibawest-gamecenter-bot"]
}

resource "google_compute_instance" "app_chibawest_gamecenter_bot" {
  name         = "app-chibawest-gamecenter-bot-instance"
  machine_type = "e2-micro"
  zone         = local.zone
  tags         = ["app-chibawest-gamecenter-bot"]

  metadata_startup_script = <<-EOF
    mkdir -p /var/chibawest-gamecenter-bot
  
    toolbox --version \
    && toolbox -q /google-cloud-sdk/bin/gcloud secrets versions access latest \
      --secret="app-chibawest-gamecenter-bot-application-credentials" > \
      /var/chibawest-gamecenter-bot/google_application_credentials.json \
    && docker run -d --rm \
        -v /var/chibawest-gamecenter-bot:/chibawest-gamecenter-bot/data \
        --name gc-bot \
        mytk0u0/chibawest-gamecenter-bot:latest
  EOF

  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.app_chibawest_gamecenter_bot.name
    access_config {}
  }

  service_account {
    email  = google_service_account.app_chibawest_gamecenter_bot.email
    scopes = ["cloud-platform"]
  }
}
