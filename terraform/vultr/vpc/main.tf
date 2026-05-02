provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_vpc2" "this" {
  region        = var.region
  description   = var.description
  ip_block      = var.ip_block
  prefix_length = var.prefix_length
}
