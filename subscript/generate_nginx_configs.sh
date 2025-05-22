#!/bin/bash

#create ssl files
KEYS_DIR="/srv/docker/nginx/etc/nginx/conf.d/keys"
mkdir -p "$KEYS_DIR"

if [[ ! -f "$KEYS_DIR/nginx.key" || ! -f "$KEYS_DIR/nginx.crt" ]]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEYS_DIR/nginx.key" \
        -out "$KEYS_DIR/nginx.crt" \
        -subj "/C=XX/ST=Nowhere/L=Nowhere/O=Homelab/CN=*.home.net"
fi


CONF_DIR="/srv/docker/nginx/etc/nginx/conf.d"


nginx_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx)

while true; do
    
echo "Available running Docker containers (name, IP, and ports):"

docker ps --format "{{.Names}}" | while read cname; do
    cip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$cname")
    ports_exposed=$(docker inspect "$cname" --format '{{range $p, $_ := .Config.ExposedPorts}}{{$p}} {{end}}')
    ports_published=$(docker inspect "$cname" --format '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}}->{{(index $conf 0).HostPort}} {{end}}{{end}}')

    printf "%-15s %-15s %-40s %-40s\n" "$cname" "$cip" "$ports_exposed" "$ports_published"
done
    read -p "Enter server name (e.g., myapp): " NAME
    read -p "Enter backend IP: " IP
    read -p "Enter backend port: " PORT
    read -p "Use http or https? (http/https): " PROTOCOL

    CONF_PATH="$CONF_DIR/$NAME.conf"
    if [[ -f "$CONF_PATH" ]]; then
        rm "$CONF_PATH"
        echo "Old config $CONF_PATH deleted."
    fi

    mkdir -p "$CONF_DIR"

    cat > "$CONF_PATH" <<EOF
server {
    listen 443 ssl;
    server_name $NAME.home.net;

    ssl_certificate /etc/nginx/conf.d/keys/nginx.crt;
    ssl_certificate_key /etc/nginx/conf.d/keys/nginx.key;

    location / {
        proxy_pass $PROTOCOL://$IP:$PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    server_name $NAME.home.net;

    return 301 https://\$host\$request_uri;
}
EOF

    echo "✅ Config written to $CONF_PATH"

    read -p "Add another server? (Y/N): " CONT
    [[ "${CONT^^}" != "Y" ]] && break
done
docker restart nginx
echo "Nginx restarted with new configurations."