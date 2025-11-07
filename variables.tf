variable "github_token" {
  description = "Personal access token for GitHub authentication"
  type        = string
  sensitive   = true
}

variable "personal_github_username" {
  description = "Your personal GitHub username"
  type        = string
}

variable "personal_github_email" {
  description = "Your personal GitHub email address"
  type        = string
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
}

variable "personal_repo_name" {
  description = "Name of the repository to create in your personal account"
  type        = string
  default     = "my-personal-repo"
}

variable "personal_repo_description" {
  description = "Description for the personal repository"
  type        = string
  default     = "Personal repository created with Terraform"
}

variable "organization_repo_name" {
  description = "Name of the repository to create in the organization"
  type        = string
  default     = "my-org-repo"
}

variable "organization_repo_description" {
  description = "Description for the organization repository"
  type        = string
  default     = "Organization repository created with Terraform"
}
