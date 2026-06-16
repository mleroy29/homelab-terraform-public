variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" { type = string; sensitive = true }
variable "ssh_public_key_ansible" { type = string }
variable "ssh_private_key_path_terraform" { type = string }