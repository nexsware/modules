variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
  sensitive   = true
}

variable "plan" {
  type        = string
  description = "Vultr plan slug (e.g., vhp-2c-4gb-intel)"
  default     = "vhp-2c-4gb-intel"
}

variable "region" {
  type        = string
  description = "Vultr region slug (e.g., jnb for Johannesburg)"
}

variable "os_id" {
  type        = number
  description = "Vultr OS ID (e.g., 2284 for Ubuntu 24.04 LTS — verify with: vultr os list)"
}

variable "label" {
  type        = string
  description = "Label for the nginx proxy instance"
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

variable "enable_ipv6" {
  type        = bool
  description = "Whether to enable IPv6"
  default     = false
}

variable "firewall_group_id" {
  type        = string
  description = "Firewall group ID to attach — leave empty for none"
  default     = ""
}

variable "vpc_ids" {
  type        = list(string)
  description = "VPC IDs to attach so nginx can reach backend services over private network"
  default     = []
}

# Nginx configuration

variable "server_name" {
  type        = string
  description = "Primary domain nginx will serve (e.g., app.safii.co.ke)"
}

variable "certbot_email" {
  type        = string
  description = "Email for Let's Encrypt notifications — defaults to admin@<server_name>"
  default     = ""
}

variable "proxy_upstreams" {
  description = "Ordered list of location blocks nginx will proxy to upstream backends"
  type = list(object({
    path    = string # nginx location path, e.g., /api/ or /hubs/
    backend = string # upstream URL, e.g., http://10.0.0.5:5000/
  }))
  # Safii default: API + SignalR hub via private VPC IP
  default = [
    { path = "/api/",   backend = "http://127.0.0.1:5000/" },
    { path = "/hubs/",  backend = "http://127.0.0.1:5000/" },
  ]
}

variable "static_root" {
  type        = string
  description = "Filesystem path for static file serving (React PWA build output)"
  default     = "/var/www/html"
}

variable "proxy_read_timeout" {
  type        = number
  description = "Nginx proxy_read_timeout in seconds — increase for long-lived SignalR connections"
  default     = 120
}
