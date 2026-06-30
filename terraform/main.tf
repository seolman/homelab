# proxmox
data "proxmox_virtual_environment_nodes" "my_nodes" {}

# TODO user
# TODO pbs
# TODO pms
# TODO rocky10 template

# oci
data "oci_identity_availability_domains" "seoul_ads" {
  provider = oci.seoul
  compartment_id = var.oci_tenancy_ocid
}

resource "oci_identity_compartment" "homelab_prd_compartment" {
  compartment_id = var.oci_tenancy_ocid
  name = "homelab-prd"
  description = "managed by terraform"

  freeform_tags = local.common_tags
}

resource "oci_core_vcn" "homelab_prd_vcn" {
  provider = oci.seoul
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  cidr_blocks = [ "192.168.0.0/16" ]

  display_name = "homelab-prd-vcn" # INFO
  dns_label = "homelab"
  freeform_tags = local.common_tags
}

# output "default_route" {
#   value = oci_core_vcn.homelab_prd_vcn.default_route_table_id
# }

resource "oci_core_internet_gateway" "homelab_prd_igw" {
  provider = oci.seoul
  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  vcn_id = oci_core_vcn.homelab_prd_vcn.id

  display_name = "homelab-prd-igw"
  enabled = true
  freeform_tags = local.common_tags
  route_table_id = oci_core_vcn.homelab_prd_vcn.default_route_table_id
}

resource "oci_core_subnet" "homelab_prd_pubsub" {
  provider = oci.seoul
  cidr_block = "192.168.5.0/24"
  vcn_id = oci_core_vcn.homelab_prd_vcn.id

  compartment_id = oci_identity_compartment.homelab_prd_compartment.id
  dhcp_options_id = oci_core_vcn.homelab_prd_vcn.default_dhcp_options_id
  display_name = "homelab-prd-pubsub"
  dns_label = "pubsub"
  security_list_ids = [oci_core_vcn.homelab_prd_vcn.default_security_list_id]
  route_table_id = oci_core_vcn.homelab_prd_vcn.default_route_table_id
  freeform_tags = local.common_tags
}

resource "oci_core_instance" "homelab_prd_vm" {
  provider = oci.seoul
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
    source_id = local.oci_oracle_linux_10_aarch_source_id
    boot_volume_size_in_gbs = 200
  }
  create_vnic_details {
    subnet_id = oci_core_subnet.homelab_prd_pubsub.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = var.my_public_key
    user_data = base64encode(<<EOF
    #cloud-config
    package_update = true
    packages:
      - neovim
      - git
      - fail2ban
    runcmd:
      - systemctl enable --now fail2ban
      - echo "complete" > /etc/motd
    EOF
  )
}
  freeform_tags = local.common_tags
}

# b2
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

