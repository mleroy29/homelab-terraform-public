terraform {
  required_version = "~> 1.15.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.109"
    }
  }
  backend "s3" {
    bucket         = "terraform-state"
    key            = "homelab/terraform.tfstate"
    region         = "main"
    endpoints      = { s3 = "https://s3.example.com" }
    use_path_style = true
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true

  ssh {
    agent       = false
    username    = "root"
    private_key = file(var.ssh_private_key_path_terraform)

    # Dynamic target node configuration mapping from cluster catalog
    dynamic "node" {
      for_each = local.proxmox_nodes_catalog
      content {
        name    = node.key
        address = node.value.ip
      }
    }
  }
}