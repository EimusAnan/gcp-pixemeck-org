# Enable required APIs

resource "google_folder" "bootstrap" {
  display_name        = "Bootstrap"
  parent              = "organizations/${var.org_id}"
  deletion_protection = false
}

resource "google_project" "bootstrap" {
  name                = "bootstrap"
  project_id          = var.project_id
  folder_id           = google_folder.bootstrap.name
  auto_create_network = false
  deletion_policy     = "DELETE"
  billing_account     = var.billing_account_id
}

resource "google_project_service" "required_apis" {
  for_each = toset([
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "serviceusage.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "terraform_pool" {
  workload_identity_pool_id = var.pool_id
  display_name              = "Terraform Enterprise"
  description               = "Workload Identity Pool for Terraform Enterprise"

  disabled = false

  depends_on = [google_project_service.required_apis]
}

# Create OIDC Provider
resource "google_iam_workload_identity_pool_provider" "terraform_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.terraform_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "Terraform Enterprise OIDC"
  description                        = "OIDC provider for Terraform Enterprise"

  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id"
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
  }

  attribute_condition = "assertion.terraform_organization_name==\"${var.terraform_org_name}\""

  oidc {
    issuer_uri = var.issuer_uri
  }
}

# Create Service Account
resource "google_service_account" "terraform" {
  account_id   = var.service_account_name
  display_name = "Terraform Enterprise Service Account"
  description  = "Service account for Terraform Enterprise WIF"
}

# Grant IAM Roles to Service Account
resource "google_project_iam_member" "terraform_roles" {
  for_each = toset(var.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Create IAM Policy Binding - Workload Identity Pool can impersonate SA
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform_pool.name}/attribute.terraform_workspace_id/${var.tfe_workspace_id}"
}

resource "google_organization_iam_binding" "folder_admin_binding" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderAdmin"

  members = [
    "serviceAccount:${google_service_account.terraform.email}",
  ]
}
