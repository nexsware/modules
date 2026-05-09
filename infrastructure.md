# Infrastructure Reference

This repository contains reusable Terraform modules and GitHub Actions workflows for deploying infrastructure on **Vultr** and **Linode**.

---

## Resource Creation Order (Vultr)

Dependencies determine the order. Create resources in this sequence:

```
1. VPC                    ── no dependencies
   Firewall               ── no dependencies (run in parallel with VPC)
2. Postgres (managed)     ── needs VPC (optional, for private networking)
   Postgres (self-hosted) ── needs VPC + Firewall
   Object Storage         ── no dependencies (run in parallel)
   Instance               ── needs VPC + Firewall
3. Nginx                  ── needs VPC + Firewall
```

**Practical sequence:**

| Step | Resource | Depends on | Notes |
|------|----------|------------|-------|
| 1 | VPC | — | Provides private network for all instances |
| 1 | Firewall | — | Can run in parallel with VPC |
| 2 | Postgres (managed) | VPC (optional) | Vultr-managed cluster; attach VPC for private access |
| 2 | Postgres (self-hosted) | VPC + Firewall | Instance with Postgres installed via cloud-init |
| 2 | Object Storage | — | Fully independent; run in parallel |
| 2 | Instance | VPC + Firewall | API servers, Docker hosts |
| 3 | Nginx | VPC + Firewall | Pass `vpc_id` → `vpc_ids`, `firewall_id` → `firewall_group_id` |

## Managed vs Self-Hosted PostgreSQL

| | Managed (`vultr/postgres`) | Self-Hosted (`vultr/postgres-self-hosted`) |
|---|---|---|
| Setup | Zero config | Installed via cloud-init on first boot |
| Maintenance | Vultr handles updates, backups, failover | You handle everything |
| Cost | Higher (check vultr.com/databases) | Cheaper — instance cost only |
| Superuser access | No | Yes (`postgres` user) |
| Extensions | Limited | Any extension you install |
| Backups | Automated by Vultr | Manual / your responsibility |
| Use when | Production, low ops overhead | Dev/test, cost-sensitive, need full control |

## VPC IP Block Assignments

Vultr requires `ip_block` to be specified — it is not auto-assigned. Use these fixed ranges to avoid conflicts:

| Environment | `ip_block` | `prefix_length` | CIDR |
|-------------|-----------|----------------|------|
| test | `10.0.0.0` | `24` | `10.0.0.0/24` |
| prod | `10.1.0.0` | `24` | `10.1.0.0/24` |

Each `/24` provides 254 usable addresses. Reserve `10.2.0.0/24` and above for future environments.

## VPC Subnet Layout

Each `/24` VPC is divided into four `/26` logical subnets. Vultr VPC is a flat Layer 2 network — subnet boundaries are enforced by firewall rules, not the network itself.

| Subnet | Range | Purpose |
| --- | --- | --- |
| `10.0.0.0/26` | `10.0.0.1` – `10.0.0.62` | Nginx/UI (public 80/443) + API servers |
| `10.0.0.64/26` | `10.0.0.65` – `10.0.0.126` | Databases |
| `10.0.0.128/26` | `10.0.0.129` – `10.0.0.190` | Internal / bastion |
| `10.0.0.192/26` | `10.0.0.193` – `10.0.0.254` | Reserved / future use |

**Cross-subnet routing:** Although the VPC is a flat Layer 2 network, instances do not automatically route traffic to other subnets through the VPC interface — the OS only knows about its own subnet by default. The `instance` and `postgres-self-hosted` cloud-init scripts handle this: on first boot they configure a static private IP via netplan and add explicit routes for the relevant peer subnets via the VPC interface. Passing `db_subnet` to the instance module adds a route to the database subnet; `bastion_subnet` and `app_subnet` on the postgres module add routes back to those subnets.

**Firewall rules that follow from this layout:**

- **Nginx / UI edge** (`firewall_type: web`, `enable_ssh: false`) — ports 80/443 from `0.0.0.0/0`. No SSH — the only public-facing server; managed via Vultr console if needed.
- **Bastion host** (`firewall_type: custom`, `enable_ssh: true`) — SSH from `0.0.0.0/0` (or restrict to known IPs via `allow_ssh_from`). The sole SSH entry point into the VPC.
- **API servers** (`firewall_type: api`, `enable_ssh: true`, `allow_ssh_from: 10.0.0.128/26`) — app port (default `5000`) from `10.0.0.0/26` only. No public access.
- **Database servers** (`firewall_type: database`, `enable_ssh: true`, `allow_ssh_from: 10.0.0.128/26`) — port 5432 from `10.0.0.0/26` (app servers) **and** `10.0.0.128/26` (bastion, for management and SSH tunnels). No public access.

