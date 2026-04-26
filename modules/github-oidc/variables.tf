variable "display_name" {
  type        = string
  description = "Display name of the App Registration"
}

variable "github_repository" {
  type        = string
  description = "GitHub repo in <owner>/<name> format"
}

variable "branch" {
  type        = string
  description = "Branch that gets the OIDC trust"
  default     = "main"
}

variable "resource_group_id" {
  type        = string
  description = "RG scope where the SP gets Owner"
}

variable "storage_account_id" {
  type        = string
  description = "Storage account scope where the SP gets Storage Blob Data Contributor"
}
