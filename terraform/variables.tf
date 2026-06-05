variable "proxmox_url" {
  type    = string
  default = "https://10.0.20.11:8006"
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
  # Format: "user@realm!tokenid=tokensecret"
}

variable "target_node" {
  type    = string
  default = "pve-node2"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for Linux VM access"
  default     = ""
}
