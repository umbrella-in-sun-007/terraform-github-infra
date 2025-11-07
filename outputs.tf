output "personal_repository_url" {
  description = "Personal GitHub repository URL"
  value       = github_repository.personal_repo.html_url
}

output "personal_repository_git_clone_url" {
  description = "Personal GitHub repository git clone URL"
  value       = github_repository.personal_repo.git_clone_url
}

output "personal_repository_ssh_url" {
  description = "Personal GitHub repository SSH URL"
  value       = github_repository.personal_repo.ssh_clone_url
}

output "organization_repository_url" {
  description = "Organization GitHub repository URL"
  value       = github_repository.organization_repo.html_url
}

output "organization_repository_git_clone_url" {
  description = "Organization GitHub repository git clone URL"
  value       = github_repository.organization_repo.git_clone_url
}

output "organization_repository_ssh_url" {
  description = "Organization GitHub repository SSH URL"
  value       = github_repository.organization_repo.ssh_clone_url
}

output "personal_repository_name" {
  description = "Personal repository name"
  value       = github_repository.personal_repo.name
}

output "organization_repository_name" {
  description = "Organization repository name"
  value       = github_repository.organization_repo.name
}

output "personal_workflow_file" {
  description = "Personal repository workflow file path"
  value       = github_repository_file.personal_workflow.file
}

output "organization_workflow_file" {
  description = "Organization repository workflow file path"
  value       = github_repository_file.organization_workflow.file
}

output "sync_token_secret" {
  description = "GitHub Actions secret name for sync token"
  value       = github_actions_secret.sync_token.secret_name
}