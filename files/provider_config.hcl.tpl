terraform {
  required_version = "~> 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.42, < 5.0"
    }
  }
}

provider "google" {
  # By default, the AWS provider will use whatever authentication mechanism is configured in your shell environment.
  # See the offical AWS provider documentation for details on how to configure AWS access for Terraform:
  #
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
}

data "google_storage_project_service_account" "gcs_account" {
  project = "{{namespace}}-{{environment}}"
}

resource "google_kms_crypto_key_iam_binding" "binding" {
  crypto_key_id = {{module_reference}}["default"]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}
