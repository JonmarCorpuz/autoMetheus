#!/bin/bash

# ==== STATIC VARIABLES ==================================================================================
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

# ==== MAIN BODY =========================================================================================

touch appendToPrometheus.yaml
echo -e "  - job_name: node_exporter\n    static_configs:      - targets: """ >> ./appendToPrometheus.yaml

while true;
do

  read -p "Enter the IP address for the Linux node that you would like to scrape: " deviceIP
  echo ""

  if [[ $deviceIP =~ $IPv4 ]];
  then
    echo $deviceIP
    echo "       - ${deviceIP}" >> ./appendToPrometheus.yaml

    read -p "Would you like to add another device? [Y] or [N] " addDevice
    if [[ $addDevice =~ "N" ]];
    then
      echo " " >> ./appendToPrometheus.yaml
      break
    fi
    echo ""
  else
    echo -e "${RED}[ERROR]${WHITE} $deviceIP is not a valid IPv4 address\n"
  fi
done

while true;
do

  read -p "Enter the IP address for your Prometheus server: " prometheusIP

  if ping $prometheusIP -c 4 &> /dev/null;
  then

    read -p "Enter SSH username: " sshUser
    #read -p "Enter SSH password: " sshPassword

    if scp appendToPrometheus.yaml $sshUser@$prometheusIP:~/;
    then
      echo -e "${YELLOW}[NOTICE]${WHITE} appendToPrometheus.yaml was copied to the home directory of $sshUser on $prometheusIP"
      echo -e "${YELLOW}[NOTICE]${WHITE} Please append the contents of this file to your prometheus.yaml configuration file"
    else
      echo -e "${RED}[ERROR]${WHITE} Failed to copy appendToPrometheus.yaml to the home directory of $sshUser on $prometheusIP"
      echo -e "${YELLOW}[NOTICE]${WHITE} Please append the contents of this file to your prometheus.yaml configuration file"
    fi
  else
    echo -e "${RED}[ERROR]${WHITE} $prometheusIP was unreachable"
    echo -e "${YELLOW}[NOTICE]${WHITE} Please append the contents of this file to your prometheus.yaml configuration file"
  fi
done

echo -e "${YELLOW}[WARNING]${WHITE} Installing the Node Exporter\n"
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.9.1.linux-amd64.tar.gz &> /dev/null
cd node_exporter-1.9.1.linux-amd64
./node_exporter & 
sleep 10

processID=$(ps -ef | grep node_exporter | grep -v grep | awk '{print $2}')
echo -e "\n${GREEN}[SUCCESS]${WHITE} The Node Exporter was successfully installed and is successfully running in the background under process $processID on this host"

# curl http://localhost:9100/metrics
