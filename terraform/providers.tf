terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.ve_endpoint
  api_token = var.ve_api_token
  insecure = true
}
