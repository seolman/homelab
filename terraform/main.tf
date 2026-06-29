data "b2_account_info" "my_account_info" {}

resource "b2_bucket" "dr_bucket" {
  bucket_name = "homelab-prd-dr-bucket"
  bucket_type = "allPrivate"

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
  key_name = "homelab-prd-dr-key"

  bucket_ids = [
    b2_bucket.dr_bucket.id
  ]
}
