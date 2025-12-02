#!/bin/bash
# Universal Network Bond Manager - funcs_core.sh

function activate_bonding() {
    echo "--- [1] $(tr ACTIVATE) ---"
    
    backup_nm_profiles

    BOND_OPTIONS="mode=active-backup,primary=${PRIMARY_SLAVE},miimon=100"

    # 1. Konfiguration erstellen
    if ! nmcli connection show "$BOND_IFACE" &> /dev/null; then
        echo "Erstelle Bond-Master '$BOND_IFACE'..."
        nmcli connection add type bond con-name "$BOND_IFACE" ifname "$BOND_IFACE" bond.options "$BOND_OPTIONS"

        for slave in "${SLAVES[@]}"; do
            echo "Bereinige und erstelle Slave-Profil für $slave..."
            
            nmcli device disconnect "$slave" &> /dev/null 
            
            nmcli connection delete "$slave" &> /dev/null 
            nmcli connection delete "${slave}-slave" &> /dev/null 
            nmcli connection delete "${slave}-dhcp" &> /dev/null 
            
            nmcli connection add type ethernet con-name "${slave}-slave" ifname "$slave" master "$BOND_IFACE"
        done

        echo "Konfiguriere statische IP-Adresse ($IP_ADDRESS)..."
        nmcli connection modify "$BOND_IFACE" ipv4.addresses "$IP_ADDRESS"
        nmcli connection modify "$BOND_IFACE" ipv4.gateway "$GATEWAY"
        nmcli connection modify "$BOND_IFACE" ipv4.dns "$DNS_SERVER"
        nmcli connection modify "$BOND_IFACE" ipv4.method manual
        nmcli connection modify "$BOND_IFACE" connection.autoconnect yes
    fi
    
    # 2. Aktivierung
    echo "Aktiviere Bond- und Slave-Verbindungen..."
    for slave in "${SLAVES[@]}"; do
        nmcli connection up "${slave}-slave"
    done
    nmcli connection up "$BOND_IFACE"

    echo "Warte 5 Sekunden auf Stabilität..."
    sleep 5
    
    echo "Starte NetworkManager neu, um Link-Status zu erzwingen..."
    systemctl restart NetworkManager
    sleep 5

    echo "Aktiviere $BOND_IFACE erneut nach NM-Neustart..."
    nmcli connection up "$BOND_IFACE"

    echo "------------------------------------"
    echo "$(tr SUCCESS_ACTIVATE)"
    echo "------------------------------------"
    diagnose_status
}

function deactivate_bonding() {
    echo "--- [2] $(tr DEACTIVATE) ---"

    if nmcli connection show "$BOND_IFACE" &> /dev/null; then
        echo "Deaktiviere und lösche Bond-Verbindungen..."
        nmcli connection down "$BOND_IFACE" &> /dev/null
        nmcli connection delete "$BOND_IFACE"
        for slave in "${SLAVES[@]}"; do
            nmcli connection delete "${slave}-slave" &> /dev/null
        done
        echo "Bonding-Konfiguration erfolgreich gelöscht."
    else
        echo "Bond-Master '$BOND_IFACE' existiert nicht."
    fi

    restore_nm_profiles
    
    echo "--------------------------------------------------------"
    echo "$(tr SUCCESS_DEACTIVATE)"
    echo "--------------------------------------------------------"
    ip a show "$PRIMARY_SLAVE"
}

function emergency_repair() {
    echo "--- [5] $(tr EMERGENCY) ---"
    
    read -rp "$(tr EMERGENCY_CONFIRM)" confirmation
    if [[ "$confirmation" != "j" && "$confirmation" != "y" ]]; then
        echo "Aktion abgebrochen."
        return
    fi
    
    echo "🚨 Durchführe Notfall-Bereinigung..."

    # 1. Alle Bond- und Slave-Profile aggressiv löschen
    nmcli connection down "$BOND_IFACE" &> /dev/null
    nmcli connection delete "$BOND_IFACE" &> /dev/null
    for slave in "${SLAVES[@]}"; do
        nmcli connection delete "${slave}-slave" &> /dev/null
    done
    
    # NEUE LOGIK: Alle Slaves auf individuelle DHCP-Profile umstellen
    echo "Stelle alle ${SLAVES[*]} Slaves auf individuelle DHCP-Verbindungen um..."
    
    for slave in "${SLAVES[@]}"; do
        local dhcp_conn="${slave}-dhcp"
        
        nmcli connection delete "$dhcp_conn" &> /dev/null
        
        echo " -> Erstelle und aktiviere DHCP für $slave..."
        nmcli connection add type ethernet con-name "$dhcp_conn" ifname "$slave" ipv4.method auto connection.autoconnect yes
        nmcli connection up "$dhcp_conn"
    done
    
    systemctl restart NetworkManager
    sleep 5
    
    local primary_dhcp_conn="${PRIMARY_SLAVE}-dhcp"
    nmcli connection up "$primary_dhcp_conn"
    
    echo "--------------------------------------------------------"
    echo "$(tr EMERGENCY_SUCCESS)"
    echo "--------------------------------------------------------"
    
    for slave in "${SLAVES[@]}"; do
        ip a show "$slave"
        echo "---"
    done
}
