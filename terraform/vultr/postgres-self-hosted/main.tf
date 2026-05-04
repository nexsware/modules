provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "this" {
  plan              = var.plan
  region            = var.region
  os_id             = var.os_id
  label             = var.label
  hostname          = var.hostname != "" ? var.hostname : var.label
  ssh_key_ids       = []
  tags              = var.tags
  firewall_group_id = null
  vpc_ids           = []

  user_data = null
}
