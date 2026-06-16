---
title: "Procedure: Add SSO Protection to a Service"
status: "production"
updated: "2026-05-26"
dependencies: ["docs/expl-terraform-architecture.md", "authentik/locals.tf"]

---

# Procedure: Add SSO Protection to a Service

Context: This procedure details how to integrate an internal application into the Authentik Single Sign-On (SSO) perimeter. Applications are categorized into two paradigms: OIDC (Native SSO) and Proxy (Traefik ForwardAuth interception).

## Prerequisites

* The application must be defined in the Ansible Traefik external services list (`inventory/group_vars/app_traefik/traefik.yml`).
* You must determine if the application natively supports OpenID Connect / OAuth2.

## Scenario A: Application Supports OIDC (Preferred)

Use this method for applications like BookStack, Forgejo, or Grafana.

1. Ensure the target application is configured to trust Traefik's proxy headers to prevent internal HTTPS-to-HTTP redirect loops.
2. Edit `authentik/locals.tf` and append the application to the `oidc_applications` map:

```terraform
  oidc_applications = {
    "app-slug" = {
      name          = "App Name"
      url           = "https://app.example.com"
      redirect_uris = ["https://app.example.com/oidc/callback"]
    }
  }
```

3. Generate a 128-character client secret and add it to `secrets.sops.yml` under the `TF_VAR_oidc_client_secrets` JSON string.

```bash
openssl rand -base64 96 | tr -dc 'a-zA-Z0-9' | head -c 128; echo
```

```yaml
TF_VAR_oidc_client_secrets: |
    {
      "bookstack": "v............................z",
      "forgejo": "E............................f",
      "openwebui": "s............................6"
    }
```

1. Run `tf apply` in the `authentik/` directory.
2. **Mandatory Version Drift Fix:** Log into the Authentik GUI, edit the newly created `oidc-<app-slug>` provider, and manually check **Authorization Code** and **Refresh token** under Grant Types.

## Scenario B: Application Requires Proxy Interception

Use this method for applications like Uptime Kuma or AdGuard that lack native SSO support.

1. Edit `inventory/group_vars/app_traefik/traefik.yml` and inject the `authentik` middleware:

```yaml
  - name: "app-slug"
    url: "app.example.com"
    backend_url: "[http://10.0.0.50:8080](http://10.0.0.50:8080)"
    middlewares:
      - "authentik"
```

1. Run the Ansible Traefik playbook to generate the Outpost interception router.
2. Edit `authentik/locals.tf` and append the application to the `proxy_applications` map:

```terraform
  proxy_applications = {
    "app-slug" = {
      name       = "App Name"
      url        = "[https://app.example.com](https://app.example.com)"
      skip_paths = "^/api/.*"
    }
  }
```

1. Run `tf apply` in the `authentik/` directory.

## Verification

**For OIDC Applications:**

1. Navigate to the application's URL.
2. Click the "Login with Authentik/SSO" button.
3. Verify successful redirection and authentication.

**For Proxy Applications:**

1. Open an incognito browser window.
2. Navigate to the application's URL.
3. Verify that Traefik intercepts the request and redirects to the Authentik login portal.

## Sources

- Traefik Proxy Integration: https://docs.goauthentik.io/add-secure-apps/providers/proxy/server_traefik/
