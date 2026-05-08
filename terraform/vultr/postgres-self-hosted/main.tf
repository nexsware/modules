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
  firewall_group_id = var.firewall_group_id != "" ? var.firewall_group_id : null
  vpc_ids           = length(var.vpc_ids) > 0 ? var.vpc_ids : []

  user_data = templatefile("${path.module}/cloud-init.yaml.tmpl", {
    postgres_version  = var.postgres_version
    postgres_password = var.postgres_password
    listen_address    = var.listen_address
    port              = var.port
    private_ip        = var.private_ip
    db_subnet         = var.db_subnet
    bastion_subnet    = var.bastion_subnet
    app_subnet        = var.app_subnet
    databases         = var.databases
    database_users    = var.database_users
  })
}
