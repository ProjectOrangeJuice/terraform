terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.10.10:8006/api2/json"
  pm_api_token_id = "${var.proxmox_token}"
  pm_api_token_secret = "${var.proxmox_secret}"
  pm_tls_insecure = true
}

# Setup LXC
resource "proxmox_lxc" "nextcloud" {
    target_node = "projectlemon" 
    hostname = "data"
    ostemplate = "${var.ubuntu_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac,infra"
    start = true
    memory = 4096
    privileged = true

    rootfs {
        storage = "Cadbury"
        size    = "50G"
    }    

    network {
        name = "eth0"
        bridge = "vmbr08"
        ip = "192.168.18.100/24"
        gateway = "192.168.18.1"
    }
}

resource "proxmox_lxc" "rundeck-test" {
  count = 0
    target_node = "projectlemon"
    hostname = "test-rundeck-${count.index}"
    ostemplate = "${var.ubuntu_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac"
    start = true
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
}