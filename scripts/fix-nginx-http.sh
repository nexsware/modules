#!/bin/bash
# Quick fix to restore HTTP-only nginx configuration

set -e

SERVER_IP="${1:-172.232.114.88}"

echo "Fixing nginx configuration on $SERVER_IP..."

ssh root@$SERVER_IP << 'ENDSSH'
set -e

# Create a simple HTTP-only nginx configuration
cat > /etc/nginx/sites-available/nexsware.com << 'EOF'
server {
    listen 80;
    server_name nexsware.com www.nexsware.com;

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

# Enable the site
ln -sf /etc/nginx/sites-available/nexsware.com /etc/nginx/sites-enabled/nexsware.com

# Remove default site if exists
rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
nginx -t && systemctl restart nginx

echo "Nginx configuration fixed and restarted"
ENDSSH

echo "Done! Your site should now be accessible at http://$SERVER_IP or http://nexsware.com"
