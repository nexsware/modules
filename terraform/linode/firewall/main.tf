terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_firewall" "main" {
  label = var.firewall_label
  # Pass VPC and Subnet IDs as tags for grouping and future compatibility
  tags  = compact(concat(var.firewall_tags, [
    var.vpc_id != "" ? "vpc_id:${var.vpc_id}" : null,
    var.subnet_id != "" ? "subnet_id:${var.subnet_id}" : null
  ]))
  # NOTE: Linode does not currently support direct firewall-to-VPC/subnet association in Terraform.
  # These variables are passed for documentation, grouping, and future use.

  # Inbound rules
  dynamic "inbound" {
    for_each = var.inbound_rules
    content {
      label    = inbound.value.label
      action   = inbound.value.action
      protocol = inbound.value.protocol
      ports    = inbound.value.ports
      ipv4     = inbound.value.ipv4
      ipv6     = length(inbound.value.ipv6) > 0 ? inbound.value.ipv6 : ["::1/128"]
    }
  }

  # Outbound rules
  dynamic "outbound" {
    for_each = var.outbound_rules
    content {
      label    = outbound.value.label
      action   = outbound.value.action
      protocol = outbound.value.protocol
      ports    = outbound.value.ports
      ipv4     = outbound.value.ipv4
      ipv6     = length(outbound.value.ipv6) > 0 ? outbound.value.ipv6 : ["::/0"]
    }
  }

  # Attach to Linodes
  linodes = var.linodes

  # Defaults
  inbound_policy  = "ACCEPT"
  outbound_policy = "ACCEPT"
}