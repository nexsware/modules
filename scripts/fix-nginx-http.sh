#!/bin/bash
# Quick fix to restore HTTP-only nginx configuration for ALL domains

set -e

SERVER_IP="${1:-172.232.114.88}"

echo "Fixing nginx configuration on $SERVER_IP..."

ssh root@$SERVER_IP << 'ENDSSH'
set -e

echo "Finding and fixing broken nginx configs..."

# Fix all configs that reference missing SSL certificates
for conf in /etc/nginx/sites-enabled/*; do
  if [ -f "$conf" ]; then
    if grep -q "/etc/letsencrypt/" "$conf"; then
      DOMAIN=$(basename "$conf")
      echo "Fixing config for: $DOMAIN"

      # Extract server_name from existing config
      SERVER_NAMES=$(grep -oP 'server_name\s+\K[^;]+' "$conf" | head -1 || echo "$DOMAIN www.$DOMAIN")

      # Extract proxy_pass backend (look for localhost:PORT)
      BACKEND=$(grep -oP 'proxy_pass\s+\K[^;]+' "$conf" | head -1 || echo "http://localhost:3000")

      echo "  Domain: $SERVER_NAMES"
      echo "  Backend: $BACKEND"

      # Create HTTP-only config
      cat > "$conf" << EOF
server {
    listen 80;
    server_name $SERVER_NAMES;

    location / {
        proxy_pass $BACKEND;
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
      echo "  ✓ Fixed!"
    fi
  fi
done

# Test and restart nginx
echo "Testing nginx configuration..."
if nginx -t; then
  echo "Configuration valid, restarting nginx..."
  systemctl restart nginx
  echo "✓ Nginx restarted successfully"
else
  echo "✗ Configuration test failed"
  exit 1
fi

ENDSSH

echo "Done! All domains should now be accessible via HTTP"
