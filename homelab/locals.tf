locals {
  # --- Cluster Infrastructure Catalog ---
  proxmox_nodes_catalog = {
    "pve-01" = { ip = "10.0.10.11" }
    "pve-02" = { ip = "10.0.10.12" }
  }

  vm_template_catalog = {
    debian13 = 9001
  }

  # --- Base Inheritance Profiles ---
  profile_global_defaults = {
    on_boot       = true
    started       = true
    ha_enabled    = true
    startup_order = 10
    tags          = ["managed-by-terraform"]
  }

  profile_debian_default = merge(local.profile_global_defaults, {
    os_type   = "debian13"
    cores     = 2
    memory    = 2048
    disk_size = 20
    tags      = tolist(setunion(local.profile_global_defaults.tags, ["os-linux", "dist-debian"]))
  })

  # --- Raw Declarative Inventory ---
  raw_debian_vms = {
    "srv-infra-dns" = {
      id   = 200
      ip   = "10.0.10.200/24"
      tags = ["role-dns"]
    }
    "srv-apps-generic" = {
      id        = 201
      ip        = "10.0.10.201/24"
      memory    = 8192
      disk_size = 40
      tags      = ["role-apps"]
    }
  }

  # --- Evaluation Loop & Dynamic HA Node Placement ---
  debian_vms = {
    for k, v in local.raw_debian_vms : k => merge(
      local.profile_debian_default,
      v,
      {
        # Alternates target node allocation based on VM ID parity
        target_node = try(v.target_node, v.id % 2 == 0 ? "pve-01" : "pve-02")
        tags        = tolist(setunion(local.profile_debian_default.tags, try(v.tags, [])))
      }
    )
  }
}