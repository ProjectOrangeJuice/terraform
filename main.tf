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

  clone                   = "${var.ubuntu_template}"
  cloudinit_cdrom_storage = "Cadbury"

  cores   = 4
  sockets = 1
  memory  = 8096
  balloon = 1024

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 250
          storage = "Cadbury"
          replicate = true
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
      clone,
     ]
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=192.168.18.106/24,gw=192.168.18.1"

  sshkeys = var.ssh_keys

  ciuser     = "root"
  cipassword = var.base_password
  
}



resource "proxmox_vm_qemu" "wazuh" {
  name        = "wazuh"
  desc        = "wazuh all in one"
  target_node = "projectlemon"
  tags        = "iac;infra"
  agent       = 0
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  qemu_os     = "l26"

  clone                   = "${var.ubuntu_template}"
  cloudinit_cdrom_storage = "Cadbury"

  cores   = 4
  sockets = 1
  memory  = 6096
  balloon = 1024

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 12
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
      clone,
     ]
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  sshkeys = var.ssh_keys

  ciuser     = "root"
  cipassword = var.base_password
  
}


resource "proxmox_lxc" "controller" {
    count = 1
    target_node = "projectlemon"
    description = "Ansible"
    hostname = "controller"
    ostemplate = "${var.ubuntu_container_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac,infra"
    start = false
    memory = 1024

    rootfs {
        storage = "Cadbury"
        size    = "8G"
    }    

    network {
        name = "eth0"
        bridge = "vmbr08"
        ip = "dhcp"
    }

    lifecycle {
    ignore_changes = [ 
      target_node,
      start,
      tags,
      ssh_public_keys,
      description,
     ]
  }

}


resource "proxmox_lxc" "nginx" {
    count = 2
    target_node = "projectlemon"
    description = count.index == 0 ? "Public nginx" : "Private nginx"
    hostname = "nginx-${count.index}"
    ostemplate = "${var.ubuntu_container_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac,infra"
    start = false
    memory = 1024

    rootfs {
        storage = "Cadbury"
        size    = "8G"
    }    

    network {
        name = "eth0"
        bridge = "vmbr08"
        ip = "dhcp"
    }

    lifecycle {
    ignore_changes = [ 
      target_node,
      start,
      tags,
      ssh_public_keys,
      description,
     ]
  }

}


resource "proxmox_lxc" "gateway" {
    count = 1
    target_node = "projectlemon"
    description = "Gateway for reverse proxy"
    hostname = "gateway"
    ostemplate = "${var.ubuntu_container_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac,infra"
    start = false
    memory = 1024

    rootfs {
        storage = "Cadbury"
        size    = "8G"
    }    

    network {
        name = "eth0"
        bridge = "vmbr08"
        ip = "dhcp"
    }

    lifecycle {
    ignore_changes = [ 
      target_node,
      start,
      tags,
      ssh_public_keys,
      description,
     ]
  }

}


resource "proxmox_lxc" "vault" {
    count = 1
    target_node = "projectlemon"
    description = "Bitwarden"
    hostname = "vault"
    ostemplate = "${var.ubuntu_container_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac,infra"
    start = false
    memory = 1024

    features {
        nesting = true
    }

    rootfs {
        storage = "Cadbury"
        size    = "8G"
    }    

    network {
        name = "eth0"
        bridge = "vmbr08"
        ip = "dhcp"
    }

    lifecycle {
    ignore_changes = [ 
      target_node,
      start,
      tags,
      ssh_public_keys,
      description,
     ]
  }

}