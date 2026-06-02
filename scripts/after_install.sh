#!/bin/bash
# Configure Nginx for React SPA
cat > /etc/nginx/conf.d/react-app.conf << 'EOL'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOL

# Remove default config if it exists
if [ -f /etc/nginx/conf.d/default.conf ]; then
  rm -f /etc/nginx/conf.d/default.conf
fi

# Set proper permissions and restart nginx
chmod -R 755 /usr/share/nginx/html
systemctl restart nginx
