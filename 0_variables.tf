///////////////////////////////////////////////
//////// Declare Vars /////////////////////////
///////////////////////////////////////////////

#SET THIS VARIABLE TO YOUR USERNAME TO DISTINGUISH YOUR LAB FROM OTHERS WITHIN THE SAME REGION
variable "gcp_terraform_prefix" {
  type    = "string"
  default = "terraformed" //CHANGE TO YOUR USERNAME
}

///////////////////////////////////////////////
#SELECT YOUR VERSION OF PCF OPERATIONS MANAGER VERSION (FROM A GCE IMAGE )
variable "gcp_opsmanager" {
  type    = "string"

  default = "INSERT OPSMAN IMAGE URL HERE"
}

///////////////////////////////////////////////


variable "gcp_proj_id" { type = "string" default = "YOUR-PROJECT-NAME-HERE" }
variable "gcp_region"  { type = "string" default = "us-east1" }

variable "serice_acct_key" { type    = "string"
  default = "GCP-Service-Account-bosh-1.json"
}