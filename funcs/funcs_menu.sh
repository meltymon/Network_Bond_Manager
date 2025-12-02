#!/bin/bash
# Universal Network Bond Manager - funcs_menu.sh

function select_adapters() {
    clear
    echo "--- $(tr CONFIG_MENU): $(tr SELECT_ADAPTERS) ---"
    
    echo "$(tr SELECT_ADAPTERS):"
    echo "----------------------------------------------------------------------------------------------------------------"
    nmcli device show | grep -E "DEVICE:|TYPE:|HWADDR:" | awk '{
        if ($1=="DEVICE:") {dev=$2} 
        else if ($1=="TYPE:") {type=$2} 
        else if ($1=="HWADDR:") {print dev " (" type ") MAC: " $2}
    }' | grep -E "(ethernet|wifi)" | nl
    echo "----------------------------------------------------------------------------------------------------------------"

    read -rp "Adapter eingeben (durch Leerzeichen getrennt, z.B. ens1 eth0 eno1): " input_slaves

    if [[ ! -z "$input_slaves" ]]; then
        SLAVES=($input_slaves)
        
        echo ""
        echo "$(tr SELECT_PRIMARY): ${SLAVES[*]}"
        read -rp "Primary Slave (muss einer der gewählten Adapter sein, z.B. ens1): " input_primary
        
        if [[ " ${SLAVES[*]} " =~ " ${input_primary} " ]]; then
            PRIMARY_SLAVE="$input_primary"
            echo "✅ Konfiguration gespeichert."
        else
            echo "❌ Fehler: $input_primary ist kein gültiger Slave. Bitte erneut versuchen."
            read -rp "$(tr PRESS_ENTER)"
            select_adapters
        fi
    else
        echo "❌ Fehler: Es müssen Adapter ausgewählt werden."
        read -rp "$(tr PRESS_ENTER)"
        select_adapters
    fi
}

function configure_ip() {
    clear
    echo "--- $(tr CONFIG_MENU) ---"
    
    read -rp "$(tr ENTER_IP) (Aktuell: $IP_ADDRESS): " input_ip
    if [[ ! -z "$input_ip" ]]; then
        IP_ADDRESS="$input_ip"
    fi

    read -rp "$(tr ENTER_GATEWAY) (Aktuell: $GATEWAY): " input_gateway
    if [[ ! -z "$input_gateway" ]]; then
        GATEWAY="$input_gateway"
    fi

    read -rp "$(tr ENTER_DNS) (Aktuell: $DNS_SERVER): " input_dns
    if [[ ! -z "$input_dns" ]]; then
        DNS_SERVER="$input_dns"
    fi

    echo "✅ IP-Konfiguration gespeichert."
}

function configure_speedtest_server() { 
    clear
    echo "--- $(tr CONFIG_MENU): $(tr SPEEDTEST_CONFIG) ---"
    
    if [ -z "$SPEEDTEST_SERVER_IDS" ]; then
        echo "Aktuell: Automatische Serverauswahl."
    else
        echo "Aktuelle Server ID: $SPEEDTEST_SERVER_IDS"
    fi

    echo ""
    echo "Tipp: Verwenden Sie 'speedtest-cli --list' in einer separaten Konsole, um Server-IDs zu finden."
    read -rp "$(tr ENTER_SERVER_ID) " input_server_id
    
    SPEEDTEST_SERVER_IDS="$input_server_id"
    echo "✅ Speedtest Server ID gespeichert."
}