For the test environment, replace the first octet pair: `10.0.x.x` → `10.1.x.x`.

---

## Vultr Terraform Modules

All modules live under `terraform/vultr/` and require a `VULTR_API_KEY` secret.

### VPC (`terraform/vultr/vpc`)

Creates a Vultr VPC 2.0 for private networking between instances.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `region` | yes | — | Region slug (e.g., `jnb`) |
| `description` | no | `""` | Human-readable label |
| `ip_block` | yes | — | IPv4 network address (see VPC IP Block Assignments above) |
| `prefix_length` | no | `24` | Subnet prefix length |

**Outputs:** `id`, `region`, `ip_block`, `prefix_length`, `description`

---

### Firewall (`terraform/vultr/firewall`)

Creates a Vultr firewall group with inbound rules. Each rule targets a single CIDR.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `description` | no | `"firewall"` | Firewall group description |
| `inbound_rules` | no | `[]` | List of `{label, protocol, network, port, ip_type}` |

**Outputs:** `id`, `description`

---

### PostgreSQL (`terraform/vultr/postgres`)

Creates a Vultr managed PostgreSQL cluster. Uses a two-phase apply: first creates the cluster, then (once the runner IP is trusted) creates databases and users via the `postgresql` provider.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `label` | yes | — | Cluster label |
| `region` | yes | — | Region slug |
| `plan` | yes | — | Plan slug (e.g., `vultr-dbaas-startup-cc-1-55-2`) |
| `engine_version` | no | `"16"` | PostgreSQL major version |
| `cluster_time_zone` | no | `Africa/Nairobi` | IANA time zone |
| `maintenance_dow` | no | `sunday` | Maintenance day of week |
| `maintenance_time` | no | `22:00` | Maintenance time (UTC, HH:MM) |
| `databases` | no | `[]` | Extra databases to create |
| `database_users` | no | `{}` | Map of `{username: {password, roles}}` |
| `create_resources` | no | `true` | Set `false` on first apply; `true` on second |

**Outputs:** `id`, `host`, `port`, `user`, `password` *(sensitive)*, `dbname`, `status`, `connection_string` *(sensitive)*

---

### Nginx (`terraform/vultr/nginx`)

Creates a Vultr compute instance pre-configured with nginx as a reverse proxy via cloud-init. SSL is provisioned via certbot on first boot.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `region` | yes | — | Region slug |
| `os_id` | yes | — | OS ID (e.g., `2284` for Ubuntu 24.04 LTS) |
| `label` | yes | — | Instance label |
| `server_name` | yes | — | Primary domain (e.g., `app.example.com`) |
| `plan` | no | `vhp-2c-4gb-intel` | Plan slug |
| `hostname` | no | `""` | Defaults to `label` |
| `ssh_key_ids` | no | `[]` | Vultr SSH key IDs to authorize |
| `tags` | no | `[]` | Instance tags |
| `enable_ipv6` | no | `false` | Enable IPv6 |
| `firewall_group_id` | no | `""` | Firewall group to attach |
| `vpc_ids` | no | `[]` | VPC 2.0 IDs for private networking |
| `certbot_email` | no | `""` | Let's Encrypt email (defaults to `admin@<server_name>`) |
| `proxy_upstreams` | no | `[{/api/ → 127.0.0.1:5000}, {/hubs/ → 127.0.0.1:5000}]` | Ordered list of `{path, backend}` proxy rules |
| `static_root` | no | `/var/www/html` | Path for static file serving |
| `proxy_read_timeout` | no | `120` | nginx proxy_read_timeout in seconds |

**Outputs:** `id`, `ip_address`, `label`, `region`, `plan`, `status`, `server_name`

---

### Instance (`terraform/vultr/instance`)

