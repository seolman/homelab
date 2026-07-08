locals {
  # oci_rocky_linux_9_aarch_source_id = "ocid1.image.oc1..aaaaaaaas7a4zwwsdtry2nsf6rqrvhgasczcyb2wxsx6x3pewxorcwr3d4pq"
  oci_ubuntu_24_04_aarch_source_id = "ocid1.image.oc1.ap-seoul-1.aaaaaaaae5dqssutnmejddxsq54jjg325skera6l57vgsohths75dem3sp4a"
  oci_instance_shape = "VM.Standard.A1.Flex"

  common_tags = {
    project = "homelab"
    environment = "development"
    managedby = "terraform"
  }
  common_description = "managed by terraform"
}
