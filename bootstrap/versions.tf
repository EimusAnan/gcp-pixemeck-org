terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 8.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "< 8.0.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "< 1.0.0"
    }
  }
}