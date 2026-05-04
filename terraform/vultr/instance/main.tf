provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "this" {
  plan              = var.plan
  region            = var.region
  os_id             = var.os_id
  label             = var.label
  hostname          = var.hostname != "" ? var.hostname : var.label
  ssh_key_ids       = var.ssh_key_ids
  tags              = var.tags
  enable_ipv6       = var.enable_ipv6
  firewall_group_id = var.firewall_group_id != "" ? var.firewall_group_id : null
  vpc_ids           = length(var.vpc_ids) > 0 ? var.vpc_ids : []
  user_data = templatefile("${path.module}/cloud-init.yaml.tmpl", {
    private_ip      = var.private_ip
    instance_subnet = var.instance_subnet
    user_data       = var.user_data
  })
}
