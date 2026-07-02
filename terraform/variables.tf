variable "my_public_key" { type = string }
variable "seolman_password" { type = string }

variable "ve_endpoint" { type = string }
variable "ve_api_token" { type = string }

variable "b2_application_key" { type = string }
variable "b2_application_key_id" { type = string }

variable "oci_tenancy_ocid" { type = string }
variable "oci_user_ocid" { type = string }
variable "oci_fingerprint" { type = string }
variable "oci_private_key" { type = string }
variable "oci_region" { 
  type = string
  default = "ap-seoul-1"
}
