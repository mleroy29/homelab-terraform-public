> [!WARNING]
> **Architectural Showcase Only**
> This repository is strictly an educational portfolio designed to demonstrate Infrastructure as Code (IaC) engineering principles, HCL factorisation logic, and split-workspace patterns. It is intentionally incomplete, heavily anonymized, and stripped of production assets. It is not functional and must not be used for live deployments.

# Homelab Infrastructure as Code - Showcase

## Architectural Overview

This repository demonstrates the management of a multi-node hypervisor infrastructure and cloud perimeter using Terraform split-workspace state management. 

The infrastructure is strictly decoupled into separate logical domains to isolate state blast radiuses and align with distinct resource lifecycles:

* **`gateway/`**: Perimeter layer. Manages public DNS zoning (OVH) and edge routing compute instances.
* **`homelab/`**: Core infrastructure layer. Provisions Proxmox hypervisor resources, virtual machines, and storage allocations.
* **`authentik/`**: Identity & Access Management layer. Automates Identity Provider (IdP) configurations, OAuth2/OIDC applications, and access policies.
* **`forgejo/`**: Platform layer. Manages organizations, repositories, and CI/CD runner profiles.

## Core Design Principles

1.  **State Isolation**: Each directory represents an independent Terraform workspace utilizing a self-hosted S3 remote backend.
2.  **Secret Sovereignty**: Plaintext secrets are strictly prohibited. Production secrets are encrypted via SOPS using Age, injected into the runtime environment at execution time.
3.  **Data-Driven Provisioning**: Resource duplication is avoided by driving deployments through complex HCL variables (`maps`, `objects`) and dynamic `for_each` loops.

## Continuous Integration

Every commit triggers a GitHub Actions pipeline validating:
* HCL Canonical code formatting (`terraform fmt`)
* Syntax correctness (`terraform validate`)
* Static code analysis and security linting (`tflint`)
