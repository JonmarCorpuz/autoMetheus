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

# Run the Node Exporter in the background
cd node_exporter-1.9.1.linux-amd64
./node_exporter & 
sleep 5

processID=$(ps -ef | grep node_exporter | grep -v grep | awk '{print $2}')
echo -e "\n${GREEN}[SUCCESS]${WHITE} The Node Exporter was successfully installed and is successfully running in the background under process $processID on this host"

# Cleanup
echo -e "\nPlease add the following to your prometheus configuration file:\n"
cat ../tmp.yaml && echo ""
rm ../tmp.yaml

exit 0

# curl http://localhost:9100/metrics
