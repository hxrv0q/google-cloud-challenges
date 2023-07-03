resource "google_compute_instance" "lamp_instance" {
  name = "lamp-1-vm"
  zone = "us-central1-a"
  machine_type = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  tags = ["http-server"]

  # Firewall rule
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2 php7.0
    ufw allow 80
    sudo service apache2 restart 
  SCRIPT
}

resource "google_compute_firewall" "http_firewall" {
  name = "http-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}