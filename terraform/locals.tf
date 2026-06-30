locals {
  oci_oracle_linux_10_aarch_source_id = "ocid1.image.oc1.ap-seoul-1.aaaaaaaamcz6gylksnmtpw6b6lyitjal56c4ricocqkizllyjuo73yuczlga"
  oci_instance_shape = "VM.Standard.A1.Flex"

  common_tags = {
    project = "homelab"
    environment = "production"
    managedby = "terraform"
  }
}
