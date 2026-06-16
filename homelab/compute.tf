resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each     = local.debian_vms
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve-01"

  source_raw {
    file_name = "user-data-${each.key}.yml"
    data = templatefile("${path.module}/templates/user-data-debian.yml.tftpl", {
      hostname               = each.key
      ssh_public_key_ansible = var.ssh_public_key_ansible
    })
  }
}

resource "proxmox_virtual_environment_vm" "debian_server" {
  for_each  = local.debian_vms
  name      = each.key
  vm_id     = each.value.id
  node_name = each.value.target_node
  tags      = each.value.tags
  on_boot   = each.value.on_boot
  started   = each.value.started

  clone {
    node_name = "pve-01"
    vm_id     = local.vm_template_catalog[each.value.os_type]
    full      = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  initialization {
    datastore_id      = "local-zfs"
    interface         = "scsi1"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = "10.0.10.1"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      node_name,
      initialization[0].user_data_file_id,
      clone
    ]
  }
}

resource "proxmox_haresource" "ha_vms" {
  for_each    = local.debian_vms
  depends_on  = [proxmox_virtual_environment_vm.debian_server]
  resource_id = "vm:${each.value.id}"
  state       = "started"
  failback    = false
}