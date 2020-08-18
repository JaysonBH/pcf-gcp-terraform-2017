#CREATE THE STORAGE BUCKETS
resource "google_storage_bucket" "buildpacks-store" {
  name     = "${var.gcp_terraform_prefix}-buildpacks"
  location = "US"
}

resource "google_storage_bucket" "droplets-store" {
  name     = "${var.gcp_terraform_prefix}-droplets"
  location = "US"
}

resource "google_storage_bucket" "packages-store" {
  name     = "${var.gcp_terraform_prefix}-packages"
  location = "US"
}

resource "google_storage_bucket" "resources-store" {
  name     = "${var.gcp_terraform_prefix}-resources"
  location = "US"
}
