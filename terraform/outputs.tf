output "data_proxmox_virtual_environment_nodes" {
  value = {
    names     = data.proxmox_virtual_environment_nodes.my_nodes.names
    cpu_count = data.proxmox_virtual_environment_nodes.my_nodes.cpu_count
    online    = data.proxmox_virtual_environment_nodes.my_nodes.online
  }
}

