#!/bin/bash

# ==== STATIC VARIABLES ==================================================================================
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

# ==== MAIN BODY =========================================================================================

# Specify what to add to the Prometheus server's configuration file
touch tmp.yaml
echo -e "  - job_name: node_exporter\n    static_configs:\n      - targets:" >> ./tmp.yaml

while true;
do
  read -p "Enter the IP address for the Linux node that you would like to scrape: " deviceIP

  if [[ $deviceIP =~ $IPv4 ]];
  then
    echo $deviceIP
    echo "        - ${deviceIP}" >> ./tmp.yaml
    echo ""

    read -p "Would you like to add another device? [Y] or [N] " addDevice
    if [[ $addDevice =~ "N" ]];
    then
      echo " " >> ./tmp.yaml
      break
    fi
    echo ""
  else
    echo -e "${RED}[ERROR]${WHITE} $deviceIP is not a valid IPv4 address\n"
  fi
done

# Install the Node Exporter
echo -e "${YELLOW}[WARNING]${WHITE} Installing the Node Exporter\n"
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.9.1.linux-amd64.tar.gz &> /dev/null

# Create a systemd service for the Node Exporter
cd node_exporter-1.9.1.linux-amd64

sudo useradd --no-create-home --shell /bin/false node_exporter &> /dev/null
sudo useradd --no-create-home --shell /bin/false node_exporter &> /dev/null
sudo chown -R node_exporter:node_exporter /opt/node_exporter 
sudo mkdir /opt/node_exporter
sudo mv node_exporter /opt/node_exporter/

sudo su -c 'echo """
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=default.target
""" > /etc/systemd/system/node_exporter.service'

sudo systemctl daemon-reexec &> /dev/null
sudo systemctl daemon-reload &> /dev/null
sudo systemctl enable node_exporter &> /dev/null
sudo systemctl start node_exporter &> /dev/null

echo -e "\n${GREEN}[SUCCESS]${WHITE} The Node Exporter was successfully installed and is configured to automatically startup"

# Cleanup
echo -e "\nPlease add the following to your prometheus configuration file:\n"
cat ../tmp.yaml && echo ""
rm ../tmp.yaml

exit 0

# curl http://localhost:9100/metrics
