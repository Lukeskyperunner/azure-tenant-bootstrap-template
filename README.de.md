# Azure Tenant Bootstrap Template

Wiederverwendbares GitHub-Template-Repo zum Aufsetzen eines neuen Azure-Tenants mit Terraform-verwalteter Infrastruktur und GitHub-Actions-OIDC-Pipeline. Bringt einen frischen Tenant in ~15 Minuten von `az login` zu einer laufenden CI/CD-Pipeline.

## Was es bereitstellt

- **Resource Group** für Terraform-State (`rg-{project}-tfstate-{suffix}`)
- **Storage Account** + Container für tfstate-Blobs
- **App Registration** + Service Principal + Federated Credential für GitHub Actions OIDC (keine Client Secrets)
- **Role Assignments**: `Owner` auf der tfstate-RG, `Storage Blob Data Contributor` auf dem Storage Account

## Verwendung

1. Auf GitHub **Use this template** klicken → neues Repo erstellen
2. `az login --tenant <neue-tenant-id>`
3. `tenant.tfvars` bearbeiten mit Projektname, Region, GitHub-Repo-Pfad
4. [CLAUDE.md](CLAUDE.md) folgen — enthält jeden nötigen Befehl
5. Nach dem Bootstrap hat der neue Tenant eine laufende Terraform-Pipeline

## Variablen

Alle tenant-spezifischen Werte leben in `tenant.tfvars` (gitignored):

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

Das Naming wird aus diesen Werten über `locals.tf` abgeleitet — eine Variable ändern, alle Namen bleiben konsistent.

## Repo-Struktur

```
main.tf              # Verdrahtet die Module
locals.tf            # Leitet Ressourcennamen aus Variablen ab
provider.tf          # azurerm + azuread, partielle Backend-Konfig
variables.tf         # Tenant-Inputs
outputs.tf           # Werte für GitHub Secrets
tenant.tfvars.example
modules/
├── state-foundation/   # RG + Storage + Container
└── github-oidc/        # App Reg + Federated Credential + Role Assignments
.github/workflows/      # plan / deploy / state — alle via OIDC
CLAUDE.md            # Schritt-für-Schritt-Bootstrap-Anleitung (auch für KI)
```

## Warum partielle Backend-Konfig

Der `backend "azurerm" {}` in `provider.tf` ist absichtlich leer. Backend-Werte werden zur `terraform init`-Zeit per `-backend-config=`-Flags übergeben. So bleibt der Code tenant-agnostisch — derselbe Code läuft gegen jeden Tenant.

## Erweiterung des Bootstraps

Das Template ist **bewusst minimal** — es richtet nur State + Pipeline-Identity ein. Übliche Erweiterungen:

- **Tenant Users / Groups** — `modules/tenant-users/`-Modul hinzufügen
- **Platform-Baseline** — Azure Policies, Budget-Alerts, Default-Tagging
- **Subscription-übergreifende Role Assignments** — für Management-Group-Setups

Neue Module unter `modules/` anlegen, in `main.tf` verdrahten — werden über dieselbe Pipeline ausgerollt.

## Konventionen

- Provider: `azurerm ~> 3.0`, `azuread ~> 2.0`
- Authentifizierung: `az login` für ersten Apply; OIDC für Pipeline
- State-Key: `bootstrap.tfstate` im selbst angelegten Storage Account (selbstreferenziell)
