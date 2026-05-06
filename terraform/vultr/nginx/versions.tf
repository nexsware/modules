terraform {
  required_version = ">= 1.0"

  backend "s3" {}

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}
