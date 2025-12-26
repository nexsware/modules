provider "linode" {
  token = var.linode_token
}


resource "linode_instance" "this" {
  label           = var.label
  image           = var.image
  region          = var.region
  type            = var.type
  root_pass       = var.root_pass
  authorized_keys = var.authorized_keys
  tags            = var.tags
  private_ip      = var.private_ip
  # Set your StackScript ID here (replace with the ID from Linode Cloud Manager)
  stackscript_id  = var.stackscript_id != 0 ? var.stackscript_id : null
  # Pass StackScript variables (e.g., server_name) as a map
  stackscript_data = {
    server_name = var.server_name
  }


  # Optionally create a public interface
  dynamic "interface" {
    for_each = var.public_interface ? [1] : []
    content {
      purpose = "public"
    }
  }

  # Optionally create a VPC interface if vpc_id and subnet_id are provided
  dynamic "interface" {
    for_each = var.vpc_id != "" && var.subnet_id != "" ? [1] : []
    content {
      purpose   = "vpc"
      subnet_id = var.subnet_id != "" ? tonumber(var.subnet_id) : null
      # Optionally set a static VPC IP if provided (not implemented here)
    }
  }
}


# attach firewalls if any are provided
resource "linode_firewall_device" "this" {
    entity_id = linode_instance.this.id
    firewall_id = element(var.firewall_ids, count.index)
    count  = length(var.firewall_ids) > 0 ? length(var.firewall_ids) : 0
}