output "id" {
  description = "The ID of the VPC 2.0"
  value       = vultr_vpc.this.id
}

output "region" {
  description = "The region where the VPC is deployed"
  value       = vultr_vpc.this.region
}

output "ip_block" {
  description = "The IPv4 network address of the VPC subnet"
  value       = vultr_vpc.this.v4_subnet
}

output "prefix_length" {
  description = "The prefix length of the VPC subnet"
  value       = vultr_vpc.this.v4_subnet_mask
}

output "description" {
  description = "The description of the VPC"
  value       = vultr_vpc.this.description
}
