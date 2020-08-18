#GCP: COMPUTE ENGINE - INSTANCE GROUPS
resource "google_compute_instance_group" "pcf-instance-group-lb-1a" {
  name        = "pcf-instance-group-lb-1a-${var.gcp_terraform_prefix}"
  description = "Terraformed - ${var.gcp_terraform_prefix} PCF Instance Group LB 1A"
  zone        = "${var.gcp_region}-d"

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }
}

#### LOAD BALANCER #0A -- SHARED TCP WEBSOCKETS / SSH LB RESOURCES

#CREATES THE REGIONAL EXTERNAL TCP WEBSOCKETS / SSH IP ADDRESS (STATIC)
resource "google_compute_address" "pcf-tcp-websockets-ssh-ip-address" {
  name   = "${var.gcp_terraform_prefix}-pcf-tcp-websockets-ssh-ip-address"
  region = "${var.gcp_region}"
}

#### LOAD BALANCER #0B -- SHARED HTTP / HTTPS LB RESOURCES

#CREATES THE EXTERNAL HTTP / HTTPS IP ADDRESS (STATIC)
resource "google_compute_global_address" "pcf-http-https-ip-address" {
  name = "${var.gcp_terraform_prefix}-pcf-fronend-ip-address"
}

#GCP: NETWORKING - LOAD BALANCING - TARGET PROXIES
resource "google_compute_url_map" "lb-http-https" {
  name        = "${var.gcp_terraform_prefix}-lb-pcf-router"
  description = "External app/system HTTP / HTTPS Load Balancer"

  default_service = "${google_compute_backend_service.pcf-gcp-http-https-backend.self_link}"
}

#BACKEND SERVICE FOR HTTP / HTTPS LOAD BALANCERS
resource "google_compute_backend_service" "pcf-gcp-http-https-backend" {
  name        = "pcf-gcp-backend-http-${var.gcp_terraform_prefix}"
  description = "External app/system HTTP / HTTPS Load Balancer's Backend Service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = "${google_compute_instance_group.pcf-instance-group-lb-1a.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.pcf-instance-group-lb-1b.self_link}"
  }
  
  backend {
    group = "${google_compute_instance_group.pcf-instance-group-lb-1c.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.health_check_http.self_link}"]
}

#### LOAD BALANCER #0C -- SHARED HTTP / HTTPS / WEBSOCKETS LB RESOURCES

#HEALTH CHECK FOR HTTP / HTTPS / WEBSOCKETS LOAD BALANCERS
resource "google_compute_http_health_check" "health_check_http" {
  name         = "health-check-http-${var.gcp_terraform_prefix}"
  description  = "External app/system HTTP Load Balancer's Health Check"
  request_path = "/health"
  port         = "8080"

  timeout_sec         = 5
  check_interval_sec  = 30
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

#### LOAD BALANCER #1 -- CREATE THE HTTP LOAD BALANCER ####

#TARGET PROXY FOR HTTP LOAD BALANCER
resource "google_compute_target_http_proxy" "pcf-router-http-target-proxy" {
  name        = "${var.gcp_terraform_prefix}-pcf-router-http-target-proxy"
  description = "External app/system HTTP Load Balancer's Proxy"
  url_map     = "${google_compute_url_map.lb-http-https.self_link}"
}

#GLOBAL FORWARDING RULE
resource "google_compute_global_forwarding_rule" "lb-pcf-router-frontend-http" {
  name        = "${var.gcp_terraform_prefix}-lb-pcf-router-frontend-http"
  description = "Routes HTTP Traffic"
  target      = "${google_compute_target_http_proxy.pcf-router-http-target-proxy.self_link}"
  port_range  = "80"
  ip_address  = "${google_compute_global_address.pcf-http-https-ip-address.address}"
}

#### LOAD BALANCER #2 -- CREATE THE HTTP(S) LOAD BALANCER ####

#TARGET PROXY FOR HTTPS LOAD BALANCER
resource "google_compute_target_https_proxy" "pcf-router-https-target-proxy" {
  name             = "${var.gcp_terraform_prefix}-pcf-router-https-target-proxy"
  description      = "External app/system HTTPS Load Balancer's Proxy"
  url_map          = "${google_compute_url_map.lb-http-https.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.lb-https-cert.self_link}"]
}

#CERTIFICATE FOR HTTPS LOAD BALANCER
resource "google_compute_ssl_certificate" "lb-https-cert" {
  name        = "pcf-router-https-certificate-${var.gcp_terraform_prefix}"
  description = "External app/system HTTPS Load Balancer's Certificate"
  private_key = "${file("keys/private.key")}"
  certificate = "${file("certs/certificate.crt")}"
}

#GLOBAL FORWARDING RULE
resource "google_compute_global_forwarding_rule" "lb-pcf-router-frontend-https" {
  name        = "${var.gcp_terraform_prefix}-lb-pcf-router-frontend-https"
  description = "Routes HTTPS Traffic"
  target      = "${google_compute_target_https_proxy.pcf-router-https-target-proxy.self_link}"
  port_range  = "443"
  ip_address  = "${google_compute_global_address.pcf-http-https-ip-address.address}"
}

#### LOAD BALANCER #3 -- CREATE THE TCP WEBSOCKETS LOAD BALANCER ####

#WEBSOCKETS FORWARDING RULE
resource "google_compute_forwarding_rule" "lb-tcp-websockets" {
  name       = "${var.gcp_terraform_prefix}-pcf-websockets-forwarding-rule"
  target     = "${google_compute_target_pool.tcp-websockets-targetpool.self_link}"
  port_range = "443"
  region     = "${var.gcp_region}"
  ip_address = "${google_compute_address.pcf-tcp-websockets-ssh-ip-address.address}"
}

#TARGET POOL
resource "google_compute_target_pool" "tcp-websockets-targetpool" {
  name = "${var.gcp_terraform_prefix}-pcf-websockets"

  health_checks = [
    "${google_compute_http_health_check.health_check_http.name}",
  ]
}

#### LOAD BALANCER #4 -- CREATE THE SSH PROXY LOAD BALANCER ####

#SSH PROXY FORWARDING RULE
resource "google_compute_forwarding_rule" "lb-tcp-ssh-proxy" {
  name       = "${var.gcp_terraform_prefix}-pcf-ssh-proxy-forwarding-rule"
  target     = "${google_compute_target_pool.tcp-ssh-proxy-targetpool.self_link}"
  port_range = "2222"
  region     = "${var.gcp_region}"
  ip_address = "${google_compute_address.pcf-tcp-websockets-ssh-ip-address.address}"
}

#TARGET POOL
resource "google_compute_target_pool" "tcp-ssh-proxy-targetpool" {
  name = "${var.gcp_terraform_prefix}-pcf-ssh-proxy"
}

resource "google_compute_instance_group" "pcf-instance-group-lb-1b" {
  name        = "pcf-instance-group-lb-1b-${var.gcp_terraform_prefix}"
  description = "Terraformed - ${var.gcp_terraform_prefix} PCF Instance Group LB 1B"
  zone        = "${var.gcp_region}-b"

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }
}

resource "google_compute_instance_group" "pcf-instance-group-lb-1c" {
  name        = "pcf-instance-group-lb-1c-${var.gcp_terraform_prefix}"
  description = "Terraformed - ${var.gcp_terraform_prefix} PCF Instance Group LB 1C"
  zone        = "${var.gcp_region}-c"

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }
}