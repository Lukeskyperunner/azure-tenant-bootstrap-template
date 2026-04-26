variable "project_name" {
  type        = string
  description = "Short project identifier — used as a name fragment in derived resource names. Lowercase, alphanumeric, no separators."
}

variable "naming_suffix" {
  type        = string
  description = "Suffix appended to resource names to encode environment and region (e.g., 'dev-ch')."
  default     = "dev-ch"
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "switzerlandnorth"
}

variable "github_repository" {
  type        = string
  description = "GitHub repo in <owner>/<name> format. The bootstrap pipeline OIDC trust will be scoped to this repo's main branch."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource."
  default = {
    managed_by = "terraform"
  }
}
