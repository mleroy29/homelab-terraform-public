terraform {
  required_version = ">= 1.15.0"
  required_providers {
    forgejo = {
      source  = "svalabs/forgejo"
      version = "~> 15.0.0"
    }
  }
}