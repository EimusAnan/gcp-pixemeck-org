output "workload_identity_pool_resource_name" {
  value       = google_iam_workload_identity_pool.terraform_pool.name
  description = "Resource name of the Workload Identity Pool"
}

output "workload_identity_provider_resource_name" {
  value       = google_iam_workload_identity_pool_provider.terraform_provider.name
  description = "Resource name of the OIDC Provider"
}

output "service_account_email" {
  value       = google_service_account.terraform.email
  description = "Email of the service account"
}

output "service_account_unique_id" {
  value       = google_service_account.terraform.unique_id
  description = "Unique ID of the service account"
}

output "tfe_configuration" {
  value = {
    workload_identity_provider = google_iam_workload_identity_pool_provider.terraform_provider.name
    service_account_email      = google_service_account.terraform.email
    project_id                 = var.project_id
  }
  description = "Configuration values needed in TFE"
}