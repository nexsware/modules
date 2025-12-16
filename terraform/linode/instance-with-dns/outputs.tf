# -----------------------------------------------------------------------------
# Instance Outputs
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "The ID of the Linode instance"
  value       = module.instance.instance_id
}

output "label" {
  description = "The label of the Linode instance"
  value       = module.instance.label
}

output "ipv4_address" {
  description = "The primary IPv4 address of the Linode instance"
  value       = module.instance.ipv4_address
}

output "private_ip" {
  description = "The private IP address of the Linode instance, if enabled"
  value       = module.instance.private_ip
}

output "region" {
  description = "The region where the Linode instance is deployed"
  value       = module.instance.region
}

output "type" {
  description = "The Linode plan type of the instance"
  value       = module.instance.type
}

output "tags" {
  description = "The tags assigned to the Linode instance"
  value       = module.instance.tags
}

output "image" {
  description = "The image used for the Linode instance"
  value       = module.instance.image
}

# -----------------------------------------------------------------------------
# DNS Outputs
# -----------------------------------------------------------------------------

output "dns_record_id" {
  description = "The ID of the DNS record"
  value       = module.dns.record_id
}

output "dns_record_name" {
  description = "The name of the DNS record"
  value       = module.dns.record_name
}

output "dns_record_target" {
  description = "The target of the DNS record"
  value       = module.dns.record_target
}

output "fqdn" {
  description = "The fully qualified domain name"
  value       = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
}
