#!/bin/bash
# Universal Network Bond Manager - funcs_tools.sh

function run_speedtest_multi_server() {
    echo "--- [3] $(tr SPEEDTEST) ---"
    
    if ! command -v "$SPEEDTEST_TOOL" &> /dev/null; then
        echo "$(tr TOOL_NOT_FOUND)"
        echo "Wählen Sie Option 6, um 'speedtest-cli' zu installieren."
        return
    fi
    
    local speedtest_cmd=""
    local speedtest_tool_used="$SPEEDTEST_TOOL"

    if [ -n "$SPEEDTEST_SERVER_IDS" ]; then
        echo "$(tr STARTING_SPEEDTEST_MANUAL) (Tool: $speedtest_tool_used)"
        # Das Problem der Server-ID, das Sie hatten, sollte mit speedtest-cli gelöst sein.
        speedtest_cmd="$SPEEDTEST_TOOL --server $SPEEDTEST_SERVER_IDS"
    else
        echo "$(tr STARTING_SPEEDTEST_AUTO) (Tool: $speedtest_tool_used)"
        speedtest_cmd="$SPEEDTEST_TOOL"
    fi
    
    $speedtest_cmd
    
    if [ $? -eq 0 ]; then
        echo "✅ Speedtest erfolgreich."
    else
        echo "❌ FEHLER: Speedtest ist fehlgeschlagen."
        echo "   Mögliche Gründe: Server ID ist ungültig (Option 7 -> 3 prüfen) oder keine Internetverbindung."
    fi
}

function diagnose_status() {
    echo "--- [4] $(tr DIAGNOSE) ---"
    
    echo "## 1. Routing-Tabelle"
    echo "----------------------------------------"
    ip route show
    
    if ip route show | grep -q "default.*dev $BOND_IFACE"; then
        echo "$(tr ROUTE_CORRECT)"
    else
        echo "$(tr ROUTE_ERROR)"
    fi
    
    echo ""
    echo "## 2. Bonding Treiberstatus (/proc/net/bonding/)"
    echo "---------------------------------"
    BOND_STATUS_OUTPUT=$(cat /proc/net/bonding/"$BOND_IFACE" 2>/dev/null)
    
    if [ -z "$BOND_STATUS_OUTPUT" ]; then
        echo "❌ BOND NICHT AKTIV: '$BOND_IFACE' ist nicht im Kernel registriert."
        echo "   Bitte Option 1 (Aktivieren) verwenden."
    else
        echo "$BOND_STATUS_OUTPUT"
        
        ACTIVE_SLAVE=$(echo "$BOND_STATUS_OUTPUT" | grep "Currently Active Slave" | awk '{print $4}')
        MII_STATUS=$(echo "$BOND_STATUS_OUTPUT" | grep "MII Status" | head -n 1 | awk '{print $3}')
        
        echo ""
        echo "## ZUSAMMENFASSUNG"
        echo "-------------------"
        if [ "$MII_STATUS" == "up" ]; then
            echo "$(tr MII_STATUS_UP)"
        else
            echo "$(tr MII_STATUS_DOWN)"
        fi

        echo "$(tr SLAVE_RUNNING): $ACTIVE_SLAVE (Primary: $PRIMARY_SLAVE)"
    fi
}


function manage_packages() {
    while true; do
        clear
        echo "--- [6] $(tr PACKAGE_MGMT) ---"
        echo "$(tr PKGMGR_INFO): $PKG_MANAGER"
        echo "-------------------------------------"
        echo "1) ➕ $(tr PKG_INSTALL_TITLE)"
        echo "2) ➖ $(tr PKG_REMOVE_TITLE)"
        echo "0) $(tr EXIT)"
        echo "-------------------------------------"
        read -rp "$(tr CONFIG_CHOICE_PROMPT): " pkg_choice

        case "$pkg_choice" in
            1) install_packages ;;
            2) remove_packages ;;
            0) break ;;
            *) echo "$(tr INVALID_CHOICE)"; sleep 2 ;;
        esac
    done
}

