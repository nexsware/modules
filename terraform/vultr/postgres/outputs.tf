output "id" {
  description = "The ID of the managed PostgreSQL cluster"
  value       = vultr_database.this.id
}

output "host" {
  description = "The public hostname for the database cluster"
  value       = vultr_database.this.host
}

output "port" {
  description = "The port the database listens on"
  value       = vultr_database.this.port
}

output "user" {
  description = "The admin username"
  value       = vultr_database.this.user
}

output "password" {
  description = "The admin password"
  value       = vultr_database.this.password
  sensitive   = true
}

output "dbname" {
  description = "The default database name"
  value       = vultr_database.this.dbname
}

output "status" {
  description = "Current status of the cluster"
  value       = vultr_database.this.status
}

output "connection_string" {
  description = "PostgreSQL connection string (for use in app config)"
  value       = "postgresql://${vultr_database.this.user}:${vultr_database.this.password}@${vultr_database.this.host}:${vultr_database.this.port}/${vultr_database.this.dbname}?sslmode=require"
  sensitive   = true
}
