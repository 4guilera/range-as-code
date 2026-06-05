packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "windows-11-enterprise" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = "win11-enterprise-template"
  template_description = "Windows 11 Enterprise (25H2)"

  os       = "win11"
  memory   = var.vm_memory
  cores    = var.vm_cores
  sockets  = 1
  cpu_type = "host"
  bios     = "seabios"
  machine  = "pc"

  qemu_agent      = true
  scsi_controller = "virtio-scsi-single"

  disks {
    type         = "scsi"
    disk_size    = var.vm_disk_size
    storage_pool = var.vm_storage_pool
    format       = "raw"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  iso_file = "${var.iso_storage_pool}:iso/${var.windows_iso}"

  additional_iso_files {
    device   = "sata0"
    iso_file = "${var.iso_storage_pool}:iso/${var.virtio_iso}"
    unmount  = true
  }

  additional_iso_files {
    device           = "sata1"
    cd_files         = ["./Autounattend.xml"]
    cd_label         = "OEMDRV"
    iso_storage_pool = var.iso_storage_pool
  }

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.winrm_password
  winrm_host     = "10.0.20.91"
  winrm_timeout  = "45m"
  winrm_use_ssl  = false

  boot_wait    = "5s"
  boot_command = ["<spacebar>"]
}

build {
  sources = ["source.proxmox-iso.windows-11-enterprise"]

  provisioner "powershell" {
    inline = [
      "$virtioVols = Get-Volume | Where-Object { $_.DriveType -eq 'CD-ROM' }",
      "foreach ($vol in $virtioVols) {",
      "  $msi = \"$($vol.DriveLetter):\\guest-agent\\qemu-ga-x86_64.msi\"",
      "  if (Test-Path $msi) { Start-Process msiexec.exe -ArgumentList \"/i $msi /qn\" -Wait; break }",
      "}"
    ]
  }

  provisioner "powershell" {
    inline = [
      "$virtioVols = Get-Volume | Where-Object { $_.DriveType -eq 'CD-ROM' }",
      "foreach ($vol in $virtioVols) {",
      "  $msi = \"$($vol.DriveLetter):\\virtio-win-gt-x64.msi\"",
      "  if (Test-Path $msi) { Start-Process msiexec.exe -ArgumentList \"/i $msi /qn\" -Wait; break }",
      "}"
    ]
  }

  provisioner "powershell" {
    inline = [
      "Remove-Item -Path $env:TEMP\\* -Recurse -Force -ErrorAction SilentlyContinue",
      "& C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /quiet",
      "Start-Sleep -Seconds 60"
    ]
  }
}
