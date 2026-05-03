provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_firewall_group" "this" {
  description = var.description
}

resource "vultr_firewall_rule" "inbound" {
  for_each = { for rule in var.inbound_rules : rule.label => rule }

  firewall_group_id = vultr_firewall_group.this.id
  protocol          = each.value.protocol
  subnet            = cidrhost(each.value.network, 0)
  subnet_size       = tonumber(split("/", each.value.network)[1])
  port              = each.value.port != "" ? each.value.port : null
  ip_type           = each.value.ip_type
  notes             = each.value.label
}
