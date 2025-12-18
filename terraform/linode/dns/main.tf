provider "linode" {
  token = var.linode_token
}

resource "linode_domain_record" "main" {
    count = var.create_dns_record ? 1 : 0
    domain_id = var.domain_id
    name = var.subdomain != "" ? var.subdomain : ""
    record_type = var.record_type
    target = var.target_ip
    ttl_sec = var.ttl_sec
}