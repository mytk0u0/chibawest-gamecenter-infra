resource "google_service_account" "valheim" {
  account_id   = "valheim"
  display_name = "Valheim"
}


resource "google_compute_address" "valheim" {
  name   = "valheim-ip"
  region = local.region
}

/*
# Quota 'NETWORKS' exceeded. Limit: 5.0 globally.
# ↑のエラー対策でとりあえず今はマイクラ用のもので代用
resource "google_compute_network" "valheim" {
  name = "valheim-network"
}
*/

resource "google_compute_firewall" "valheim" {
  name    = "valheim-firewall"
  network = google_compute_network.minecraft.name

  # Valheim Server Port
  allow {
    protocol = "udp"
    ports    = ["2456-2458"]
  }

  # ICMP (ping)
  allow {
    protocol = "icmp"
  }

  # SSH
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["valheim"]
}

resource "google_compute_instance" "valheim" {
  name         = "valheim-instance"
  machine_type = "n1-standard-1"
  zone         = local.zone
  tags         = ["valheim"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      size  = 15
      type  = "pd-ssd"
      image = "ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
      nat_ip = google_compute_address.valheim.address
    }
  }

  service_account {
    email  = google_service_account.valheim.email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = true # Closes within 24 hours (sometimes sooner)
    automatic_restart = false
  }
}
