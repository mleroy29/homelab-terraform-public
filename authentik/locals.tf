locals {
  # Schema definition for OIDC-compliant applications to provision via loops
  oidc_applications = {
    "forgejo" = {
      name          = "Forgejo Git Service"
      launch_url    = "https://git.example.com"
      redirect_uris = ["https://git.example.com/login/oauth/authorize"]
    }
    "bookstack" = {
      name          = "BookStack Documentation"
      launch_url    = "https://docs.example.com"
      redirect_uris = ["https://docs.example.com/oidc/callback"]
    }
  }
}