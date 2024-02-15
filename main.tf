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
resource "proxmox_lxc" "rundeck" {
    target_node = "projectlemon"
    hostname = "rundeck"
    ostemplate = "${var.ubuntu_template}"
    password = "${var.base_password}"
    ssh_public_keys = "${var.ssh_keys}"
    tags = "iac;infra"
    start = true
    memory = 2024

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