resource "authentik_provider_oauth2" "oidc" {
  for_each      = local.oidc_applications
  name          = "provider-${each.key}"
  client_id     = each.key
  client_secret = "dummy-secret-managed-via-sops" # Explicit placement for showcase structure

  allowed_redirect_uris = [
    for uri in each.value.redirect_uris : {
      matching_mode     = "strict"
      url               = uri
      redirect_uri_type = "authorization"
    }
  ]
}

resource "authentik_application" "apps" {
  for_each          = local.oidc_applications
  name              = each.value.name
  slug              = each.key
  protocol_provider = authentik_provider_oauth2.oidc[each.key].id
}