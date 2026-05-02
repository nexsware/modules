output "id" {
  description = "The ID of the nginx proxy instance"
  value       = vultr_instance.this.id
}

output "ip_address" {
  description = "The public IPv4 address — point your DNS A record here"
  value       = vultr_instance.this.main_ip
}

output "label" {
  description = "The label of the instance"
  value       = vultr_instance.this.label
}

output "region" {
  description = "The region where the instance is deployed"
  value       = vultr_instance.this.region
}

output "plan" {
  description = "The plan used for the instance"
  value       = vultr_instance.this.plan
}

output "status" {
  description = "The current power status of the instance"
  value       = vultr_instance.this.status
}

output "server_name" {
  description = "The domain this nginx instance is serving"
  value       = var.server_name
}
