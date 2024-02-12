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
    ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    password = "${var.base_password}"
    tags = "Infra,IaC"
    start = true

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