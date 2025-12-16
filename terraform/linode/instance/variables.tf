variable "label" {
  type        = string
  description = "The label for the Linode instance"
}

variable "region" {
  type        = string
  description = "The region to deploy the Linode in"
}

variable "image" {
  type        = string
  description = "The image to use for the Linode (e.g., linode/ubuntu22.04)"
}

variable "type" {
  type        = string
  description = "The Linode plan type (e.g., g6-standard-1)"
}

variable "root_pass" {
  type        = string
  description = "The root password for the Linode"
  sensitive   = true
  default     = ""
}

variable "authorized_keys" {
  type        = list(string)
  description = "List of SSH public keys to authorize"
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags to assign to the Linode"
  default     = []
}

variable "private_ip" {
  type        = bool
  description = "Whether to enable private networking"
  default     = false
}
