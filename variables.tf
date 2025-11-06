variable "github_token" {
  description = "Personal access token for GitHub authentication"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub Organization or user account name"
  type        = string
}

variable "repo_name" {
  description = "Name of the repo to create"
  type        = string
  default     = "terraform-github-infra"
}

variable "repo_private" {
  description = "Whether a repo should be private or not"
  type        = bool
  default     = true
}
