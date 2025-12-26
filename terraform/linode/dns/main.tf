provider "linode" {
  token = var.linode_token
}



resource "linode_domain_record" "main" {
  count      = length(var.dns_records)
  domain_id  = var.domain_id
  name       = var.dns_records[count.index].name
  record_type= var.dns_records[count.index].type
  target     = var.dns_records[count.index].value
  ttl_sec    = var.ttl_sec
}