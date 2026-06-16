terraform {
  required_version = ">= 1.15.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2026.5.0"
    }
  }
  # Backend configuration omitted for showcase validation
}