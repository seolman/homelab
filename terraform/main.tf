data "b2_account_info" "my_account_info" {}

resource "b2_bucket" "dr_bucket" {
  bucket_name = "homelab-prd-dr-bucket" # INFO need to change naming
  bucket_type = "allPrivate"

  # INFO need to change naming
  bucket_info = {
    "project" = "homelab"
    "environment" = "production"
    "managedby" = "terraform"
  }
  # cors_rules {}
  default_server_side_encryption {
    algorithm = "AES256"
    mode = "SSE-B2"
  }
  file_lock_configuration {
    is_file_lock_enabled = true
    default_retention {
      mode = "governance"
      period {
        duration = 90
        unit = "days"
      }
    }
  }
  lifecycle_rules {
    file_name_prefix = ""
    days_from_uploading_to_hiding = 30
    days_from_hiding_to_deleting  = 30
  }
}

resource "b2_application_key" "dr_key" {
  capabilities = [
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles",
    "deleteFiles"
  ]
  key_name = "homelab-prd-dr-key" # INFO need to change naming

  bucket_ids = [
    b2_bucket.dr_bucket.id
  ]
}

resource "oci_identity_compartment" "homelab_prd_compartment" {
  compartment_id = var.oci_tenancy_ocid
  name = "homelab-prd"
  description = "managed by terraform"
  freeform_tags = {
    "project" = "homelab"
    "environment" = "production"
    "managedby" = "terraform"
  }
}

resource "oci_core_vcn" "homelab_prd_vcn" {
  provider = oci.seoul
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  cidr_blocks = [ "192.168.0.0/16" ]
  display_name = "homelab-prd-vcn" # INFO
  dns_label = "homelab"
  freeform_tags = {
    "project" = "homelab"
    "environment" = "production"
    "managedby" = "terraform"
  }
}
