#CREATES THE NATs COMPUTE INSTANCE
resource "google_compute_instance" "nat-gateway-pri" {
  name           = "${var.gcp_terraform_prefix}-nat-gateway-pri"
  machine_type   = "n1-standard-4"
  zone           = "${var.gcp_region}-b"
  create_timeout = "10"
  can_ip_forward = true

  tags = ["nat-traverse", "${var.gcp_terraform_prefix}-nat-instance","allow-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-lts"
      size  = "10"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnetwk-infra.name}"
    address    = "10.0.0.2"

    access_config {
      #Ephemeral
    }
  }

  service_account {
    scopes = ["userinfo-email"]
  }

  metadata_startup_script = "#! /bin/bash \n sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward' \n sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

}

resource "google_compute_instance" "nat-gateway-sec" {
  name           = "${var.gcp_terraform_prefix}-nat-gateway-sec"
  machine_type   = "n1-standard-4"
  zone           = "${var.gcp_region}-c"
  create_timeout = "10"
  can_ip_forward = true

  tags = ["nat-traverse", "${var.gcp_terraform_prefix}-nat-instance","allow-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-lts"
      size  = "10"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnetwk-infra.name}"
    address    = "10.0.0.3"

    access_config {
      #Ephemeral
    }
  }

  service_account {
    scopes = ["userinfo-email"]
  }

  metadata_startup_script = "#! /bin/bash \n sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward' \n sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

}

resource "google_compute_instance" "nat-gateway-ter" {
  name           = "${var.gcp_terraform_prefix}-nat-gateway-ter"
  machine_type   = "n1-standard-4"
  zone           = "${var.gcp_region}-d"
  create_timeout = "10"
  can_ip_forward = true

  tags = ["nat-traverse", "${var.gcp_terraform_prefix}-nat-instance","allow-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-lts"
      size  = "10"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnetwk-infra.name}"
    address    = "10.0.0.4"

    access_config {
      #Ephemeral
    }
  }

  service_account {
    scopes = ["userinfo-email"]
  }

  metadata_startup_script = "#! /bin/bash \n sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward' \n sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

}

#CREATE ROUTES FOR NAT INSTANCES
resource "google_compute_route" "route-pri" {
  name        = "${var.gcp_terraform_prefix}-nat-pri"
  dest_range  = "0.0.0.0/0"
  network     = "${google_compute_network.netwk.self_link}"
  next_hop_instance = "${google_compute_instance.nat-gateway-pri.name}"
  next_hop_instance_zone = "${google_compute_instance.nat-gateway-pri.zone}"
  priority    = 800
  tags        = ["${var.gcp_terraform_prefix}"]
}

resource "google_compute_route" "route-sec" {
  name        = "${var.gcp_terraform_prefix}-nat-sec"
  dest_range  = "0.0.0.0/0"
  network     = "${google_compute_network.netwk.self_link}"
  next_hop_instance = "${google_compute_instance.nat-gateway-sec.name}"
  next_hop_instance_zone = "${google_compute_instance.nat-gateway-sec.zone}"
  priority    = 800
  tags        = ["${var.gcp_terraform_prefix}"]
}

resource "google_compute_route" "route-ter" {
  name        = "${var.gcp_terraform_prefix}-nat-ter"
  dest_range  = "0.0.0.0/0"
  network     = "${google_compute_network.netwk.self_link}"
  next_hop_instance = "${google_compute_instance.nat-gateway-ter.name}"
  next_hop_instance_zone = "${google_compute_instance.nat-gateway-ter.zone}"
  priority    = 800
  tags        = ["${var.gcp_terraform_prefix}"]
}
