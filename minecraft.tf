resource "google_service_account" "minecraft" {
  account_id   = "minecraft"
  display_name = "Minecraft"
}

# マイクラのデータ置き場 (これが死んだら終わり)
resource "google_compute_disk" "minecraft_data" {
  name    = "minecraft-data-disk"
  size    = 35
  type    = "pd-ssd"
  zone    = local.zone
  project = local.project
}

resource "google_compute_disk" "minecraft_image" {
  name    = "minecraft-image-disk"
  size    = 10
  type    = "pd-ssd"
  zone    = local.zone
  image   = "cos-cloud/cos-stable"
  project = local.project
}

resource "google_compute_address" "minecraft" {
  name   = "minecraft-ip"
  region = local.region
}

resource "google_compute_network" "minecraft" {
  name = "minecraft-network"
}

resource "google_compute_firewall" "minecraft" {
  name    = "minecraft-firewall"
  network = google_compute_network.minecraft.name

  # Minecraft "Bedrock Edition" client port
  allow {
    protocol = "udp"
    ports    = ["19132"]
  }

  # ICMP (ping)
  allow {
    protocol = "icmp"
  }

  # SSH (for RCON-CLI access)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft"]
}

resource "google_compute_instance" "minecraft" {
  name         = "minecraft-instance"
  machine_type = "n1-standard-1"
  zone         = local.zone
  tags         = ["minecraft"]

  metadata_startup_script = <<-EOF
    if blkid /dev/sdb;then
        :
    else
        mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
    fi

    mkdir -p /mnt/disks/minecraft_data
    mount -o discard,defaults /dev/sdb /mnt/disks/minecraft_data
    chmod a+w /mnt/disks/minecraft_data

    docker run -d --rm \
        -p 19132:19132/udp \
        -v /mnt/disks/minecraft_data:/data \
        -e EULA=TRUE \
        -e GAMEMODE=survival \
        -e DIFFICULTY=normal \
        --name mc \
        itzg/minecraft-bedrock-server:latest
  EOF

  metadata = {
    enable-oslogin = "TRUE" # https://cloud.google.com/compute/docs/instances/managing-instance-access#gcloud
  }

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.minecraft_image.self_link
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
      nat_ip = google_compute_address.minecraft.address
    }
  }

  service_account {
    email  = google_service_account.minecraft.email
    scopes = ["userinfo-email"]
  }

  scheduling {
    preemptible       = true # Closes within 24 hours (sometimes sooner)
    automatic_restart = false
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_attached_disk" "minecraft" {
  disk     = google_compute_disk.minecraft_data.id
  instance = google_compute_instance.minecraft.id
}
