#CREATES THE OPERATIONS MANAGER COMPUTE INSTANCE
resource "google_compute_instance" "opsman" {
  name           = "opsman-${var.gcp_terraform_prefix}"
  machine_type   = "n1-standard-1"
  zone           = "${var.gcp_region}-b"
  create_timeout = "10"

  tags = ["allow-http", "allow-https", "allow-ssh"]

  boot_disk {
    initialize_params {
      image = "${var.gcp_opsmanager}"
      size  = "150"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnetwk-infra.name}"
    address    = "10.0.0.5"

    access_config {
      nat_ip = "${google_compute_address.opsmanager-ip-address.address}"
    }
  }

  metadata {
    ubuntu = "future-ssh-variable"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  
}

#CREATES THE OPSMANAGER IP ADDRESS (STATIC)
resource "google_compute_address" "opsmanager-ip-address" {
  name   = "${var.gcp_terraform_prefix}-opsmanager-ip-address"
  region = "${var.gcp_region}"
}
