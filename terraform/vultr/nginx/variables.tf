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
    { path = "/api/", backend = "http://127.0.0.1:5000/" },
    { path = "/hubs/", backend = "http://127.0.0.1:5000/" },
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

# Host firewall.
#
# On by default here, unlike the generic instance module. This module installs
# nginx and runs certbot itself, so it knows exactly which ports the host needs
# — 22, 80, 443 — and a web server that cannot be reached is not serving. The
# generic module can't make that claim about an unknown workload, so there it
# is opt-in.
variable "ufw_enabled" {
  type        = bool
  description = "Declare the host firewall from this module: 22, 80 and 443, then enable. Set false to inherit whatever the image ships."
  default     = true
}

variable "ssh_allow_from" {
  type        = string
  description = "CIDR permitted to reach port 22, e.g. a bastion subnet. Empty means anywhere. Reached through a bastion over the VPC, this must be the bastion's PRIVATE subnet — its public IP is never the source address."
  default     = ""
}

variable "extra_public_ports" {
  type        = list(string)
  description = "Additional TCP ports to open to 0.0.0.0/0 beyond 80 and 443."
  default     = []
}

variable "disable_password_authentication" {
  type        = bool
  description = <<-EOT
    Turn off SSH password authentication, leaving key auth only.

    Ignored when ssh_key_ids is empty: disabling passwords on a host that has no
    key installed locks it out, and the only way back is the provider's console.
  EOT
  default     = true
}
