terraform {
  required_version = ">= 1.6"

  backend "s3" {
    region = "us-east-1"

    endpoints = {
      s3 = "https://ams1.vultrobjects.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}
