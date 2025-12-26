
#!/bin/bash
# <UDF name="domains_containers" label="JSON array of domain-to-container mappings" default='[{"domain":"example.com","container":"localhost:3000"}]'>

# Install dependencies
apt-get update
apt-get install -y nginx certbot python3-certbot-nginx jq

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

    cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        return 301 https://$host$request_uri;
}
server {
        listen 443 ssl;
        server_name $DOMAIN www.$DOMAIN;
        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
        location / {
                proxy_pass http://$CONTAINER;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_cache_bypass $http_upgrade;
        }
}
EOF

    ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

    # Obtain SSL certificate (will fail if DNS is not set up yet)
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN || true
done

systemctl reload nginx
