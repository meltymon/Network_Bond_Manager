#!/bin/bash
# Universal Network Bond Manager - funcs_utils.sh

# Die globale Variable TEXT ist hier verfügbar, da die Sprachdateien zuerst in main.sh geladen werden.

# --- Hilfsfunktionen ---

function tr() { # Übersetzungshilfe
    echo -n "${TEXT[$LANGUAGE,$1]}"
}

function select_language() {
    clear
    echo "==================================="
    echo "🌍 Language Selection / Sprachauswahl"
    echo "==================================="
    echo "1) Deutsch (DE)"
    echo "2) English (EN)"
    echo "==================================="
    read -rp "Please select your language (1 or 2): " lang_choice

    case "$lang_choice" in
        1) LANGUAGE="de" ;;
        2) LANGUAGE="en" ;;
        *) select_language ;;
    esac
}

# --- Paketmanager-Erkennung ---

function detect_package_manager() {
    # Diese Funktion setzt die globalen Variablen PKG_MANAGER, INSTALL_CMD etc. aus config.sh
    if command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        REMOVE_CMD="sudo pacman -Rs --noconfirm"
        UPDATE_CMD="sudo pacman -Sy"
    elif command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt install -y"
        REMOVE_CMD="sudo apt remove -y"
        UPDATE_CMD="sudo apt update"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        REMOVE_CMD="sudo dnf remove -y"
        UPDATE_CMD="sudo dnf check-update"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        REMOVE_CMD="sudo yum remove -y"
        UPDATE_CMD="sudo yum check-update"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
        REMOVE_CMD="sudo zypper remove -y"
        UPDATE_CMD="sudo zypper update"
    else
        echo "FEHLER: Konnte keinen unterstützten Paketmanager (pacman, apt, dnf, yum, zypper) erkennen."
        exit 1
    fi
}

# --- Menü-Anzeige ---

function show_menu() {
    clear
    echo "==================================================="
    echo "$(tr TITLE)"
    echo "==================================================="
    echo "$(tr CONFIG_TITLE):"
    echo "  - $(tr SLAVE_ADAPTERS): ${SLAVES[*]}"
    echo "  - $(tr PRIMARY_SLAVE_ADAPTER): $PRIMARY_SLAVE"
    echo "  - $(tr IP_ADDRESS): $IP_ADDRESS"
    if [ -n "$SPEEDTEST_SERVER_IDS" ]; then
        echo "  - $(tr CURRENT_SERVER_ID): $SPEEDTEST_SERVER_IDS"
    fi
    echo "==================================================="
    echo "$(tr MENU_TITLE):"
    echo "1) $(tr ACTIVATE)"
    echo "2) $(tr DEACTIVATE)"
    echo "3) $(tr SPEEDTEST)"
    echo "4) $(tr DIAGNOSE)"
    echo "5) $(tr EMERGENCY)"
    echo "6) $(tr PACKAGE_MGMT)"
    echo "7) $(tr CONFIG_MENU)"
    echo "0) $(tr EXIT)"
    echo "==================================================="
}

# --- Backup/Restore Funktionen (Kernschutz) ---

function backup_nm_profiles() {
    echo "--- $(tr BACKUP_TITLE) ---"

    mkdir -p "$BACKUP_DIR"

    rm -f "$BACKUP_DIR"/*

    local files_to_backup=()
    # Finde alle Nicht-Bond-Profile im NM-Verzeichnis zum Sichern
    while IFS= read -r file; do
        files_to_backup+=("$file")
    done < <(find /etc/NetworkManager/system-connections/ -maxdepth 1 -type f \
        ! -name "$BOND_IFACE" -a \
        ! -name "*slave" -a \
        ! -name "*.backup" 2>/dev/null)

    if [ ${#files_to_backup[@]} -gt 0 ]; then
        cp "${files_to_backup[@]}" "$BACKUP_DIR"
        echo "$(tr BACKUP_CREATED)"
    else
        echo "$(tr BACKUP_FAILED)"
    fi
}

function restore_nm_profiles() {
    echo "--- $(tr RESTORE_TITLE) ---"

    if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR")" ]; then

        cp "$BACKUP_DIR"/* /etc/NetworkManager/system-connections/

        systemctl restart NetworkManager
        sleep 5

        echo "$(tr RESTORE_SUCCESS)"
    else
        echo "$(tr RESTORE_FAILED)"
    fi
}
