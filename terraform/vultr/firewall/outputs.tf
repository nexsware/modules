output "id" {
  description = "The ID of the firewall group"
  value       = vultr_firewall_group.this.id
}

output "description" {
  description = "The description of the firewall group"
  value       = vultr_firewall_group.this.description
}
