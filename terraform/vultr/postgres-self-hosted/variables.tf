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

variable "vpc2_ids" {
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

variable "databases" {
  type        = list(string)
  description = "Databases to create on first boot"
  default     = []
}

variable "database_users" {
  description = "Map of database users to create"
  type = map(object({
    password = string
    roles    = optional(list(string), [])
  }))
  default   = {}
  sensitive = true
}
