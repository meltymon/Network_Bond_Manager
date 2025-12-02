# 💻 Universal Network Bond Manager

[![GitHub license](https://img.shields.io/github/license/meltymon/Network_Bond_Manager.svg)](https://github.com/meltymon/Network_Bond_Manager/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/meltymon/Network_Bond_Manager.svg?style=social)](https://github.com/meltymon/Network_Bond_Manager/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/meltymon/Network_Bond_Manager.svg?style=social)](https://github.com/meltymon/Network_Bond_Manager/network/members)

Ein robustes und interaktives Bash-Skript zur einfachen Verwaltung von **Network Bonding (Active-Backup-Modus)** unter Linux-Distributionen, die den **NetworkManager (nmcli)** verwenden. Das Tool bietet Menü-gesteuerte Optionen für Aktivierung, Diagnose und Konfiguration von Netzwerk-Schnittstellen.

---

## ✨ Features

Der **Universal Network Bond Manager** bietet folgende Hauptfunktionen über ein interaktives Menü:

### ⚡ Kernfunktionen (Bonding)

* **Bonding Aktivierung:** Erstellt und aktiviert einen **Bond-Master (`bond0`)** im **Active-Backup-Modus** und konfiguriert die ausgewählten physischen Adapter als Slaves.
* **Backup-System:** Erstellt ein **Backup** aller aktiven NetworkManager-Profile vor der Bond-Aktivierung und stellt diese beim Deaktivieren wieder her.
* **Bonding Deaktivierung:** Löscht die Bond-Profile (`bond0` und alle Slaves) und stellt die ursprünglichen Profile aus dem Backup wieder her.
* **Notfall-Reparatur (`Emergency Repair`):** Löscht aggressiv alle Bond-Profile und stellt die Slaves auf **individuelle DHCP-Profile** um.

### ⚙️ Konfiguration & Diagnose

* **Sprachauswahl:** Dynamische Umschaltung zwischen **Deutsch (DE)** und **Englisch (EN)**.
* **Konfigurationsmenü:** Erlaubt das Ändern der Bonding-Parameter (Slaves, primärer Slave, statische IP/Gateway/DNS).
* **Diagnose/Statusprüfung:** Zeigt den aktuellen Bond-Status, den aktiven Slave und den MII-Link-Status an.
* **Paketverwaltung:** Integriertes Menü zur Installation/Deinstallation von Hilfstools (`speedtest-cli`, `net-tools`) unter Verwendung des automatisch erkannten System-Paketmanagers.
* **Speedtest-Funktion:** Startet einen Geschwindigkeitstest. Unterstützt die **manuelle Eingabe einer Server-ID** für konsistente Messungen.

---

## 🚀 Installation & Start

### 1. Klonen des Repositorys

```bash
git clone [https://github.com/meltymon/Network_Bond_Manager.git](https://github.com/meltymon/Network_Bond_Manager.git)
cd Network_Bond_Manager