General-purpose compute instance. Use this for API servers, Docker hosts, or any workload that doesn't need the nginx-specific cloud-init setup. For nginx reverse proxies use the `nginx` module instead.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `region` | yes | — | Region slug |
| `os_id` | yes | — | OS ID (e.g., `2284` for Ubuntu 24.04 LTS) |
| `label` | yes | — | Instance label |
| `plan` | no | `vhp-2c-4gb-intel` | Plan slug |
| `hostname` | no | `""` | Defaults to `label` |
| `ssh_key_ids` | no | `[]` | Vultr SSH key IDs to authorize |
| `tags` | no | `[]` | Instance tags |
| `enable_ipv6` | no | `false` | Enable IPv6 |
| `firewall_group_id` | no | `""` | Firewall group to attach |
| `vpc_ids` | no | `[]` | VPC 2.0 IDs for private networking |
| `private_ip` | no | `""` | Static private IP for the VPC interface (e.g., `10.0.0.129`). Leave empty for Vultr auto-assigned IP. |
| `instance_subnet` | no | `""` | CIDR of the subnet this instance is placed in (e.g., `10.0.0.128/26`). Required when `private_ip` is set. |
| `db_subnet` | no | `""` | CIDR of the database subnet — a static route is added via the VPC interface so this instance can reach the database. Leave empty to skip. |
| `user_data` | no | `""` | Cloud-init user data (raw string) |

**Outputs:** `id`, `ip_address`, `internal_ip`, `label`, `region`, `plan`, `status`, `os_id`

---

### PostgreSQL Self-Hosted (`terraform/vultr/postgres-self-hosted`)

Provisions a compute instance and installs PostgreSQL via cloud-init. No separate Terraform provider needed — databases and users are created by the boot script. Use when you want full superuser control or lower cost vs managed.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `region` | yes | — | Region slug |
| `os_id` | yes | — | OS ID (e.g., `2284` for Ubuntu 24.04 LTS) |
| `label` | yes | — | Instance label |
| `postgres_password` | yes | — | Password for the `postgres` superuser *(sensitive)* |
| `plan` | no | `vc2-2c-4gb` | Plan slug |
| `hostname` | no | `""` | Defaults to `label` |
| `postgres_version` | no | `16` | PostgreSQL major version |
| `port` | no | `5432` | Port PostgreSQL listens on |
| `listen_address` | no | `*` | PostgreSQL `listen_addresses` setting |
| `databases` | no | `[]` | Databases to create on first boot |
| `database_users` | no | `{}` | Map of `{username: {password, roles}}` *(sensitive)* |
| `ssh_key_ids` | no | `[]` | Vultr SSH key IDs to authorize |
| `firewall_group_id` | no | `""` | Firewall group to attach |
| `vpc_ids` | no | `[]` | VPC 2.0 IDs for private networking |
| `private_ip` | no | `""` | Static private IP for the VPC interface (e.g., `10.0.0.65`). Leave empty for Vultr auto-assigned IP. |
| `db_subnet` | no | `10.0.0.64/26` | CIDR of the subnet this database instance is placed in — used to derive the netmask for the static IP assignment. |
| `bastion_subnet` | no | `10.0.0.128/26` | CIDR of the bastion subnet — a static route and UFW allow rule for port 5432 are added for this subnet. |
| `app_subnet` | no | `10.0.0.0/26` | CIDR of the app subnet — a static route and UFW allow rule for port 5432 are added for this subnet. |
| `tags` | no | `[]` | Instance tags |

Connections from `10.0.0.0/8` (all VPC ranges) and `127.0.0.1` are allowed by default via `pg_hba.conf`.

**Outputs:** `id`, `ip_address`, `internal_ip`, `label`, `region`, `plan`, `status`, `port`

---

### Object Storage (`terraform/vultr/object-storage`)

Creates a Vultr S3-compatible object storage instance.

**Variables**

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `vultr_api_key` | yes | — | Vultr API key |
| `cluster_id` | yes | — | Storage cluster ID for target region |
| `label` | yes | — | Instance label |

> Find your cluster ID: `curl -H "Authorization: Bearer <api_key>" https://api.vultr.com/v2/object-storage/clusters`

**Outputs:** `id`, `s3_hostname`, `s3_access_key` *(sensitive)*, `s3_secret_key` *(sensitive)*, `label`

---

## Vultr GitHub Actions Workflows

All workflows are reusable (`workflow_call`) and require a `VULTR_API_KEY` secret. Production deploys are gated to `refs/heads/main`.

### `deploy-vultr-vpc.yml`

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `region` | yes | — | Vultr region slug |
| `description` | no | `""` | VPC label |
| `ip_block` | no | `10.0.0.0` | Network address |
| `prefix_length` | no | `24` | Subnet prefix |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/vpc`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/vpc` | Terraform directory |

