terraform {
    required_version = ">= 1.0.0"
    required_providers {
        github = {
            source = "integrations/github"
            version = "~> 6.0"
        }
    }
}

provider "github" {
    token = var.github_token
    owner = var.github_owner
}

# Example: call the organization module
module "organization" {
  source = "./modules/organization"

  org_name = var.github_owner
  repo_name = var.repo_name
  repo_private = var.repo_private
}