# CLAUDE.md

This file is the executable bootstrap guide. Follow it step by step when applying this template to a new Azure tenant. Each step has exact commands and a verification check before proceeding to the next.

## What this template does

Provisions the **minimum viable foundation** for managing an Azure tenant via Terraform + GitHub Actions:

- A `tfstate` resource group + storage account + container for remote state
- A GitHub OIDC App Registration with `Owner` on the tfstate RG and `Storage Blob Data Contributor` on the storage account
- GitHub Actions workflows (plan / deploy / state) that authenticate via OIDC

After bootstrap, the new tenant has a working IaC pipeline. Other repos can then use the same storage account for their own state.

## Variables (single source of truth)

All tenant-specific values live in `tenant.tfvars`. The user provides values for:

| Variable | Required | Example |
|---|---|---|
| `project_name` | yes | `cloudrige` (lowercase, alphanumeric, no separators) |
| `naming_suffix` | no (default `dev-ch`) | `dev-ch` or `prod-eu` |
| `location` | no (default `switzerlandnorth`) | `westeurope` |
| `github_repository` | yes | `myorg/azure-bootstrap-cloudrige` |
| `tags` | no | map of strings |

Derived names (built in `locals.tf`):
- RG: `rg-{project}-tfstate-{suffix}`
- Storage Account: `st{project}tf{suffix}` (lowercase, no hyphens, must be 3–24 chars)
- App Registration: `github-{project}-bootstrap-terraform`

## Prerequisites — verify before starting

```bash
az account show --query "{tenant: tenantId, sub: id}" -o tsv     # logged into the right tenant?
gh auth status                                                    # gh CLI authenticated?
terraform version                                                 # terraform installed?
```

If `az account show` shows the wrong tenant: `az login --tenant <new-tenant-id>` and select the right subscription with `az account set --subscription <sub-id>`.

## Bootstrap procedure

### Step 1 — Create the new GitHub repo from this template

```bash
gh repo create <owner>/<repo-name> --template <this-template-repo> --private --clone
cd <repo-name>
```

### Step 2 — Create `tenant.tfvars`

```bash
cp tenant.tfvars.example tenant.tfvars
```

Then edit `tenant.tfvars` with the values for this tenant. Keep `github_repository` consistent with the repo you just created. Storage account name length constraint: `st` + project + `tf` + suffix-without-hyphens must be ≤ 24 chars.

### Step 3 — First apply with LOCAL state

The backend is partial config — passing no `-backend-config` flags makes Terraform use a local state file.

```bash
terraform init
terraform apply -var-file=tenant.tfvars
```

**Verify**: outputs include `github_client_id`, `github_tenant_id`, `github_subscription_id`, `resource_group_name`, `storage_account_name`.

### Step 4 — Set GitHub secrets

```bash
REPO=$(jq -r '.["github_repository"].value' < <(terraform output -json) 2>/dev/null || grep -E '^github_repository' tenant.tfvars | sed 's/.*"\(.*\)"/\1/')

gh secret set AZURE_CLIENT_ID         --body "$(terraform output -raw github_client_id)"      --repo "$REPO"
gh secret set AZURE_TENANT_ID         --body "$(terraform output -raw github_tenant_id)"      --repo "$REPO"
gh secret set AZURE_SUBSCRIPTION_ID   --body "$(terraform output -raw github_subscription_id)" --repo "$REPO"
gh secret set BACKEND_RESOURCE_GROUP  --body "$(terraform output -raw resource_group_name)"   --repo "$REPO"
gh secret set BACKEND_STORAGE_ACCOUNT --body "$(terraform output -raw storage_account_name)"  --repo "$REPO"
```

### Step 5 — Migrate state to Azure Blob

```bash
terraform init -migrate-state -force-copy \
  -backend-config="resource_group_name=$(terraform output -raw resource_group_name)" \
  -backend-config="storage_account_name=$(terraform output -raw storage_account_name)" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=bootstrap.tfstate"
```

Then delete the local state file (it's now in Azure):

```bash
rm -f terraform.tfstate terraform.tfstate.backup
```

### Step 6 — Initial commit + push

```bash
git add .
git commit -m "feat: bootstrap tenant"
git push
```

The `Deploy` workflow will run automatically and re-apply (no-op since state is current). Verify it succeeded:

```bash
gh run list --workflow=Deploy --limit 1
```

### Step 7 — Tenant is ready

Other Terraform configurations in this tenant can now use the backend:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-{project}-tfstate-{suffix}"
  storage_account_name = "st{project}tf{suffix}"
  container_name       = "tfstate"
  key                  = "<environment>-<component>.tfstate"
}
```

## Idempotency / re-running

- Re-running `terraform apply` is safe; only drift gets corrected
- If you need to re-bootstrap a clean tenant: `terraform destroy -var-file=tenant.tfvars` then start over
- The local state file from Step 3 is gitignored — even if you forget to delete it, it won't leak into Git

## Common errors

| Error | Cause | Fix |
|---|---|---|
| `Storage account name "..." is invalid` | Name >24 chars or contains hyphens | Shorten `project_name` or `naming_suffix` |
| `Insufficient privileges to complete the operation` | User lacks Application Administrator or Owner on subscription | Get appropriate role in the new tenant first |
| `Backend reinitialization required` after Step 5 | Normal — the migrate-state created an Azure backend; just answer `yes` |
| Pipeline fails with `AADSTS70021` | Federated credential `subject` mismatch | Check `github_repository` variable matches the actual repo path |

## What this template does NOT do

- It does **not** create users, groups, or guests in the tenant
- It does **not** apply tenant-level Azure Policies
- It does **not** set up budget alerts or cost management
- It does **not** configure Conditional Access or Entra security defaults

Add separate modules under `modules/` if you want to extend.