**Outputs:** `vpc_id`, `ip_block`, `prefix_length`

---

### `deploy-vultr-firewall.yml`

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `description` | yes | — | Firewall group description |
| `firewall_type` | no | `web` | `web` (80,443 public + SSH), `api` (app port from app subnet + SSH), `database` (5432 from app subnet + SSH), `custom` (SSH only) |
| `allow_ssh_from` | no | `""` | Comma-separated CIDRs for SSH (empty = `0.0.0.0/0`) |
| `app_subnet` | no | `10.0.0.0/26` | Subnet allowed to reach `api` and `database` ports |
| `app_port` | no | `5000` | Port the API server listens on (used with `firewall_type: api`) |
| `environment` | no | `production` | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/firewall`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/firewall` | Terraform directory |

**Outputs:** `firewall_id`

---

### `deploy-vultr-postgres.yml`

Two-phase apply: creates the cluster first, whitelists the runner IP via the Vultr API, then creates databases and users, then removes the runner IP.

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `region` | yes | — | Vultr region slug |
| `plan` | yes | — | Database plan slug |
| `label` | yes | — | Cluster label |
| `engine_version` | no | `16` | PostgreSQL major version |
| `environment` | yes | — | GitHub environment |
| `cluster_time_zone` | no | `Africa/Nairobi` | IANA time zone |
| `maintenance_dow` | no | `sunday` | Maintenance day |
| `maintenance_time` | no | `22:00` | Maintenance time (UTC) |
| `databases` | no | `""` | Comma-separated extra databases |
| `service_account_username` | no | `srv_account` | Service account username |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/postgres`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/postgres` | Terraform directory |

**Secrets:** `VULTR_API_KEY` (required), `SERVICE_ACCOUNT`, `SERVICE_ACCOUNT_PASSWORD`

**Outputs:** `database_id`, `database_host`, `database_port`, `database_user`, `connection_string`

---

### `deploy-vultr-nginx.yml`

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `region` | yes | — | Vultr region slug |
| `os_id` | yes | — | OS ID |
| `label` | yes | — | Instance label |
| `server_name` | yes | — | Primary domain |
| `plan` | no | `vhp-2c-4gb-intel` | Plan slug |
| `certbot_email` | no | `""` | Let's Encrypt email |
| `firewall_group_id` | no | `""` | Firewall group ID |
| `vpc_ids` | no | `""` | Comma-separated VPC 2.0 IDs |
| `ssh_key_ids` | no | `""` | Comma-separated Vultr SSH key IDs |
| `proxy_upstreams` | no | `/api/` + `/hubs/` → `127.0.0.1:5000` | JSON array of `{path, backend}` |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/nginx`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/nginx` | Terraform directory |

**Outputs:** `instance_id`, `ip_address`

---

### `deploy-vultr-instance.yml`

General-purpose instance — API servers, Docker hosts, etc. Use `deploy-vultr-nginx.yml` instead when you need a pre-configured nginx reverse proxy.

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `region` | yes | — | Vultr region slug |
| `os_id` | yes | — | OS ID |
| `label` | yes | — | Instance label |
| `plan` | no | `vhp-2c-4gb-intel` | Plan slug |
| `hostname` | no | `""` | Defaults to label |
| `firewall_group_id` | no | `""` | Firewall group ID |
| `vpc_ids` | no | `""` | Comma-separated VPC 2.0 IDs |
| `ssh_key_ids` | no | `""` | Comma-separated Vultr SSH key IDs |
| `private_ip` | no | `""` | Static private IP for the VPC interface (e.g., `10.0.0.129`). Leave empty for Vultr auto-assigned IP. |
| `instance_subnet` | no | `""` | CIDR of the subnet this instance is placed in (e.g., `10.0.0.128/26`). Required when `private_ip` is set. |
| `db_subnet` | no | `""` | CIDR of the database subnet — a static route is added via the VPC interface. Leave empty to skip. |
| `user_data` | no | `""` | Cloud-init user data (raw string) |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/bastion-vps`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/instance` | Terraform directory |

**Outputs:** `instance_id`, `ip_address`, `internal_ip`

---

### `deploy-vultr-postgres-self-hosted.yml`

