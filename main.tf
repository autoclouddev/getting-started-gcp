## --------------------------------------------------------------------------------------------------------------------
## GITHUB REPOSITORY CONFIGURATION
## Define which Github repositories the Terraform blueprint user has access to
## --------------------------------------------------------------------------------------------------------------------

data "autocloud_github_repos" "repos" {}

locals {
  # A list of Github repositories the user is allowed to submit Terraform code to, add specific repositories out of the
  # repositories you have authorized AutoCloud to access to limit users to your infrastructure as code repositories. If
  # you set these, uncomment the filter lines in the `dest_repos` definition on lines 20-23 below.
  # 
  # allowed_repos = [
  #   "example",
  # ]

  # Destination repos where generated code will be submitted
  dest_repos = [
    for repo in data.autocloud_github_repos.repos.data[*].url : repo

    # Uncomment if you have defined an allow list for your repos on lines 12-14 above.
    #
    # if anytrue([
    #   for allowed_repo in local.allowed_repos: length(regexall(format("/%s", allowed_repo), repo)) > 0
    # ])
  ]
}



## --------------------------------------------------------------------------------------------------------------------
## GLOBAL BLUEPRINT CONFIGURATION
## Define form questions the user will be shown which are either not associated with any Terraform module, or are shared
## between multiple Terraform modules.
## --------------------------------------------------------------------------------------------------------------------

data "autocloud_blueprint_config" "global" {
  ###
  # Set the namespace
  variable {
    name         = "namespace"
    display_name = "Namespace"
    helper_text  = "The organization namespace the assets will be deployed in"

    type = "shortText"

    value = "autocloud"
  }

  ###
  # Choose the environment
  variable {
    name         = "environment"
    display_name = "Environment"
    helper_text  = "The environment the assets will be deployed in"

    type = "radio"

    options {
      option {
        label   = "Nonprod"
        value   = "nonprod"
        checked = true
      }
      option {
        label = "Production"
        value = "production"
      }
    }
  }

  ###
  # Collect the name of the asset group
  variable {
    name         = "name"
    display_name = "Name"
    helper_text  = "The name of the encrypted cloud storage bucket"

    type = "shortText"

    validation_rule {
      rule          = "isRequired"
      error_message = "You must provide a name for the encrypted S3 bucket"
    }
  }
}



## --------------------------------------------------------------------------------------------------------------------
## GOOGLE CLOUD CONFIGURATION
## Define Google cloud specific elements that will be added to all assets, such as labels and tags
## between multiple Terraform modules.
## --------------------------------------------------------------------------------------------------------------------

data "autocloud_blueprint_config" "gcp" {
  source = {
    global = data.autocloud_blueprint_config.global.blueprint_config,
  }

  ###
  # Set the project ID
  variable {
    name         = "project_id"
    display_name = "Project ID"
    helper_text  = "The Google Cloud project ID the assets will be deployed in"

    type = "shortText"

    value = "{{namespace}}-{{environment}}"

    variables = {
      namespace   = "global.variables.namespace",
      environment = "global.variables.environment",
    }
  }

  ###
  # Choose the location
  variable {
    name         = "location"
    display_name = "Location"
    helper_text  = "The location the assets will be deployed in"

    type = "radio"

    options {
      option {
        label = "ASIA"
        value = "ASIA"
      }
      option {
        label = "EU"
        value = "EU"
      }
      option {
        label   = "US"
        value   = "US"
        checked = true
      }
    }
  }

  ###
  # Collect labels to apply to assets
  variable {
    name         = "labels"
    display_name = "Labels"
    helper_text  = "A map of labels to apply to the deployed assets"

    type = "map"
  }
}



## --------------------------------------------------------------------------------------------------------------------
## KMS KEY MODULE
## Define display and output for the KMS key used to encrypt the cloud storage bucket.
## --------------------------------------------------------------------------------------------------------------------

resource "autocloud_module" "kms_key" {
  name   = "kmskey"
  source = "github.com/terraform-google-modules/terraform-google-kms?ref=v2.2.2"
}

