#!/bin/bash
# Universal Network Bond Manager - main.sh

# Das Skript MUSS mit sudo ausgeführt werden.
if [ "$EUID" -ne 0 ]; then
  echo "Fehler: Dieses Skript muss mit sudo ausgeführt werden."
  exit 1
fi

# --- 1. Konfiguration laden ---
source ./config.sh

# --- 2. Hilfsfunktionen, Paketmanager und Sprachen laden ---
source ./funcs/funcs_utils.sh
source ./langs/lang_de.sh
source ./langs/lang_en.sh

# Führt die Erkennung aus, um die Paketmanager-Variablen zu setzen
detect_package_manager

# --- 3. Kernfunktionen laden ---
source ./funcs/funcs_core.sh
source ./funcs/funcs_tools.sh
source ./funcs/funcs_menu.sh

# --- 4. Hauptlogik starten ---

select_language

while true; do
    show_menu
    # Die Eingabeaufforderung muss manuell übersetzt werden, da show_menu davor aufgerufen wird.
    if [ "$LANGUAGE" == "de" ]; then
        read -rp "Bitte wählen Sie eine Option (0-7): " choice
    else
        read -rp "Please select an option (0-7): " choice
    fi

    case "$choice" in
        1)
            activate_bonding
            read -rp "$(tr PRESS_ENTER)"
            ;;
        2)
            deactivate_bonding
            read -rp "$(tr PRESS_ENTER)"
            ;;
        3)
            run_speedtest_multi_server
            read -rp "$(tr PRESS_ENTER)"
            ;;
        4)
            diagnose_status
            read -rp "$(tr PRESS_ENTER)"
            ;;
        5) 
            emergency_repair
            read -rp "$(tr PRESS_ENTER)"
            ;;
        6) 
            manage_packages
            ;;
        7) 
            while true; do
                clear
                echo "--- $(tr CONFIG_MENU) ---"
                echo "1) $(tr SELECT_ADAPTERS)"
                echo "2) $(tr IP_SETTINGS)"
                echo "3) $(tr SPEEDTEST_CONFIG)"
                echo "4) $(tr SELECT_LANGUAGE)$LANGUAGE)" 
                echo "0) $(tr EXIT)" 
                echo "-------------------------"
                read -rp "$(tr CONFIG_CHOICE_PROMPT): " config_choice # NEU: Eingabezeile in Konfigurationsmenü

                case "$config_choice" in
                    1) select_adapters ;;
                    2) configure_ip ;;
                    3) configure_speedtest_server ;;
                    4) select_language ;;
                    0) break ;;
                    *) echo "$(tr INVALID_CHOICE)"; sleep 2 ;;
                esac
            done
            ;;
        0)
            echo "$(tr EXIT)" 
            exit 0
            ;;
        *)
            echo "$(tr INVALID_CHOICE)"
            read -rp "$(tr PRESS_ENTER)"
            ;;
    esac
done
