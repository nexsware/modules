output "id" {
  description = "The ID of the Linode instance"
  value       = linode_instance.this.id
}

output "ip_address" {
  description = "The primary IPv4 address of the Linode instance"
  value       = try(one(linode_instance.this.ipv4), null)
}

output "label" {
  description = "The label of the Linode instance"
  value       = linode_instance.this.label
}

output "region" {
  description = "The region where the Linode instance is deployed"
  value       = linode_instance.this.region
}

output "type" {
  description = "The Linode plan type of the instance"
  value       = linode_instance.this.type
}

output "tags" {
  description = "The tags assigned to the Linode instance"
  value       = linode_instance.this.tags
}

output "private_ip" {
  description = "The private IP address of the Linode instance, if enabled"
  value       = linode_instance.this.private_ip
}

output "image" {
  description = "The image used for the Linode instance"
  value       = linode_instance.this.image
}

output "vpc_id" {
  description = "The VPC ID attached to the instance (if any)"
  value       = try(linode_vpc_interface.this[0].vpc_id, null)
}

output "subnet_id" {
  description = "The Subnet ID attached to the instance (if any)"
  value       = try(linode_vpc_interface.this[0].subnet_id, null)
}

output "status" {
  description = "The current status of the Linode instance"
  value       = linode_instance.this.status
}

output "specs" {
    description = "The specifications of the instance created"
    value       = linode_instance.this.specs
}

output "public_interface" {
  description = "Whether a public interface was created for the instance"
  value       = var.public_interface
}