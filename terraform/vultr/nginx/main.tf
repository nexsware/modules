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
  vpc2_ids          = length(var.vpc2_ids) > 0 ? var.vpc2_ids : []

  user_data = templatefile("${path.module}/cloud-init.yaml.tmpl", {
    server_name        = var.server_name
    certbot_email      = var.certbot_email != "" ? var.certbot_email : "admin@${var.server_name}"
    proxy_upstreams    = var.proxy_upstreams
    static_root        = var.static_root
    proxy_read_timeout = var.proxy_read_timeout
  })
}
