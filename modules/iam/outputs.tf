output "service_account_emails" {
  description = "Map of service account emails"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.email
  }
}

output "service_account_ids" {
  description = "Map of service account IDs"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.id
  }
}

output "service_account_unique_ids" {
  description = "Map of service account unique IDs"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.unique_id
  }
}

output "service_account_keys" {
  description = "Map of service account private keys (sensitive)"
  value = {
    for name, key in google_service_account_key.service_account_keys : name => key.private_key
  }
  sensitive = true
}

output "custom_role_ids" {
  description = "Map of custom role IDs"
  value = {
    for name, role in google_project_iam_custom_role.custom_roles : name => role.id
  }
}

output "custom_role_names" {
  description = "Map of custom role names"
  value = {
    for name, role in google_project_iam_custom_role.custom_roles : name => role.name
  }
}

# Output for easy reference in other modules
output "common_service_accounts" {
  description = "Common service account references"
  value = {
    compute_sa = contains(keys(var.service_accounts), "compute-sa") ? google_service_account.service_accounts["compute-sa"].email : null
    gke_sa     = contains(keys(var.service_accounts), "gke-sa") ? google_service_account.service_accounts["gke-sa"].email : null
    storage_sa = contains(keys(var.service_accounts), "storage-sa") ? google_service_account.service_accounts["storage-sa"].email : null
  }
}
