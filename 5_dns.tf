#CREATE THE OPSMANAGER DOMAIN NAME ATTACHED TO THE OPS MANAGER'S IP ADDRESS
resource "google_dns_record_set" "opsman-dns" {
  name = "opsman.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_address.opsmanager-ip-address.address}"]
}

#SET *.system.YOURDOMAIN TO THE pcf-router LB
resource "google_dns_record_set" "system-dns" {
  name = "*.system.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_global_forwarding_rule.lb-pcf-router-frontend-http.ip_address}"]
}

#SET *.apps.YOURDOMAIN TO THE pcf-router LB
resource "google_dns_record_set" "apps-dns" {
  name = "*.apps.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_global_forwarding_rule.lb-pcf-router-frontend-http.ip_address}"]
}

#SET THE doppler.YOURSYSTEMDOMAIN TO THE pcf-websockets LB
resource "google_dns_record_set" "doppler-dns" {
  name = "doppler.system.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_forwarding_rule.lb-tcp-ssh-proxy.ip_address}"]
}

#SET THE loggregator.YOURSYSTEMDOMAIN TO THE pcf-websockets LB
resource "google_dns_record_set" "loggregator-dns" {
  name = "loggregator.system.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_forwarding_rule.lb-tcp-ssh-proxy.ip_address}"]
}

#SET THE ssh.YOURSYSTEMDOMAIN	TO THE pcf-ssh LB
resource "google_dns_record_set" "ssh-dns" {
  name = "ssh.system.${var.gcp_terraform_prefix}.us-east.gcp.gss-labs.pivotal.io."
  type = "A"
  ttl  = 300

  managed_zone = "us-east-team"

  rrdatas = ["${google_compute_forwarding_rule.lb-tcp-ssh-proxy.ip_address}"]
}
