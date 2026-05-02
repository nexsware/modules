output "id" {
  description = "The ID of the VPC 2.0"
  value       = vultr_vpc2.this.id
}

output "region" {
  description = "The region where the VPC is deployed"
  value       = vultr_vpc2.this.region
}

output "ip_block" {
  description = "The IPv4 network address of the VPC subnet"
  value       = vultr_vpc2.this.ip_block
}

output "prefix_length" {
  description = "The prefix length of the VPC subnet"
  value       = vultr_vpc2.this.prefix_length
}

output "description" {
  description = "The description of the VPC"
  value       = vultr_vpc2.this.description
}
