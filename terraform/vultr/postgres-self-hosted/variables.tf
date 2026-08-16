variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Vultr region slug (e.g., jnb for Johannesburg)"
}

variable "plan" {
  type        = string
  description = "Vultr plan slug (e.g., vc2-2c-4gb)"
  default     = "vc2-2c-4gb"
}

variable "os_id" {
  type        = number
  description = "Vultr OS ID (e.g., 2284 for Ubuntu 24.04 LTS)"
}

variable "label" {
  type        = string
  description = "Label for the instance"
}

variable "hostname" {
  type        = string
  description = "Hostname — defaults to label if empty"
  default     = ""
}

variable "ssh_key_ids" {
  type        = list(string)
  description = "Vultr SSH key IDs to authorize on the instance"
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags to assign to the instance"
  default     = []
}

variable "firewall_group_id" {
  type        = string
  description = "Firewall group ID to attach — leave empty for none"
  default     = ""
}

variable "vpc_ids" {
  type        = list(string)
  description = "VPC 2.0 IDs to attach for private networking"
  default     = []
}

variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version to install (e.g., 16)"
  default     = "16"
}

variable "postgres_password" {
  type        = string
  description = "Password for the postgres superuser"
  sensitive   = true
}

variable "port" {
  type        = number
  description = "Port PostgreSQL will listen on"
  default     = 5432
}

variable "listen_address" {
  type        = string
  description = "PostgreSQL listen_addresses setting. Use '*' for all interfaces or a specific IP."
  default     = "*"
}

variable "private_ip" {
  type        = string
  description = "Static private IP to assign to the VPC interface (e.g., 10.0.0.65). Must be within db_subnet. Leave empty to use Vultr auto-assigned IP."
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC this instance is deployed into (e.g., 10.0.0.0/24)"
  default     = "10.0.0.0/24"
}

variable "bastion_subnet" {
  type        = string
  description = "CIDR of the bastion subnet — a route is added so the database can reach the bastion (e.g., 10.0.0.128/26)"
  default     = "10.0.0.128/26"
}

variable "app_subnet" {
  type        = string
  description = "CIDR of the app subnet — a route is added so the database can reach app servers (e.g., 10.0.0.0/26)"
  default     = "10.0.0.0/26"
}

variable "db_subnet" {
  type        = string
  description = "CIDR of the subnet within the VPC where this database instance is placed (e.g., 10.0.0.64/26)"
  default     = "10.0.0.64/26"
}

variable "databases" {
  type        = list(string)
  description = "Databases to create on first boot"
  default     = []
}

variable "database_users" {
  description = <<-EOT
    Map of database users to create. privileges selects the grant set:
      "crud" - CONNECT, USAGE on public, SELECT/INSERT/UPDATE/DELETE on tables,
               USAGE/SELECT on sequences and EXECUTE on routines, plus matching
               default privileges so objects created later by postgres are
               covered. No DDL rights.
      "all"  - ALL PRIVILEGES on the database and ALL on schema public (default,
               preserves the behaviour callers had before privileges existed).
  EOT
  type = map(object({
    password   = string
    privileges = optional(string, "all")
  }))
  default   = {}
  sensitive = true

  validation {
    condition     = alltrue([for u in values(var.database_users) : contains(["crud", "all"], u.privileges)])
    error_message = "database_users privileges must be either \"crud\" or \"all\"."
  }
}
