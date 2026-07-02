locals {
  oci_rocky_linux_9_aarch_source_id = "ocid1.image.oc1..aaaaaaaas7a4zwwsdtry2nsf6rqrvhgasczcyb2wxsx6x3pewxorcwr3d4pq"
  oci_instance_shape = "VM.Standard.A1.Flex"

  common_tags = {
    project = "homelab"
    environment = "production"
    managedby = "terraform"
  }
  common_description = "managed by terraform"
}
