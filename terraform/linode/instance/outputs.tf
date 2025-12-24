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

output "status" {
  description = "The current status of the Linode instance"
  value       = linode_instance.this.status
}

output "specs" {
    description = "The specifications of the instance created"
    value       = linode_instance.this.specs
}

output "database_password" {
  value = linode_database_postgresql_v2.pgsql-cluster-1.root_password
  sensitive = true
  description = "The password associated to the admin username"
}

output "database_username" {
  value = linode_database_postgresql_v2.pgsql-cluster-1.root_username
  sensitive = true
  description = "The admin username"
}

output "database_fqdn" {
  value = linode_database_postgresql_v2.pgsql-cluster-1.host_primary
  description = "The fqdn you can use to access the DB"
}

output "db_certificate" {
  value = linode_database_postgresql_v2.pgsql-cluster-1.ca_cert
  sensitive = true
  description = "The certificate used for DB Connections"
}

output "database_port" {
  value = linode_database_postgresql_v2.pgsql-cluster-1.port
  description = "The TCP Port used by the database"
}

output "database_id" {
  description = "The cluster ID used by Akamai"
  value = linode_database_postgresql_v2.pgsql-cluster-1.id
}

output "database1_created_databases" {
  value = module.database1.databases
  description = "List of databases created by database1 module"
}

output "database2_created_databases" {
  value = module.database2.databases
  description = "List of databases created by database2 module"
}