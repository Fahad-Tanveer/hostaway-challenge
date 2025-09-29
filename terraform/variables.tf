# GitHub Configuration Variables

variable "github_username" {
  description = "GitHub username for repository access"
  type        = string
  sensitive   = false
}

variable "github_pat" {
  description = "GitHub Personal Access Token for authentication"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub organization (optional, defaults to username if not provided)"
  type        = string
  default     = ""
}

variable "repository_name" {
  description = "GitHub repository name (used for both application and GitOps)"
  type        = string
  default     = "hostaway-demo"
}

variable "app_source_path" {
  description = "Path within the repository where application source code is located"
  type        = string
  default     = "apps/hello"
}

variable "gitops_path" {
  description = "Path within the repository where GitOps configuration is located"
  type        = string
  default     = "gitops"
}

# Computed locals for GitHub URLs
locals {
  github_org_or_user = var.github_org != "" ? var.github_org : var.github_username
  repository_url     = "https://github.com/${local.github_org_or_user}/${var.repository_name}"
  github_base_url    = "https://github.com/${local.github_org_or_user}"
}
