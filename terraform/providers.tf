terraform {
  required_version = ">= 1.0.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }
    b2 = {
      source = "Backblaze/b2"
      version = "0.12.1"
    }
    oci = {
      source = "oracle/oci"
      version = "8.20.0"
    }
  }
}

# provider "proxmox" {
#   endpoint = var.ve_endpoint
#   api_token = var.ve_api_token
#   insecure = true
# }

provider "b2" {
  application_key = var.b2_application_key
  application_key_id = var.b2_application_key_id
}

provider "oci" {
  alias = "seoul"
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid = var.oci_user_ocid
  fingerprint = var.oci_fingerprint
  private_key = var.oci_private_key
  region = var.oci_region
}
