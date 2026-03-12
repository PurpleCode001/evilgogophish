#!/bin/bash

# =============================================
# EvilgoGoPhish v1.1 - Environment Preparator
# Author: PSDT - PurpleCode
# Description: Prepares the system for Evilginx + Gophish
# =============================================

# Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

echo "${blue}========================================${reset}"
echo "${green}EvilgoGoPhish v1.1 - System Preparation${reset}"
echo "${blue}========================================${reset}"

# 1.- Install required packages
echo "${yellow}[1/5] Installing required packages...${reset}"
sudo apt update
sudo apt install -y \
    git \
    build-essential \
    wget \
    curl \
    net-tools \
    sqlite3 \
    dnsutils \
    ufw \
    fail2ban \
    golang \
    certbot

# 2.- Stop conflicting services
echo "${yellow}[2/5] Stopping conflicting services...${reset}"

# Show current port usage
echo "Current port usage:"
sudo netstat -tulpn | grep -E ':80|:443|:53' || echo "Ports 80, 443, 53 are free"

# Stop Apache
if systemctl is-active --quiet apache2; then
    sudo systemctl stop apache2
    sudo systemctl disable apache2
    echo "Apache stopped and disabled"
fi

# Stop Nginx
if systemctl is-active --quiet nginx; then
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    echo "Nginx stopped and disabled"
fi

# Stop systemd-resolved (uses port 53)
if systemctl is-active --quiet systemd-resolved; then
    sudo systemctl stop systemd-resolved
    sudo systemctl disable systemd-resolved
    echo "systemd-resolved stopped and disabled"
fi

# Configure DNS
echo "Configuring DNS..."
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf  # Make it immutable
echo "DNS configured (Google DNS)"

# Verify ports are free
echo "Verifying ports are free:"
sudo netstat -tulpn | grep -E ':53|:80|:443' || echo "✓ Ports 53, 80, 443 are free"

# 3.- Configure Firewall
echo "${yellow}[3/5] Configuring firewall...${reset}"

# Reset UFW to default
sudo ufw --force reset

# Configure basic rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow necessary ports
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 8080/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw allow 53/tcp comment 'DNS TCP'
sudo ufw allow 53/udp comment 'DNS UDP'
sudo ufw allow 8443/tcp comment 'GoPhish Panel'

# Enable firewall
echo "y" | sudo ufw enable

# Show firewall status
echo "${yellow}[4/5] Firewall status:${reset}"
sudo ufw status verbose

# 4.- Create directory structure
echo "${yellow}[5/5] Creating directory structure...${reset}"
sudo mkdir -p /opt/evilgogophish
sudo mkdir -p /var/log/evilgogophish
sudo mkdir -p /opt/evilginx

# 5.- Summary
echo "${blue}========================================${reset}"
echo "${green}✅ System preparation completed!${reset}"
echo "${blue}========================================${reset}"
"
echo "🌐 Open ports:"
sudo ufw status | grep -E '22|80|443|53|8443' | while read line; do echo "  $line"; done
echo ""
echo "📁 Directories created:"
echo "  /opt/evilgogophish/ - Main installation"
echo "  /var/log/evilgogophish/ - Log files"
echo "  /opt/evilginx/ - For Evilginx (optional)"
echo ""
echo "${blue}========================================${reset}"
echo ""
echo "📌 Next steps:"
echo "  1. Run ./evilgogophish.sh -h "
echo ""
