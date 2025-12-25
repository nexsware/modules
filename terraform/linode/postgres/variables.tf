variable "label" {
  description = "The label for the PostgreSQL database cluster."
  type        = string
}

variable "engine_id" {
  description = "The database engine and version."
  type        = string
}

variable "region" {
  description = "The Linode region where the database cluster will be created."
  type        = string
}

variable "type" {
  description = "The Linode plan type for the database cluster."
  type        = string
}

variable "allow_list" {
  description = "A list of IP addresses or CIDR blocks to allow access to the database cluster."
  type        = list(string)
  default     = []
}

variable "cluster_size" {
  description = "The number of nodes in the database cluster."
  type        = number
  default     = 1
}

# variable "updates"
variable "update_duration" {
  description = "The duration of the maintenance window in hours."
  type        = number
  default     = 4
}

variable "update_frequency" {
  description = "The frequency of the maintenance window."
  type        = string
  default     = "weekly"
}

variable "update_hour_of_day" {
  description = "The hour of the day for the maintenance window."
  type        = number
  default     = 22
}

variable "update_day_of_week" {
  description = "The day of the week for the maintenance window."
  type        = number
  default     = 2
}

variable "database_users" {
  description = "Map of additional database users to create. Each user should have 'password' and optional 'roles' list."
  type = map(object({
    password = string
    roles    = optional(list(string), [])
  }))
  default = {}
}

variable "databases" {
  description = "List of additional databases to create (besides the default 'postgres' database)."
  type        = list(string)
  default     = []
}

variable "linode_token" {
  type        = string
  description = "The API token for Linode"
  sensitive   = true
}

variable "create_resources" {
  type        = bool
  description = "Whether to create databases and users (set to false for initial database creation)"
  default     = true
}
