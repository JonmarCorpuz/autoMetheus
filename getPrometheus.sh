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
echo -e "${YELLOW}[INFO]${WHITE} Creating a Prometheus user to run Prometheus"
if ! id prometheus;
then
  sudo useradd --no-create-home --shell /bin/false prometheus
  echo -e "${GREEN}[SUCCESS]${WHITE} the prometheus user was created successfully\n"
else
  echo -e "${YELLOW}[ERROR]${WHITE} The prometheus user already exists on this host\n"
fi

# Step 2: Create necessary directories
echo -e "${YELLOW}[NOTICE]${WHITE} Creating directories to be used by Prometheus"
sudo mkdir /etc/prometheus              # Stores the configuration files
sudo mkdir /var/lib/prometheus          # Stores its time series database (TSDB) files
echo -e "${GREEN}[SUCCESS]${WHITE} The /etc/prometheus and /var/lib/prometheus directories were created successfully\n"

# Step 3: Download Prometheus
echo -e "${YELLOW}[NOTICE]${WHITE} Downloading Prometheus (v.2.52)"
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz

tar -xvf prometheus-2.52.0.linux-amd64.tar.gz &> /dev/null
cd prometheus-2.52.0.linux-amd64

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus

# Step 4: Set ownership
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /var/lib/prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} Prometheus (v.2.52) was successfully downloaded"

# Step 5: Create Prometheus systemd service
echo -e "${YELLOW}[NOTICE]${WHITE} Configuring a systemd service for the Prometheus server"
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
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yaml --storage.tsdb.path=/var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
""" > prometheus.service'

sudo mv prometheus.service /etc/systemd/system/

sudo su -c 'echo """
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

scrape_configs:
  - job_name: "prometheus"

    static_configs:
      - targets: ["localhost:9090"]
""" > /etc/prometheus/prometheus.yaml'

# Step 7: Start Prometheus
sudo systemctl daemon-reexec 
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
echo -e "${GREEN}[SUCCESS]${WHITE} Prometheus was successfully installed, enabled, and currently running on port 9090 of this host\n"
