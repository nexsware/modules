resource "linode_instance" "this" {
  label           = var.label
  image           = var.image
  region          = var.region
  type            = var.type
  root_pass       = var.root_pass
  authorized_keys = var.authorized_keys
  tags            = var.tags
  private_ip      = var.private_ip
}