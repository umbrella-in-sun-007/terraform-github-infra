# GCP IAM Module - Service Accounts, IAM Bindings, Custom Roles
# Learn about GCP Identity and Access Management here

# Custom IAM roles (optional)
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
  project     = var.project_id
}

# Service accounts for different purposes
resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

# Service account keys (be careful with these in production!)
resource "google_service_account_key" "service_account_keys" {
  for_each = var.create_service_account_keys

  service_account_id = google_service_account.service_accounts[each.key].name
  public_key_type    = "TYPE_X509_PEM_FILE"
  
  # Keys should be rotated regularly
  keepers = {
    rotation_time = var.key_rotation_time
  }
}

# Project-level IAM bindings
resource "google_project_iam_binding" "project_bindings" {
  for_each = var.project_iam_bindings

  project = var.project_id
  role    = each.key
  members = each.value

  # Conditional bindings (advanced)
  dynamic "condition" {
    for_each = lookup(var.conditional_bindings, each.key, null) != null ? [1] : []
    content {
      title       = var.conditional_bindings[each.key].title
      description = var.conditional_bindings[each.key].description
      expression  = var.conditional_bindings[each.key].expression
    }
  }
}

# Service account IAM bindings (for service account impersonation)
resource "google_service_account_iam_binding" "sa_bindings" {
  for_each = var.service_account_iam_bindings

  service_account_id = google_service_account.service_accounts[each.value.service_account].name
  role               = each.value.role
  members            = each.value.members
}

# Workload Identity binding (for GKE)
resource "google_service_account_iam_binding" "workload_identity" {
  for_each = var.workload_identity_bindings

  service_account_id = google_service_account.service_accounts[each.value.service_account].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.ksa_name}]"
  ]
}

# Organization-level IAM bindings (if you have org access)
resource "google_organization_iam_binding" "org_bindings" {
  for_each = var.organization_id != null ? var.organization_iam_bindings : {}

  org_id  = var.organization_id
  role    = each.key
  members = each.value
}

# Folder-level IAM bindings (if using folders)
resource "google_folder_iam_binding" "folder_bindings" {
  for_each = var.folder_id != null ? var.folder_iam_bindings : {}

  folder  = var.folder_id
  role    = each.key
  members = each.value
}

# IAM policy for bucket (example of resource-specific IAM)
resource "google_storage_bucket_iam_binding" "bucket_bindings" {
  for_each = var.bucket_iam_bindings

  bucket  = each.value.bucket_name
  role    = each.value.role
  members = each.value.members
}

# Audit logging configuration
resource "google_project_iam_audit_config" "audit_config" {
  for_each = var.enable_audit_logging ? var.audit_log_config : {}

  project = var.project_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = each.value
    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = lookup(audit_log_config.value, "exempted_members", [])
    }
  }
}

# IAM Deny Policies (newer feature for additional security)
resource "google_iam_deny_policy" "deny_policies" {
  for_each = var.iam_deny_policies

  parent       = "projects/${var.project_id}"
  name         = each.key
  display_name = each.value.display_name

  rules {
    description = each.value.description
    
    deny_rule {
      denied_principals  = each.value.denied_principals
      denied_permissions = each.value.denied_permissions
      
      dynamic "exception_principals" {
        for_each = lookup(each.value, "exception_principals", [])
        content {
          principals = exception_principals.value
        }
      }
    }
  }
}
