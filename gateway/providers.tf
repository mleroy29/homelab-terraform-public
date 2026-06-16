terraform {
  required_version = ">= 1.15.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.48.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
    }
  }
}