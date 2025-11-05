variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "organization_id" {
  description = "GCP Organization ID (optional)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "GCP Folder ID (optional)"
  type        = string
  default     = null
}

# Service Accounts
variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    display_name = string
    description  = string
  }))
  default = {}
}

variable "create_service_account_keys" {
  description = "Set of service account names to create keys for"
  type        = set(string)
  default     = []
}

variable "key_rotation_time" {
  description = "Timestamp for key rotation (change to rotate keys)"
  type        = string
  default     = "2024-01-01"
}

# Custom Roles
variable "custom_roles" {
  description = "Map of custom roles to create"
  type = map(object({
    title       = string
    description = string
    permissions = list(string)
    stage       = string
  }))
  default = {}
}

# IAM Bindings
variable "project_iam_bindings" {
  description = "Map of project-level IAM role bindings"
  type        = map(list(string))
  default     = {}
}

variable "organization_iam_bindings" {
  description = "Map of organization-level IAM role bindings"
  type        = map(list(string))
  default     = {}
}

variable "folder_iam_bindings" {
  description = "Map of folder-level IAM role bindings"
  type        = map(list(string))
  default     = {}
}

variable "service_account_iam_bindings" {
  description = "Map of service account IAM bindings"
  type = map(object({
    service_account = string
    role           = string
    members        = list(string)
  }))
  default = {}
}

variable "bucket_iam_bindings" {
  description = "Map of storage bucket IAM bindings"
  type = map(object({
    bucket_name = string
    role        = string
    members     = list(string)
  }))
  default = {}
}

# Conditional IAM
variable "conditional_bindings" {
  description = "Map of conditional IAM bindings"
  type = map(object({
    title       = string
    description = string
    expression  = string
  }))
  default = {}
}

# Workload Identity
variable "workload_identity_bindings" {
  description = "Map of Workload Identity bindings for GKE"
  type = map(object({
    service_account = string
    namespace       = string
    ksa_name        = string
  }))
  default = {}
}

# Audit Logging
variable "enable_audit_logging" {
  description = "Enable audit logging configuration"
  type        = bool
  default     = false
}

variable "audit_log_config" {
  description = "Audit log configuration"
  type = map(list(object({
    log_type         = string
    exempted_members = optional(list(string))
  })))
  default = {
    "allServices" = [
      {
        log_type = "ADMIN_READ"
      },
      {
        log_type = "DATA_READ"
      },
      {
        log_type = "DATA_WRITE"
      }
    ]
  }
}

# IAM Deny Policies
variable "iam_deny_policies" {
  description = "Map of IAM deny policies"
  type = map(object({
    display_name         = string
    description          = string
    denied_principals    = list(string)
    denied_permissions   = list(string)
    exception_principals = optional(list(string))
  }))
  default = {}
}
