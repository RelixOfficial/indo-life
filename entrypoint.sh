#!/bin/bash

# Set warna
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# Setup Neofetch config dari GitHub
mkdir -p /home/container/.config/neofetch
wget -qO /home/container/.config/neofetch/config.conf "https://raw.githubusercontent.com/RelixOfficial/egg-conf/main/config.conf"

# Pastikan ownership yang benar
chown -R container:container /home/container/.config
chmod 755 /home/container/.config/neofetch

clear
neofetch --config /home/container/.config/neofetch/config.conf

# Script Tambahan untuk Menjalankan Server
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Print Node.js Version
echo -e "${GREEN}Node.js Version:${NC} $(node -v)"
sleep 1


# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')


# Jalankan Server
echo -e "${YELLOW}Starting the server...${NC}"
curl -s -O https://raw.githubusercontent.com/RelixOfficial/egg-conf/main/run.js
curl -s -O https://raw.githubusercontent.com/RelixOfficial/egg-conf/main/README-PANEL
eval ${MODIFIED_STARTUP}

# Jalankan perintah bawaan container
exec "$@"

