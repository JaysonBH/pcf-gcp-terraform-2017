// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("keys/${var.serice_acct_key}")}"
  project     = "${var.gcp_proj_id}"
  region      = "${var.gcp_region}"
}
