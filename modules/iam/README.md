# IAM Module

This module manages Identity and Access Management (IAM) resources including service accounts and IAM bindings.

## Resources Created

- **Service Accounts**: Identity for applications and services
- **IAM Bindings**: Role assignments at project level
- **Custom Roles**: Tailored permissions for specific needs (optional)

## Usage Examples

### Basic Service Accounts
```hcl
module "iam" {
  source = "../modules/iam"
  
  project_id = "my-project"
  
  service_accounts = {
    "app-backend" = {
      display_name = "Application Backend"
      description  = "Service account for backend services"
    }
    "data-processor" = {
      display_name = "Data Processing Service"
      description  = "Service account for data processing jobs"
    }
  }
}
```

### Project-Level IAM Bindings
```hcl
project_iam_bindings = {
  "roles/storage.objectViewer" = [
    "serviceAccount:app-backend@project.iam.gserviceaccount.com",
    "user:developer@company.com"
  ]
  "roles/compute.instanceAdmin.v1" = [
    "serviceAccount:deployment@project.iam.gserviceaccount.com"
  ]
}
```

### Custom Roles
```hcl
custom_roles = {
  "custom.dataProcessor" = {
    title       = "Data Processor"
    description = "Custom role for data processing tasks"
    stage       = "GA"
    permissions = [
      "storage.objects.get",
      "storage.objects.list",
      "bigquery.jobs.create",
      "bigquery.tables.get"
    ]
  }
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | GCP project ID | string | n/a |
| service_accounts | Map of service accounts to create | map(object) | {} |
| project_iam_bindings | IAM bindings at project level | map(list(string)) | {} |
| custom_roles | Custom roles to create | map(object) | {} |

## Outputs

| Name | Description |
|------|-------------|
| service_account_emails | Map of service account emails |
| service_account_ids | Map of service account IDs |
