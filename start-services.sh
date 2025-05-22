#!/usr/bin/env bash
# =========================================================
# Homelab Service Bootstrapper
# Description: Install prerequisites and launch Docker-based
#              homelab services in a consistent, idempotent way
# =========================================================


set -euo pipefail # Enable strict error handling

echo "=== 🚀 Initializing Homelab Services ==="

# --- Helper: install a package if missing ---
ensure_pkg() {
    local pkg=$1 
    if ! command -v "$pkg" &>/dev/null; then
        echo "[*] Installing missing package: $pkg"
        sudo apt-get update -qq #qq 
        sudo apt-get install -y "$pkg"
    fi
}

# Install essentials
ensure_pkg docker
ensure_pkg curl
ensure_pkg jq

# --- Helper: locate and run a script only once ---
run_script_if_needed() {
    local name=$1
    local check_cmd=$2
    local script_name=$3
    local on_missing_msg=$4
    local success_msg=$5

    if eval "$check_cmd"; then
        echo "[+] ${success_msg}"
    else
        echo "[!] ${on_missing_msg}"
        # find the first matching script anywhere
        local script
        script=$(find / -type f -name "$script_name" 2>/dev/null | head -n1 || true)
        [[ -x $script ]] || { echo "[!] ERROR: '$script_name' not found or not executable. Aborting."; exit 1; }
        bash "$script"
        echo "[+] ${success_msg}"
    fi
}

# 1) Ensure nginx config directory exists (or copy it)
run_script_if_needed \
    "nginx-conf" \
    '[ -d /srv/docker/nginx/etc/nginx/conf.d ]' \
    "copy-config.sh" \
    "Directory '/srv/docker/nginx/etc/nginx/conf.d' missing. Copying configs..." \
    "nginx configs in place."

# 2) Ensure Docker network exists
run_script_if_needed \
    "homelab-network" \
    "docker network ls --format '{{.Name}}' | grep -wq homelab-network" \
    "homelab-network.sh" \
    "Docker network 'homelab-network' not found. Creating..." \
    "homelab-network is ready."

# 3) Ensure nginx container is running
run_script_if_needed \
    "nginx-container" \
    "docker ps --format '{{.Names}}' | grep -wq nginx" \
    "start-nginx.sh" \
    "Docker container 'nginx' not running. Starting..." \
    "nginx container is running."

# 4) Deploy each srv-*.sh service script
echo "[*] Searching for service scripts..."
mapfile -t SCRIPTS < <(find / -type f -name "srv-*.sh" 2>/dev/null)
if [ ${#SCRIPTS[@]} -eq 0 ]; then
    echo "[!] ERROR: No service scripts found. Aborting."; exit 1
fi

echo "[+] Found ${#SCRIPTS[@]} service scripts."
for script in "${SCRIPTS[@]}"; do
    chmod +x "$script"
    echo
    echo ">>> Ready to deploy: $(basename "$script")"
    read -r -p "Deploy this service? [y/N]: " ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        if bash "$script"; then
            echo "✅ Deployed: $(basename "$script")"
        else
            echo "❌ Failed: $(basename "$script") (exit $?)"
        fi
    else
        echo "⏭ Skipped: $(basename "$script")"
    fi
done

echo
echo "=== 🎉 Core Services Deployed ==="

# --- Optional post-deploy configurations ---
prompt_and_run() {
    local desc=$1
    local script_name=$2
    local prompt_msg=$3

    read -r -p "$prompt_msg [y/N]: " ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        script=$(find / -type f -name "$script_name" 2>/dev/null | head -n1 || true)
        chmod +x "$script"
        [[ -x $script ]] || { echo "[!] ERROR: '$script_name' not found. Aborting."; exit 1; }
        bash "$script"
        echo "[+] Completed: $desc"
    else
        echo "⏭ Skipped: $desc"
    fi
}

# Pi-hole password config if pihole service was deployed
if printf '%s\n' "${SCRIPTS[@]}" | grep -q pihole; then
    prompt_and_run "Pi-hole password setup" "change-pihole-password.sh" \
        "Set Pi-hole admin password? (ensure container is running)"
fi

# Nginx reverse-proxy config
prompt_and_run "Nginx reverse-proxy generation" "generate_nginx_configs.sh" \
    "Generate Nginx reverse-proxy configs for services?"

# Tailscale remote-access setup
prompt_and_run "Tailscale setup" "tailscale-setup.sh" \
    "Configure Tailscale for remote access?"
    
echo "all your volumes in /srv/docker"
echo "✔️ Homelab Startup Complete - All systems operational"
