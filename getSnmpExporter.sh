#!/bin/bash

# ==== REQUIREMENTS ======================================================================================

#enable
#configure terminal

# Set a read-only community string
#snmp-server community public RO

# Optional: Set a read-write community string (not recommended unless needed)
#snmp-server community private RW

#end
#write memory

# ==== STATIC VARIABLES ==================================================================================
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

INTEGER='^[0-9]+$'
IPv4='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

# ==== MAIN BODY =========================================================================================

wget https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-amd64.tar.gz
tar xzvf snmp_exporter-0.29.0.linux-amd64.tar.gz
cd snmp_exporter-0.29.0.linux-amd64.tar.gz
./snmp_exporter
