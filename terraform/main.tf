
resource "proxmox_virtual_environment_vm" "dc01" {
  name      = "dc01"
  node_name = var.target_node
  vm_id     = 300

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
}

resource "proxmox_virtual_environment_vm" "ws01" {
  name      = "ws01"
  node_name = var.target_node
  vm_id     = 301

  clone {
    vm_id = 9001
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
}

resource "proxmox_virtual_environment_vm" "target01" {
  name      = "target01"
  node_name = var.target_node
  vm_id     = 302

  clone {
    vm_id = 9002
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.20.62/24"
        gateway = "10.0.20.1"
      }
    }
    dns {
      servers = ["10.0.20.1"]
    }
    user_account {
      username = "ubuntu"
      keys     = var.ssh_public_key != "" ? [var.ssh_public_key] : []
      password = "LabAdmin2024!"
    }
  }
}

resource "proxmox_virtual_environment_vm" "kali" {
  name      = "kali"
  node_name = var.target_node
  vm_id     = 303

  clone {
    vm_id = 9003
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.20.63/24"
        gateway = "10.0.20.1"
      }
    }
    dns {
      servers = ["10.0.20.1"]
    }
    user_account {
      username = "kali"
      keys     = var.ssh_public_key != "" ? [var.ssh_public_key] : []
      password = "LabAdmin2024!"
    }
  }
}