function install_packages() {
    clear
    echo "--- $(tr PKG_INSTALL_TITLE) (via $PKG_MANAGER) ---"
    echo "Wähle die zu installierenden Pakete (Mehrfachauswahl möglich, z.B. 1 3):"
    echo "1) speedtest-cli (Speedtest-Tool)"
    echo "2) net-tools (Enthält ifconfig, route, netstat)"
    echo "3) iproute2 (Enthält ip, ss, rtacct)"
    echo "4) DNS-Tools (dig/nslookup)"
    echo "0) $(tr EXIT)"
    echo "-------------------------------------"
    read -rp "$(tr CONFIG_CHOICE_PROMPT): " install_list

    local PKGS_TO_INSTALL=()
    
    for choice in $install_list; do
        case "$choice" in
            1) PKGS_TO_INSTALL+=("speedtest-cli") ;;
            2) PKGS_TO_INSTALL+=("net-tools") ;;
            3) PKGS_TO_INSTALL+=("iproute2") ;;
            4) 
                if [ "$PKG_MANAGER" == "apt" ]; then
                    PKGS_TO_INSTALL+=("dnsutils")
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    PKGS_TO_INSTALL+=("bind")
                else
                    PKGS_TO_INSTALL+=("bind-utils")
                fi
                ;;
            0) echo "Abgebrochen."; read -rp "$(tr PRESS_ENTER)"; return ;;
            *) echo "Ungültige Auswahl $choice übersprungen." ;;
        esac
    done

    if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
        echo "Führe Installation aus: ${PKGS_TO_INSTALL[*]}"
        $UPDATE_CMD 
        $INSTALL_CMD ${PKGS_TO_INSTALL[@]}
        if [ $? -eq 0 ]; then
            echo "$(tr PKG_INSTALL_DONE)"
        else
            echo "❌ FEHLER bei der Installation. Bitte die Meldungen oben prüfen."
        fi
    fi
    read -rp "$(tr PRESS_ENTER)"
}

function remove_packages() {
    clear
    echo "--- $(tr PKG_REMOVE_TITLE) (via $PKG_MANAGER) ---"
    echo "Wähle die zu deinstallierenden Pakete (Mehrfachauswahl möglich, z.B. 1 3):"
    echo "1) speedtest-cli"
    echo "2) net-tools"
    echo "3) iproute2"
    echo "4) DNS-Tools (dnsutils/bind-utils)"
    echo "0) $(tr EXIT)"
    echo "-------------------------------------"
    read -rp "$(tr CONFIG_CHOICE_PROMPT): " remove_list

    local PKGS_TO_REMOVE=()

    for choice in $remove_list; do
        case "$choice" in
            1) PKGS_TO_REMOVE+=("speedtest-cli") ;;
            2) PKGS_TO_REMOVE+=("net-tools") ;;
            3) PKGS_TO_REMOVE+=("iproute2") ;;
            4) 
                if [ "$PKG_MANAGER" == "apt" ]; then
                    PKGS_TO_REMOVE+=("dnsutils")
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    PKGS_TO_REMOVE+=("bind")
                else
                    PKGS_TO_REMOVE+=("bind-utils")
                fi
                ;;
            0) echo "Abgebrochen."; read -rp "$(tr PRESS_ENTER)"; return ;;
            *) echo "Ungültige Auswahl $choice übersprungen." ;;
        esac
    done

    if [ ${#PKGS_TO_REMOVE[@]} -gt 0 ]; then
        echo "Führe Deinstallation aus: ${PKGS_TO_REMOVE[*]}"
        $REMOVE_CMD ${PKGS_TO_REMOVE[@]}
        if [ $? -eq 0 ]; then
            echo "$(tr PKG_REMOVE_DONE)"
        else
            echo "❌ FEHLER bei der Deinstallation. Bitte die Meldungen oben prüfen."
        fi
    fi
    read -rp "$(tr PRESS_ENTER)"
}
