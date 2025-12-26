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
    stackscript_id  = var.stackscript_id != 0 ? var.stackscript_id : null
    stackscript_data = length(var.stackscript_data) > 0 ? var.stackscript_data : null
}

# Attach to VPC and subnet if provided
resource "linode_vpc_interface" "this" {
  count      = var.vpc_id != "" && var.subnet_id != "" ? 1 : 0
  linode_id  = linode_instance.this.id
  vpc_id     = var.vpc_id
  subnet_id  = var.subnet_id
}

# attach firewalls if any are provided
resource "linode_firewall_device" "this" {
    entity_id = linode_instance.this.id
    firewall_id = element(var.firewall_ids, count.index)
    count  = length(var.firewall_ids) > 0 ? length(var.firewall_ids) : 0
}