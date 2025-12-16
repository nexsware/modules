# -----------------------------------------------------------------------------
# Linode Instance with DNS Module
# Combines instance and dns modules into a single reusable module
# -----------------------------------------------------------------------------

module "instance" {
  source = "../instance"

  label           = var.label
  image           = var.image
  region          = var.region
  type            = var.type
  root_pass       = var.root_pass
  authorized_keys = var.authorized_keys
  tags            = var.tags
  private_ip      = var.private_ip
}

module "dns" {
  source = "../dns"

  domain_id         = var.domain_id
  domain_name       = var.domain_name
  domain_type       = var.domain_type
  subdomain         = var.subdomain
  target_ip         = module.instance.ipv4_address
  record_type       = var.dns_record_type
  ttl_sec           = var.dns_ttl_sec
  create_dns_record = var.create_dns_record
}
