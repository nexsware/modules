#!/bin/bash
# <UDF name="server_name" label="Domain name for nginx server_name (e.g. nexsware.com)" default="example.com">

# Install nginx and certbot
apt-get update
apt-get install -y nginx certbot python3-certbot-nginx

# Write nginx config
cat > /etc/nginx/sites-available/$SERVER_NAME <<EOF
server {
    listen 80;
    server_name $SERVER_NAME www.$SERVER_NAME;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl default_server;
    server_name $SERVER_NAME www.$SERVER_NAME;
    ssl_certificate /etc/letsencrypt/live/$SERVER_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$SERVER_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    location / {
        proxy_pass http://localhost:3000;
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

ln -sf /etc/nginx/sites-available/$SERVER_NAME /etc/nginx/sites-enabled/$SERVER_NAME
systemctl reload nginx

# Obtain SSL certificate (will fail if DNS is not set up yet)
certbot --nginx -d $SERVER_NAME -d www.$SERVER_NAME --non-interactive --agree-tos -m admin@$SERVER_NAME || true
systemctl reload nginx
