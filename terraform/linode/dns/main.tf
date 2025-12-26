provider "linode" {
  token = var.linode_token
}


locals {
  dns_records = jsondecode(var.dns_records)
}

resource "linode_domain_record" "main" {
  count      = length(local.dns_records)
  domain_id  = var.domain_id
  name       = local.dns_records[count.index]["name"]
  record_type= local.dns_records[count.index]["type"]
  target     = local.dns_records[count.index]["value"]
  ttl_sec    = var.ttl_sec
}