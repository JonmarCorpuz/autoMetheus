#!/bin/bash

# ==== STATIC VARIABLES ==================================================================================
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

INTEGER='^[0-9]+$'
IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

# ==== MAIN BODY =========================================================================================

# Step 1: Create a Prometheus user
echo -e "${YELLOW}[NOTICE]${WHITE} Creating a Prometheus user."
sudo useradd --no-create-home --shell /bin/false prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 2: Create necessary directories
echo -e "${YELLOW}[NOTICE]${WHITE} Creating "
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 3: Download Prometheus
echo -e "${YELLOW}[NOTICE]${WHITE} "
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 4: Extract and move binaries
echo -e "${YELLOW}[NOTICE]${WHITE} "
tar -xvf prometheus-2.52.0.linux-amd64.tar.gz
cd prometheus-2.52.0.linux-amd64

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 5: Set ownership
echo -e "${YELLOW}[NOTICE]${WHITE} "
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /var/lib/prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 6: Create Prometheus systemd service
echo -e "${YELLOW}[NOTICE]${WHITE} Configuring a systemd service for Prometheus"
touch prometheus.service
sudo su -c 'echo """
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
""" > prometheus.service
sudo mv prometheus.service /etc/systemd/system/'
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 7: Start Prometheus
echo -e "${YELLOW}[NOTICE]${WHITE} Starting Prometheus"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} "

# Step 8: Access Prometheur through the web on port 9090
