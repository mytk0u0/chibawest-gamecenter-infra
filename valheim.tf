resource "google_service_account" "valheim" {
  account_id   = "valheim"
  display_name = "Valheim"
}

resource "google_compute_disk" "valheim" {
  name    = "valheim-disk"
  size    = 10
  type    = "pd-ssd"
  zone    = local.zone
  project = local.project
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

  metadata_startup_script = <<-EOF
    if blkid /dev/sdb;then
        :
    else
        mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
    fi
    mkdir -p /mnt/disks/valheim
    mount -o discard,defaults /dev/sdb /mnt/disks/valheim
    mkdir -p /mnt/disks/valheim/{config,data}

    docker run -d --rm \
        --name valheim-server \
        --cap-add=sys_nice \
        --stop-timeout 120 \
        -p 2456-2457:2456-2457/udp \
        -v /mnt/disks/valheim/config:/config \
        -v /mnt/disks/valheim/data:/opt/valheim \
        -e SERVER_NAME="Chiba West Gamecenter" \
        -e WORLD_NAME="ChibaWest" \
        -e SERVER_PASS="chibawest" \
        lloesche/valheim-server
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

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_attached_disk" "valheim" {
  disk     = google_compute_disk.valheim.id
  instance = google_compute_instance.valheim.id
}