data "autocloud_blueprint_config" "kms_key" {
  source = {
    global = data.autocloud_blueprint_config.global.blueprint_config,
    gcp    = data.autocloud_blueprint_config.gcp.blueprint_config,
    kms    = autocloud_module.kms_key.blueprint_config
  }

  omit_variables = [
    # Global
    "labels",
    "location",
    "project_id",

    # Use defaults in the module (don't collect)
    "keys",
    "prevent_destroy",
    "purpose",
    "set_owners_for",
    "owners",
    "set_encrypters_for",
    "encrypters",
    "set_decrypters_for",
    "decrypters",
    "key_rotation_period",
    "key_algorithm",
    "key_protection_level",

    # Defined below
    "keyring",
  ]

  ###
  # Pass GCP details
  variable {
    name  = "kms.variables.labels"
    type  = "map"
    value = "gcp.variables.labels"
  }

  variable {
    name  = "kms.variables.location"
    type  = "shortText"
    value = "gcp.variables.location"
  }

  variable {
    name  = "kms.variables.project_id"
    type  = "shortText"
    value = "gcp.variables.project_id"
  }

  ###
  # Set keyring name
  variable {
    name         = "keyring"
    display_name = "KMS Keyring Name"

    type = "shortText"

    value = "{{namespace}}-{{environment}}-{{name}}"
    variables = {
      namespace   = "global.variables.namespace"
      environment = "global.variables.environment"
      name        = "global.variables.name"
    }
  }
}



## --------------------------------------------------------------------------------------------------------------------
## CLOUD STORAGE BUCKET MODULE
## Define display and output for the cloud storage bucket.
## --------------------------------------------------------------------------------------------------------------------

resource "autocloud_module" "bucket" {
  name   = "bucket"
  source = "github.com/terraform-google-modules/terraform-google-cloud-storage?ref=v4.0.0"
}

data "autocloud_blueprint_config" "bucket" {
  source = {
    global = data.autocloud_blueprint_config.global.blueprint_config,
    gcp    = data.autocloud_blueprint_config.gcp.blueprint_config,
    bucket = autocloud_module.bucket.blueprint_config
  }

  omit_variables = [
    # Global
    "labels",
    "location",
    "project_id",

    # Use defaults in the module (don't collect)
    "admins",
    "bucket_admins",
    "bucket_creators",
    "bucket_hmac_key_admins",
    "bucket_lifecycle_rules",
    "bucket_policy_only",
    "bucket_storage_admins",
    "bucket_viewers",
    "cors",
    "creators",
    "custom_placement_config",
    "default_event_based_hold",
    "folders",
    "force_destroy",
    "hmac_key_admins",
    "hmac_service_accounts",
    "lifecycle_rules",
    "logging",
    "names",
    "prefix",
    "randomize_suffix",
    "retention_policy",
    "set_admin_roles",
    "set_creator_roles",
    "set_hmac_access",
    "set_hmac_key_admin_roles",
    "set_storage_admin_roles",
    "set_viewer_roles",
    "storage_admins",
    "storage_class",
    "versioning",
    "viewers",
    "website",

    # Defined below
    "encryption_key_names",
    "name",
    "public_access_prevention",
  ]

  ###
  # Pass GCP details
  variable {
    name  = "bucket.variables.labels"
    type  = "map"
    value = "gcp.variables.labels"
  }

  variable {
    name  = "bucket.variables.location"
    type  = "shortText"
    value = "gcp.variables.location"
  }

  variable {
    name  = "bucket.variables.project_id"
    type  = "shortText"
    value = "gcp.variables.project_id"
  }

  ###
  # Set the KMS Keys
  variable {
    name  = "bucket.variables.encryption_key_names"
    value = jsonencode([autocloud_module.kms_key.outputs.keyring_name])
  }

  ###
  # Set Public Access Prevention to Enforced
  variable {
    name  = "bucket.variables.public_access_prevention"
    value = "enforced"
  }

  ###
  # Set the bucket name
  variable {
    name         = "bucket.variables.name"
    display_name = "Storage Bucket Name"
    type         = "shortText"
    value        = "{{namespace}}-{{environment}}-{{name}}"
    variables = {
      namespace   = "global.variables.namespace"
      environment = "global.variables.environment"
      name        = "global.variables.name"
    }
  }
}



