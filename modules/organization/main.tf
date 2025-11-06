# create a repository in the organization
resource "github_repository" "repo" {
  name        = var.repo_name
  description = "Repository managed by terraform"
  visibility  = var.repo_private ? "private" : "public"
  auto_init   = true
}

# output "repository_url" {
#     value = github_repository.repo.html_url
# }