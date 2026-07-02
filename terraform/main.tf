# INFO proxmox
data "proxmox_virtual_environment_nodes" "my_nodes" {}

resource "proxmox_node_config" "pve3_note" {
  node_name = "pve3"

  description = trimspace(<<-EOT
  # Backup Node
  EOT
  )
}

resource "proxmox_virtual_environment_group" "admin_group" {
  group_id = "admin"

  comment = "managed by terraform"
}

resource "proxmox_acl" "admin_acl" {
  path = "/"
  role_id = "Administrator"

  group_id = proxmox_virtual_environment_group.admin_group.id
  propagate = true
}

resource "proxmox_virtual_environment_user" "seolman_user" {
  user_id  = "seolman@pve"

  comment = "managed by terraform"
  email = "tjfehdgns@gmail.com"
  enabled = true
  groups = [proxmox_virtual_environment_group.admin_group.group_id]
  password = var.seolman_password
}

resource "proxmox_download_file" "rocky_linux_10_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10-latest-x86_64-minimal.iso"

  file_name = "rocky_linux_10.iso"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_9_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-minimal.iso"

  file_name = "rocky_linux_9.iso"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_8_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8-latest-x86_64-minimal.iso"

  file_name = "rocky_linux_8.iso"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_10_oci_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Base.latest.x86_64.tar.xz"

  file_name = "rocky_linux_10.tar.xz"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_9_oci_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz"

  file_name = "rocky_linux_9.tar.xz"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_8_oci_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz"

  file_name = "rocky_linux_8.tar.xz"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_10_qcow2_img" {
  content_type = "import"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2"

  file_name = "rocky_linux_10.qcow2"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_9_qcow2_img" {
  content_type = "import"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"

  file_name = "rocky_linux_9.qcow2"
  overwrite = true
}

resource "proxmox_download_file" "rocky_linux_8_qcow2_img" {
  content_type = "import"
  datastore_id = "local"
  node_name = "pve3"
  url = "https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"

  file_name = "rocky_linux_8.qcow2"
  overwrite = true
}

# TODO
# resource "proxmox_virtual_environment_vm" "test_vm" {
#   node_name = "pve3"
#
#   agent {
#     enabled = true
#   }
# }

# TODO pbs
# TODO pms

# INFO oci
data "oci_identity_availability_domains" "seoul_ads" {
  compartment_id = var.oci_tenancy_ocid
}

resource "oci_identity_compartment" "homelab_prd_compartment" {
  provider = oci.osaka
  compartment_id = var.oci_tenancy_ocid
  name = "homelab-prd"
  description = "managed by terraform"

  freeform_tags = local.common_tags
}

resource "oci_core_vcn" "homelab_prd_vcn" {
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  cidr_blocks = [ "192.168.0.0/16" ]

  display_name = "homelab-prd-vcn"
  dns_label = "homelab"
  freeform_tags = local.common_tags
}

resource "oci_core_internet_gateway" "homelab_prd_igw" {
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  vcn_id = oci_core_vcn.homelab_prd_vcn.id

  display_name = "homelab-prd-igw"
  enabled = true
  freeform_tags = local.common_tags
}

resource "oci_core_route_table" "homelab_prd_rt" {
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  vcn_id = oci_core_vcn.homelab_prd_vcn.id

  display_name = "homelab-prd-rt"
  freeform_tags = local.common_tags
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.homelab_prd_igw.id
  }
}

resource "oci_core_subnet" "homelab_prd_pubsub" {
  cidr_block = "192.168.5.0/24"
  vcn_id = oci_core_vcn.homelab_prd_vcn.id

  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  dhcp_options_id = oci_core_vcn.homelab_prd_vcn.default_dhcp_options_id
  display_name = "homelab-prd-pubsub"
  dns_label = "pubsub"
  security_list_ids = [oci_core_vcn.homelab_prd_vcn.default_security_list_id]
  route_table_id = oci_core_route_table.homelab_prd_rt.id
  freeform_tags = local.common_tags
}

resource "oci_core_instance" "homelab_prd_vm" {
  availability_domain = data.oci_identity_availability_domains.seoul_ads.availability_domains[0].name
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id

  display_name = "homelab-prd-vm"
  shape = local.oci_instance_shape
  shape_config {
    ocpus = 4
    memory_in_gbs = 24
  }
  source_details {
    source_type = "image"
    source_id = local.oci_rocky_linux_9_aarch_source_id
    boot_volume_size_in_gbs = 200
  }
  create_vnic_details {
    subnet_id = oci_core_subnet.homelab_prd_pubsub.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = var.my_public_key
  }
  freeform_tags = local.common_tags
}

# INFO b2
data "b2_account_info" "my_account_info" {}

resource "b2_bucket" "dr_bucket" {
  bucket_name = "homelab-prd-dr-bucket" # INFO need to change naming
  bucket_type = "allPrivate"

  # INFO need to change naming
  bucket_info = local.common_tags
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

