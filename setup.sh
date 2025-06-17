#!/bin/bash

set -e

INSTALL_DIR="/opt/vaultwarden-selfhost"

echo "Creating directory structure in $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chown "$(whoami)":"$(whoami)" "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "Generating docker-compose.yml..."
cat > docker-compose.yml <<EOL
version: '3'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./vw-data:/data
    networks:
      - vault_net

  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./caddy-data:/data
      - ./caddy-config:/config
    networks:
      - vault_net

networks:
  vault_net:
EOL

echo "Generating Caddyfile..."
cat > Caddyfile <<EOL
vault.lan {
    encode gzip
    reverse_proxy vaultwarden:80
    tls /etc/caddy/certs/root.crt /etc/caddy/certs/root.key
}
EOL

echo "Generating backup.sh..."
cat > backup.sh <<'EOL'
#!/bin/bash

BACKUP_DIR="$(pwd)/backups"
DATA_DIR="$(pwd)/vw-data"
DATE=$(date +%F)
GDRIVE_REMOTE="gdrive:vaultwarden-backups"

mkdir -p "$BACKUP_DIR"
tar -czvf "$BACKUP_DIR/vaultwarden-$DATE.tar.gz" -C "$DATA_DIR" .

rclone copy "$BACKUP_DIR/vaultwarden-$DATE.tar.gz" "$GDRIVE_REMOTE"
rclone ls "$GDRIVE_REMOTE" | sort | head -n -7 | awk '{print $2}' | while read file; do
    rclone delete "$GDRIVE_REMOTE/$file"
done

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -delete
EOL

echo "Generating restore.sh..."
cat > restore.sh <<'EOL'
#!/bin/bash

BACKUP_FILE="$1"
RESTORE_DIR="$(pwd)/vw-data"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup-tar.gz>"
  exit 1
fi

docker compose down
rm -rf "$RESTORE_DIR"/*
mkdir -p "$RESTORE_DIR"
tar -xzvf "$BACKUP_FILE" -C "$RESTORE_DIR"
docker compose up -d
EOL

echo "Generating .gitignore..."
cat > .gitignore <<EOL
backups/
vw-data/
caddy-data/
caddy-config/
*.tar.gz
EOL

echo "Setting permissions..."
chmod +x backup.sh restore.sh

echo "Vaultwarden setup files generated in $INSTALL_DIR"
