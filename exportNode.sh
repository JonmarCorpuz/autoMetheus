#!/bin/bash

# ==== STATIC VARIABLES ==================================================================================
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

# ==== MAIN BODY =========================================================================================

touch tmp.yaml

#while true;
#do

#  read -p "Enter the IP address for your Prometheus server: " prometheusIP

#  if ! ping $prometheusIP -c 4 &> /dev/null;
#  then
#    echo -e "${RED}[ERROR]${WHITE} $prometheusIP was unreachable"
#  else
#    read -p "Enter SSH username: " sshUser
#    read -p "Enter SSH password: " sshPassword

#    test=$(sshpass -p '$sshPassword' ssh -o StrictHostKeyChecking=no '$sshUser@$prometheusIP')
#    if $test;
#    then
#      sshpass -p "$sshPassword" ssh -o StrictHostKeyChecking=no "$sshUser@$prometheusIP" \
#      'echo \"- job_name: node_exporter\n  static_configs:\n    - targets: [localhost:9100]\" | sudo tee -a /etc/prometheus/prometheus.yaml'
#    else
#      echo -e "${RED}[ERROR]${WHITE} ok"
#    fi
#  fi
#done

echo """
  - job_name: node_exporter
    static_configs:
""" >> ./tmp.yaml

while true;
do

  read -p "Enter the IP address for the Linux node that you would like to scrape: " deviceIP

  if [[ $deviceIP =~ $IPv4 ]];
  then
    cat $deviceIP
    echo "       - ${deviceIP}" >> ./tmp.yaml

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

echo -e "${YELLOW}[WARNING]${WHITE} Installing the Node Exporter\n"

wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.9.1.linux-amd64.tar.gz &> /dev/null
cd node_exporter-1.9.1.linux-amd64
./node_exporter &

processID=$(ps -ef | grep node_exporter | grep -v grep | awk '{print $2}')
echo -e "\n${GREEN}[SUCCESS]${WHITE} The Node Exporter was successfully installed and is successfully running in the background under process $processID on this host"

echo -e "\n${GREEN}[SUCCESS]${WHITE} Node Exporter was successfully installed"

# curl http://localhost:9100/metrics
