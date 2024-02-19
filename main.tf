terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.10.10:8006/api2/json"
  pm_api_token_id     = var.proxmox_token
  pm_api_token_secret = var.proxmox_secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "nextcloud" {
  name        = "data"
  desc        = "nextcloud"
  target_node = "projectlemon"
  tags        = "iac;infra"
  agent       = 0
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  qemu_os     = "l26"

  clone                   = "VM 9000"
  cloudinit_cdrom_storage = "Cadbury"

  cores   = 4
  sockets = 1
  memory  = 6096
  balloon = 1024

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 60
          storage = "Cadbury"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr08"
  }

  lifecycle {
    ignore_changes = [ 
      target_node,
      vm_state,
      bootdisk,
      agent,
     ]
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=192.168.18.106/24,gw=192.168.18.1"

  sshkeys = var.ssh_keys

  ciuser     = "root"
  cipassword = var.base_password
}


resource "proxmox_vm_qemu" "ansible-controller" {
  name        = "ansible-controller"
  desc        = "Semaphore (ansible UI)"
  target_node = "projectlemon"
  tags        = "iac;infra"
  agent       = 0
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  qemu_os     = "l26"

  clone                   = "VM 9000"
  cloudinit_cdrom_storage = "Cadbury"

  cores   = 4
  sockets = 1
  memory  = 2096
  balloon = 512

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 8
          storage = "Cadbury"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr08"
  }

  lifecycle {
    ignore_changes = [ 
      target_node,
      vm_state,
      bootdisk,
      agent,
     ]
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  sshkeys = var.ssh_keys

  ciuser     = "root"
  cipassword = var.base_password
}
