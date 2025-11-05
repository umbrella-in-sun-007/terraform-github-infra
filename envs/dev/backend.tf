# Development Environment Backend Configuration
# This file configures the Terraform state backend

terraform {
  # Uncomment and configure the backend after creating a state bucket
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket-dev"
  #   prefix = "terraform/state/dev"
  # }
  
  # For learning purposes, you can start with local state
  # Later, migrate to a GCS backend for better collaboration
}

# Note: To set up GCS backend:
# 1. Create a GCS bucket for Terraform state
# 2. Enable versioning on the bucket
# 3. Uncomment and configure the backend block above
# 4. Run `terraform init -migrate-state`

# Example backend configuration:
# terraform {
#   backend "gcs" {
#     bucket                      = "my-terraform-state-dev"
#     prefix                      = "terraform/state"
#     impersonate_service_account = "terraform@my-project.iam.gserviceaccount.com"
#   }
# }