Provisions a compute instance with PostgreSQL installed via cloud-init. Waits for both SSH and the Postgres port to be reachable before completing.

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `region` | yes | — | Vultr region slug |
| `os_id` | yes | — | OS ID |
| `label` | yes | — | Instance label |
| `plan` | no | `vc2-2c-4gb` | Plan slug |
| `hostname` | no | `""` | Defaults to label |
| `postgres_version` | no | `16` | PostgreSQL major version |
| `port` | no | `5432` | Port PostgreSQL listens on |
| `listen_address` | no | `*` | `listen_addresses` setting |
| `private_ip` | no | `""` | Static private IP for the VPC interface (e.g., `10.0.0.65`). Leave empty for Vultr auto-assigned IP. |
| `db_subnet` | no | `10.0.0.64/26` | CIDR of the subnet this database instance is placed in. |
| `bastion_subnet` | no | `10.0.0.128/26` | Bastion subnet — routes and UFW rules for port 5432 are added for this subnet. |
| `app_subnet` | no | `10.0.0.0/26` | App subnet — routes and UFW rules for port 5432 are added for this subnet. |
| `databases` | no | `""` | Comma-separated databases to create |
| `service_account_username` | no | `srv_account` | Service account username |
| `firewall_group_id` | no | `""` | Firewall group ID |
| `vpc_ids` | no | `""` | Comma-separated VPC 2.0 IDs |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/postgres-db`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/postgres-self-hosted` | Terraform directory |

**Secrets:** `VULTR_API_KEY` (required), `POSTGRES_PASSWORD` (required), `BASTION_SSH_KEY_ID` (optional — authorizes the bastion to SSH into the database instance), `SERVICE_ACCOUNT`, `SERVICE_ACCOUNT_PASSWORD`

**Outputs:** `instance_id`, `ip_address`, `internal_ip`, `port`

---

### `deploy-vultr-object-storage.yml`

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `cluster_id` | yes | — | Storage cluster ID |
| `label` | yes | — | Storage instance label |
| `environment` | yes | — | GitHub environment |
| `state_key` | yes | — | S3 state key for this resource (e.g., `test/object-storage`) |
| `state_bucket` | no | `nexsware-terraform-state` | Vultr Object Storage bucket name for Terraform state |
| `terraform_dir` | no | `modules/terraform/vultr/object-storage` | Terraform directory |

**Outputs:** `storage_id`, `s3_hostname`, `s3_access_key`, `s3_secret_key`

---

## Linode Terraform Modules

Modules live under `terraform/linode/` and require a `LINODE_TOKEN` secret.

| Module | Path | Purpose |
|--------|------|---------|
| DNS | `terraform/linode/dns` | Linode DNS records |
| Firewall | `terraform/linode/firewall` | Cloud firewall groups and rules |
| Instance | `terraform/linode/instance` | Compute instances with nginx/SSL via StackScript |
| PostgreSQL | `terraform/linode/postgres` | Linode managed PostgreSQL clusters |

---

## Linode GitHub Actions Workflows

| Workflow | Purpose |
|----------|---------|
| `deploy-firewall.yml` | Reusable Linode firewall provisioning |
| `deploy-postgres.yml` | Reusable Linode managed PostgreSQL provisioning |
| `deploy-instance.yml` | Reusable Linode instance provisioning |
| `deploy-instance-with-postgres.yml` | Instance + Postgres combo |
| `deploy-database-instance.yml` | Database-tier instance provisioning |
| `deploy-dns.yml` | DNS record management |
| `deploy-dotnet-api.yml` | .NET API deployment |
| `deploy-nexsware-ui.yml` | Frontend UI deployment |
| `deploy-postgres-docker.yml` | PostgreSQL via Docker |
| `deploy-install-flyway.yml` | Flyway migration tool setup |
| `deploy-run-migrations.yml` | Run database migrations |
| `install-ssl.yml` | SSL certificate installation |
| `install-nginx-ssl.yml` | Nginx + SSL combined setup |

---

## Reusable GitHub Actions

| Action | Path | Purpose |
|--------|------|---------|
| Build & push Docker image | `.github/actions/build-push-docker` | Build and push to GHCR |
| Deploy Docker container | `.github/actions/deploy-docker-container` | Pull and run container on instance |
| Install SSL cert | `.github/actions/install-ssl-cert` | Certbot SSL via SSH |
| Run tests | `.github/actions/run-tests` | Execute test suite |
| Setup Node app | `.github/actions/setup-node-app` | Node.js app setup |
