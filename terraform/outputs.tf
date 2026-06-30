output "data_proxmox_virtual_environment_nodes" {
  value = {
    names = data.proxmox_virtual_environment_nodes.my_nodes.names
  }
}

output "data_oci_availability_domains" {
  value = data.oci_identity_availability_domains.seoul_ads.availability_domains
}

output "oci_instance_public_ip" {
  value = oci_core_instance.homelab_prd_vm.public_ip
}

output "data_b2_account_info" {
  value = {
    s3_api_url = data.b2_account_info.my_account_info.s3_api_url
  }
}

output "b2_key_id" {
  value = b2_application_key.dr_key.application_key_id
}

output "b2_key_secret" {
  value = b2_application_key.dr_key.application_key
  sensitive = true
}
