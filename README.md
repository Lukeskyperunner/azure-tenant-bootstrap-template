# Azure Tenant Bootstrap Template

*[Deutsche Version](README.de.md)*

A reusable GitHub template repo for spinning up a new Azure tenant with Terraform-managed infrastructure and a GitHub Actions OIDC pipeline. Designed to take a fresh tenant from `az login` to a working CI/CD pipeline in ~15 minutes.

## What it provisions

- **Resource Group** for Terraform state (`rg-{project}-tfstate-{suffix}`)
- **Storage Account** + container for tfstate blobs
- **App Registration** + Service Principal + Federated Credential for GitHub Actions OIDC (no client secrets)
- **Role Assignments**: `Owner` on the tfstate RG, `Storage Blob Data Contributor` on the storage account

## How to use

1. Click **Use this template** on GitHub → create a new repo
2. `az login --tenant <new-tenant-id>`
3. Edit `tenant.tfvars` with your project name, region, GitHub repo path
4. Follow [CLAUDE.md](CLAUDE.md) — it has every command needed
5. After bootstrap, the new tenant has a working Terraform pipeline

## Variables

All tenant-specific values live in `tenant.tfvars` (gitignored):

```hcl
project_name      = "myproject"
naming_suffix     = "dev-ch"
location          = "switzerlandnorth"
github_repository = "myorg/azure-bootstrap-myproject"

tags = {
  managed_by  = "terraform"
  environment = "dev"
}
```

Naming is derived from these values via `locals.tf` — change one variable, all names stay consistent.

## Repo structure

```
main.tf              # Wires up the modules
locals.tf            # Derives resource names from variables
provider.tf          # azurerm + azuread, partial backend config
variables.tf         # Tenant inputs
outputs.tf           # Values needed for GitHub secrets
tenant.tfvars.example
modules/
├── state-foundation/   # RG + Storage + Container
└── github-oidc/        # App Reg + Federated Credential + Role Assignments
.github/workflows/      # plan / deploy / state — all use OIDC
CLAUDE.md            # Step-by-step bootstrap guide (also for AI)
```

## Why partial backend config

The `backend "azurerm" {}` in `provider.tf` is empty intentionally. Backend values are passed via `-backend-config=` flags at `terraform init` time. This keeps the file tenant-agnostic — the same code runs against any tenant.

## Adding more to the bootstrap

This template is **deliberately minimal** — it only sets up state + pipeline identity. Common additions:

- **Tenant users / groups** — add a `modules/tenant-users/` module
- **Platform baseline** — Azure Policies, budget alerts, default tagging
- **Cross-subscription role assignments** — for management-group setups

Add new modules under `modules/`, wire them into `main.tf`, and they'll be applied via the same pipeline.

## Conventions

- Provider: `azurerm ~> 3.0`, `azuread ~> 2.0`
- Authentication: ambient `az login` for first apply; OIDC for pipeline
- State key: `bootstrap.tfstate` in the same storage account it provisions (self-referential)
