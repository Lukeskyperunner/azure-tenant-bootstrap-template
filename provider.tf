terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }

  # Partial backend config — values are passed via `terraform init -backend-config=...`
  # at runtime. This keeps the file tenant-agnostic.
  # First local apply: omit the `-backend-config` flags entirely (uses local state).
  # After first apply: run `terraform init -migrate-state -backend-config=...` to push to Azure.
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
