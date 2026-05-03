provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_vpc" "this" {
  region        = var.region
  description   = var.description
  v4_subnet      = var.ip_block
  v4_subnet_mask = var.prefix_length
}