## --------------------------------------------------------------------------------------------------------------------
## COMPLETE BLUEPRINT CONFIGURATION
## Combine all the defined Terraform blueprint configurations into the complete blueprint configuration that will be used
## to create the form shown to the end user.
## --------------------------------------------------------------------------------------------------------------------

data "autocloud_blueprint_config" "complete" {
  source = {
    global  = data.autocloud_blueprint_config.global.blueprint_config,
    gcp     = data.autocloud_blueprint_config.gcp.blueprint_config,
    kms_key = data.autocloud_blueprint_config.kms_key.blueprint_config,
    bucket  = data.autocloud_blueprint_config.bucket.blueprint_config
  }

  ###
  # Hide variables from user
  omit_variables = [
    # Global

    # KMS Key
    "kms_key.variables.project_id",
    "kms_key.variables.location",
    "kms_key.variables.labels",

    # Cloud Storage Bucket
    "bucket.variables.project_id",
    "bucket.variables.location",
    "bucket.variables.labels",

    "bucket.variables.public_access_prevention",
  ]

  display_order {
    priority = 0
    values = [
      "global.variables.namespace",
      "global.variables.environment",
      "global.variables.name",
      "gcp.variables.location",
      "gcp.variables.project_id",
      "gcp.variables.labels",
    ]
  }
}



## --------------------------------------------------------------------------------------------------------------------
## AUTOCLOUD BLUEPRINT
## Create the AutoCloud Terraform blueprint using the modules and blueprint configurations defined above. 
## --------------------------------------------------------------------------------------------------------------------

resource "autocloud_blueprint" "this" {
  name = "[Getting Started] KMS Encrypted Google Cloud Storage Bucket"

  ###
  # UI Configuration
  #
  author       = "example@example.com"
  description  = "Deploy a Google Cloud storage bucket encrypted with a customer managed KMS key"
  instructions = <<-EOT
    To deploy this generator, these simple steps:

      * step 1: Choose the target environment
      * step 2: Provide a name to identify assets
      * step 3: Add tags to apply to assets
    EOT

  labels = ["gcp"]



  ###
  # Form configuration
  config = data.autocloud_blueprint_config.complete.config



  ###
  # File definitions
  file {
    action      = "CREATE"
    destination = "{{namespace}}-{{environment}}-{{name}}.tf"
    variables = {
      namespace   = data.autocloud_blueprint_config.complete.variables["namespace"]
      environment = data.autocloud_blueprint_config.complete.variables["environment"]
      name        = data.autocloud_blueprint_config.complete.variables["name"]

      module_reference = autocloud_module.kms_key.outputs.keys
    }

    ###
    # Add version requirements and provider configuration to the top of the output file. See ./files/provider_config.hcl.tpl
    # for content to be added.
    header = file("./files/provider_config.hcl.tpl")

    modules = [
      autocloud_module.kms_key.name,
      autocloud_module.bucket.name,
    ]
  }



  ###
  # Destination repository git configuraiton
  #
  git_config {
    destination_branch = "main"

    git_url_options = local.dest_repos
    git_url_default = length(local.dest_repos) != 0 ? local.dest_repos[0] : "" # Choose the first in the list by default

    pull_request {
      title                   = "[AutoCloud] new KMS Encrypted Cloud Storage Bucket {{namespace}}-{{environment}}-{{name}}, created by {{authorName}}"
      commit_message_template = "[AutoCloud] new KMS Encrypted Cloud Storage Bucket {{namespace}}-{{environment}}-{{name}}, created by {{authorName}}"
      body                    = file("./files/pull_request.md.tpl")
      variables = {
        authorName  = "generic.authorName"
        namespace   = data.autocloud_blueprint_config.complete.variables["namespace"]
        environment = data.autocloud_blueprint_config.complete.variables["environment"]
        name        = data.autocloud_blueprint_config.complete.variables["name"]
      }
    }
  }
}
