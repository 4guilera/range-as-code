terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.78.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = var.proxmox_api_token
  insecure  = true
}
