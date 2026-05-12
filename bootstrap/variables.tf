variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "terraform-enterprise"
}

variable "provider_id" {
  description = "OIDC Provider ID"
  type        = string
  default     = "terraform-enterprise-oidc"
}

variable "service_account_name" {
  description = "Service Account name"
  type        = string
  default     = "terraform-enterprise"
}

variable "terraform_org_name" {
  description = "Terraform Enterprise Organization Name"
  type        = string
}

variable "issuer_uri" {
  description = "OIDC Issuer URI"
  type        = string
  default     = "https://app.terraform.io"
}

variable "sa_roles" {
  description = "IAM roles to grant service account"
  type        = list(string)
  default = [
    "roles/storage.admin",
  ]
}

variable "tfe_workspace_id" {
  type        = string
  description = "Terraform Enterprise Workspace ID"
}
