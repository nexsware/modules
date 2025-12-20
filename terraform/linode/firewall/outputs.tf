output "firewall_id" {
  description = "The ID of the Linode firewall"
  value       = linode_firewall.main.id
}

output "firewall_label" {
  description = "The label of the Linode firewall"
  value       = linode_firewall.main.label
}

output "firewall_status" {
  description = "The status of the Linode firewall"
  value       = linode_firewall.main.status
}

output "firewall_inbound_rules" {
  description = "The inbound rules of the Linode firewall"
  value       = linode_firewall.main.inbound
}

output "firewall_outbound_rules" {
  description = "The outbound rules of the Linode firewall"
  value       = linode_firewall.main.outbound
}

output "firewall_linodes" {
  description = "The Linodes attached to the firewall"
  value       = linode_firewall.main.linodes
}

output "firewall_tags" {
  description = "The tags associated with the Linode firewall"
  value       = linode_firewall.main.tags
}