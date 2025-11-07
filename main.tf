terraform {
  required_version = ">= 1.0.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Provider for personal account
provider "github" {
  alias = "personal"
  token = var.github_token
  owner = var.personal_github_username
}

# Provider for organization
provider "github" {
  alias = "organization"
  token = var.github_token
  owner = var.organization_name
}

# Personal repository
resource "github_repository" "personal_repo" {
  provider = github.personal

  name        = var.personal_repo_name
  description = var.personal_repo_description
  visibility  = "private"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  delete_branch_on_merge = true
  auto_init              = true
  gitignore_template     = "Terraform"
  license_template       = "mit"
}

# Organization repository
resource "github_repository" "organization_repo" {
  provider = github.organization

  name        = var.organization_repo_name
  description = var.organization_repo_description
  visibility  = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  delete_branch_on_merge = true
  auto_init              = true
  gitignore_template     = "Terraform"
  license_template       = "mit"
}

# GitHub workflow file for personal repository
resource "github_repository_file" "personal_workflow" {
  provider   = github.personal
  depends_on = [github_repository.personal_repo]

  repository = github_repository.personal_repo.name
  branch     = "main"
  file       = ".github/workflows/sync-to-org.yml"
  content = templatefile("${path.module}/.github/workflows/sync-to-org.yml.tpl", {
    personal_username = var.personal_github_username
    personal_email    = var.personal_github_email
    organization_name = var.organization_name
    organization_repo = var.organization_repo_name
  })
  commit_message      = "Add GitHub workflow for syncing to organization repo"
  commit_author       = var.personal_github_username
  commit_email        = var.personal_github_email
  overwrite_on_create = true
}

# GitHub Actions secret for personal repository
resource "github_actions_secret" "sync_token" {
  provider = github.personal
  depends_on = [github_repository.personal_repo]

  repository       = github_repository.personal_repo.name
  secret_name      = "SYNC_TOKEN"
  plaintext_value  = var.github_token
}
