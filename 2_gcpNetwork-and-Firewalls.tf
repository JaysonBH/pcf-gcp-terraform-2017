#SET UP YOUR NETWORK
resource "google_compute_network" "netwk" {
  name = "${var.gcp_terraform_prefix}"
}

#SETUP YOUR SUBNETWORK NAME
resource "google_compute_subnetwork" "subnetwk-infra" {
  name          = "${var.gcp_terraform_prefix}-infrastructure-subnet"
  ip_cidr_range = "10.0.0.0/26"
  network       = "${google_compute_network.netwk.self_link}"
  region        = "${var.gcp_region}"
}

#SETUP YOUR SUBNETWORK NAME
resource "google_compute_subnetwork" "subnetwk-ert" {
  name          = "${var.gcp_terraform_prefix}-ert-subnet"
  ip_cidr_range = "10.0.16.0/22"
  network       = "${google_compute_network.netwk.self_link}"
  region        = "${var.gcp_region}"
}

#SETUP YOUR SUBNETWORK NAME
resource "google_compute_subnetwork" "subnetwk-services" {
  name          = "${var.gcp_terraform_prefix}-services-subnet"
  ip_cidr_range = "10.0.20.0/22"
  network       = "${google_compute_network.netwk.self_link}"
  region        = "${var.gcp_region}"
}

#--------------------------------------------------------------

#SETUP YOUR FIREWAL RULES
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.gcp_terraform_prefix}-pcf-ssh"
  network = "${google_compute_network.netwk.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["pcf-vms-${var.gcp_terraform_prefix}","allow-ssh"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "${var.gcp_terraform_prefix}-allow-http"
  network = "${google_compute_network.netwk.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80","8080"]
  }

  target_tags = ["http-server","allow-http","router"]
}

resource "google_compute_firewall" "allow-https" {
  name    = "${var.gcp_terraform_prefix}-allow-https"
  network = "${google_compute_network.netwk.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags = ["https-server","allow-https","router"]
}

resource "google_compute_firewall" "allow-ert-all" {
  name          = "${var.gcp_terraform_prefix}-allow-ert-all"
  network       = "${google_compute_network.netwk.name}"


  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  target_tags = ["${var.gcp_terraform_prefix}","${var.gcp_terraform_prefix}-opsman","nat-traverse"]
}

resource "google_compute_firewall" "allow-cf-tcp" {
  name    = "${var.gcp_terraform_prefix}-allow-cf-tcp"
  network = "${google_compute_network.netwk.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${var.gcp_terraform_prefix}-cf-tcp"]
}

resource "google_compute_firewall" "allow-ssh-proxy" {
  name    = "${var.gcp_terraform_prefix}-allow-ssh-proxy"
  network = "${google_compute_network.netwk.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags = ["${var.gcp_terraform_prefix}-ssh-proxy","diego-brain"]
}

