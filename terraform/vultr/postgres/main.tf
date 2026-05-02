provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_database" "this" {
  database_engine         = "pg"
  database_engine_version = var.engine_version
  region                  = var.region
  plan                    = var.plan
  label                   = var.label
  cluster_time_zone       = var.cluster_time_zone
  maintenance_dow         = var.maintenance_dow
  maintenance_time        = var.maintenance_time
}

provider "postgresql" {
  host            = vultr_database.this.host
  port            = vultr_database.this.port
  username        = vultr_database.this.user
  password        = vultr_database.this.password
  database        = vultr_database.this.dbname
  sslmode         = "require"
  superuser       = false
  connect_timeout = 15
}

resource "postgresql_database" "databases" {
  for_each = var.create_resources ? toset(var.databases) : toset([])

  name              = each.value
  owner             = vultr_database.this.user
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_role" "users" {
  for_each = var.create_resources ? var.database_users : {}

  name     = each.key
  login    = true
  password = each.value.password
  roles    = each.value.roles
}

resource "postgresql_grant" "user_database_grants" {
  for_each = {
    for pair in setproduct(keys(var.database_users), var.databases) :
    "${pair[0]}-${pair[1]}" => {
      user     = pair[0]
      database = pair[1]
    }
    if var.create_resources
  }

  database    = each.value.database
  role        = each.value.user
  object_type = "database"
  privileges  = ["CONNECT", "CREATE"]

  depends_on = [
    postgresql_database.databases,
    postgresql_role.users,
  ]
}
