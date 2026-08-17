
#!/bin/bash
# <UDF name="install_nginx" label="Whether to install and configure nginx" default="true">
# <UDF name="domains_containers" label="JSON array of domain-to-container mappings" default='[{"domain":"example.com","container":"localhost:3000"}]'>
# <UDF name="server_name" label="Domain name for nginx server_name" default="">

# Check if nginx installation is requested
INSTALL_NGINX=${INSTALL_NGINX:-$install_nginx}
if [ "$INSTALL_NGINX" != "true" ]; then
    echo "Nginx installation skipped (install_nginx=false)"
    echo "This instance is configured for internal use only"
    exit 0
fi

# Install dependencies
apt-get update
apt-get install -y nginx certbot python3-certbot-nginx jq

# Host firewall, opened before certbot runs below.
#
# The HTTP-01 challenge is an inbound request to port 80 from Let's Encrypt's
# validators, so a host firewall that has not opened 80 yet fails issuance with
# "Timeout during connect" — which reads like a DNS or nginx fault and is
# neither. Ubuntu images arrive with ufw active and a lone "allow 22 from
# anywhere" rule that appears in no Terraform, so the ports this script's own
# nginx needs have to be opened by this script.
#
# 80 stays open afterwards: certbot's renewal timer re-runs the same challenge,
# and closing 80 after the first certificate lands leaves a working site that
# quietly stops renewing about sixty days later.
if command -v ufw >/dev/null 2>&1; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

# Parse the JSON array
DOMAINS_CONTAINERS=${DOMAINS_CONTAINERS:-$domains_containers}
if [ -z "$DOMAINS_CONTAINERS" ]; then
    echo "No domain-to-container mappings provided. Exiting."
    exit 1
fi

COUNT=$(echo "$DOMAINS_CONTAINERS" | jq length)
for i in $(seq 0 $((COUNT-1))); do
    DOMAIN=$(echo "$DOMAINS_CONTAINERS" | jq -r ".[$i].domain")
    CONTAINER=$(echo "$DOMAINS_CONTAINERS" | jq -r ".[$i].container")

    # Create HTTP-only configuration first
    cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        location / {
                proxy_pass http://$CONTAINER;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_cache_bypass \$http_upgrade;
        }
}
EOF

    ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
done

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test and start nginx with HTTP-only config
nginx -t && systemctl restart nginx

# Now try to obtain SSL certificates for each domain
for i in $(seq 0 $((COUNT-1))); do
    DOMAIN=$(echo "$DOMAINS_CONTAINERS" | jq -r ".[$i].domain")

    echo "Attempting to obtain SSL certificate for $DOMAIN..."
    # Certbot will automatically modify the nginx config to add SSL
    if certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect; then
        echo "SSL certificate obtained successfully for $DOMAIN"
    else
        echo "Failed to obtain SSL certificate for $DOMAIN - site will remain HTTP-only"
    fi
done

# Reload nginx to apply any SSL configurations
systemctl reload nginx
