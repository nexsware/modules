output "database_id" {
  description = "The ID of the PostgreSQL database cluster."
  value       = linode_database_postgresql_v2.foobar.id
}

output "database_label" {
  description = "The label of the PostgreSQL database cluster."
  value       = linode_database_postgresql_v2.foobar.label
}

output "database_engine" {
  description = "The engine and version of the PostgreSQL database."
  value       = linode_database_postgresql_v2.foobar.engine_id
}

output "database_region" {
  description = "The region where the PostgreSQL database cluster is deployed."
  value       = linode_database_postgresql_v2.foobar.region
}

output "database_type" {
  description = "The Linode plan type of the database cluster."
  value       = linode_database_postgresql_v2.foobar.type
}

output "database_status" {
  description = "The status of the PostgreSQL database cluster."
  value       = linode_database_postgresql_v2.foobar.status
}

output "database_host" {
  description = "The primary host/endpoint for the PostgreSQL database."
  value       = linode_database_postgresql_v2.foobar.host_primary
}

output "database_port" {
  description = "The port for the PostgreSQL database."
  value       = linode_database_postgresql_v2.foobar.port
}

output "database_cluster_size" {
  description = "The number of nodes in the database cluster."
  value       = linode_database_postgresql_v2.foobar.cluster_size
}

output "database_allow_list" {
  description = "The list of IP addresses allowed to access the database."
  value       = linode_database_postgresql_v2.foobar.allow_list
}

output "connection_string" {
  description = "The connection string for the PostgreSQL database (without password)."
  value       = "postgresql://${linode_database_postgresql_v2.foobar.host_primary}:${linode_database_postgresql_v2.foobar.port}"
}

output "root_username" {
  description = "The root username for the PostgreSQL database."
  value       = linode_database_postgresql_v2.foobar.root_username
  sensitive   = true
}

output "root_password" {
  value       = linode_database_postgresql_v2.foobar.root_password
  description = "The root password for the PostgreSQL database."
  sensitive   = true
}

output "created_databases" {
  description = "List of additional databases created."
  value       = keys(postgresql_database.databases)
}

output "created_users" {
  description = "List of additional database users created."
  value       = keys(postgresql_role.users)
  sensitive   = true
}

