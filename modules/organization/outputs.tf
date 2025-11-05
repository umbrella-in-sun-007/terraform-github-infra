output "repository_url" {
  description = "URL of the created repository"
  value       = github_repository.repo.html_url
}
