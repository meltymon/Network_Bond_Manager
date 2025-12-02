#!/bin/bash
# Universal Network Bond Manager - config.sh

# --- Globale Variablen und Konstanten ---
BOND_IFACE="bond0"
PRIMARY_SLAVE="ens1"
SLAVES=("ens1" "eth0" "eno1")
IP_ADDRESS="192.168.31.250/24"
GATEWAY="192.168.31.1"
DNS_SERVER="8.8.8.8"
SPEEDTEST_SERVER_IDS="" 
SPEEDTEST_TOOL="speedtest-cli" # Nutzt das Tool mit besserem Server-ID-Support
LANGUAGE="de"
BACKUP_DIR="/etc/NetworkManager/system-connections/bond_backup"

# --- Paketmanager-Variablen ---
PKG_MANAGER=""
INSTALL_CMD=""
REMOVE_CMD=""
UPDATE_CMD=""
