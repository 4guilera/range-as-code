variable "proxmox_url" {
  type    = string
  default = "https://10.0.20.11:8006/api2/json"
}

variable "proxmox_node" {
  type    = string
  default = "pve-node2"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "iac@pve!tofu"
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "iso_storage_pool" {
  type    = string
  default = "TrueNAS"
}

variable "windows_iso" {
  type    = string
  default = "26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "virtio_iso" {
  type    = string
  default = "virtio-win.iso"
}

variable "vm_id" {
  type    = number
  default = 9001
}

variable "vm_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "vm_disk_size" {
  type    = string
  default = "60G"
}

variable "vm_memory" {
  type    = number
  default = 4096
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "winrm_password" {
  type      = string
  default   = "LabAdmin2024!"
  sensitive = true
}
