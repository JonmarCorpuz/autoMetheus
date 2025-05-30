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
echo -e "  - job_name: snmp\n    static_configs:\n      - targets:" >> ./tmp.yaml

while true;
do
  read -p "Enter the IP address for the networking device that you would like to scrape: " deviceIP

  if [[ $deviceIP =~ $IPv4 ]];
  then
    echo "        - $deviceIP" >> ./tmp.yaml
    echo ""

    read -p "Would you like to add another device? [Y] or [N] " addDevice
    if [[ $addDevice =~ "N" ]];
    then
      break
    fi
    echo ""
  else
    echo -e "${RED}[ERROR]${WHITE} $deviceIP is not a valid IPv4 address\n"
  fi
done

echo """
    metrics_path: /snmp
    params:
      auth: [public_v2]
      module: [if_mib]               # matches the module name in snmp.yml
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9116  # SNMP Exporter address

  # Global exporter-level metrics
  - job_name: snmp_exporter
    static_configs:
      - targets: [localhost:9116]
""" >> ./tmp.yaml

# Install the SNMP Exporter
echo -e "${YELLOW}[WARNING]${WHITE} Installing the SNMP Exporter\n"
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-amd64.tar.gz
tar xzvf snmp_exporter-0.29.0.linux-amd64.tar.gz &> /dev/null
cd snmp_exporter-0.29.0.linux-amd64

# Create the required snmp.yaml file
echo """
auths:
  public_v2:
    community: public
    version: 2
modules:
  if_mib:
    walk:
    - 1.3.6.1.4.1.318.1.1.1.12
    - 1.3.6.1.4.1.318.1.1.1.2
""" > snmp.yaml

# Create a systemd service for the SNMP Exporter
echo -e "${YELLOW}[INFO]${WHITE} Running the SNMP Exporter on the localhost and creating a service to have it automatically "

sudo useradd --no-create-home --shell /bin/false snmp_exporter &> /devnull
sudo useradd --no-create-home --shell /bin/false snmp_exporter &> /devnull
sudo chown -R snmp_exporter:node_exporter /opt/snmp_exporter
sudo mkdir /opt/snmp_exporter
sudo mv snmp_exporter /opt/snmp_exporter/
sudo mv snmp.yaml /opt/snmp_exporter/

sudo su -c 'echo """
[Unit]
Description=Prometheus SNMP Exporter
After=network.target

[Service]
Type=simple
ExecStart=/opt/snmp_exporter/snmp_exporter --config.file=/opt/snmp_exporter/snmp.yaml
Restart=on-failure
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
""" > /etc/systemd/system/snmp_exporter.service'

sudo systemctl daemon-reexec &> /devnull
sudo systemctl daemon-reload &> /devnull
sudo systemctl enable snmp_exporter &> /devnull
sudo systemctl start snmp_exporter &> /devnull

echo -e "\n${GREEN}[SUCCESS]${WHITE} The SNMP Exporter was successfully installed and is configured to automatically startup"

# Cleanup
echo -e "\nPlease add the following to your prometheus configuration file:\n"
cat ../tmp.yaml && echo ""
rm ../tmp.yaml

exit 0
