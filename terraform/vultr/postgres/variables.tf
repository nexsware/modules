variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "label" {
  type        = string
  description = "Label for the managed PostgreSQL cluster"
}

variable "region" {
  type        = string
  description = "Vultr region slug (e.g., jnb for Johannesburg)"
}

variable "plan" {
  type        = string
  description = "Vultr managed database plan slug (e.g., vultr-dbaas-startup-cc-1-55-2)"
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL major version (e.g., 16)"
  default     = "16"
}

variable "cluster_time_zone" {
  type        = string
  description = "Time zone for the database cluster (IANA format, e.g., Africa/Nairobi)"
  default     = "Africa/Nairobi"
}

variable "maintenance_dow" {
  type        = string
  description = "Day of week for maintenance window (monday … sunday)"
  default     = "sunday"
}

variable "maintenance_time" {
  type        = string
  description = "Time for maintenance window in HH:MM format (UTC)"
  default     = "22:00"
}

variable "databases" {
  type        = list(string)
  description = "Additional databases to create beyond the default one"
  default     = []
}

variable "database_users" {
  description = "Map of additional database users to create"
  type = map(object({
    password = string
    roles    = optional(list(string), [])
  }))
  default   = {}
  sensitive = true
}

variable "create_resources" {
  type        = bool
  description = "Set false on first apply before the cluster is ready, then re-apply with true"
  default     = true
}
