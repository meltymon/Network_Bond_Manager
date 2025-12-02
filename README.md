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

```
git clone [https://github.com/meltymon/Network_Bond_Manager.git](https://github.com/meltymon/Network_Bond_Manager.git)
cd Network_Bond_Manager
```

💡 Hinweis: Stellen Sie sicher, dass Git auf Ihrem System installiert ist.
### 2. Berechtigungen setzen und Start

Da das Skript systemweite Änderungen an der Netzwerkkonfiguration vornimmt (über `nmcli`), muss es mit **Root-Rechten (`sudo`)** ausgeführt werden.

Stellen Sie zunächst die Ausführungsberechtigung sicher:
```
chmod +x main.sh
```

Anschließend starten Sie das interaktive Tool:

```
sudo ./main.sh
```
⚠️ Wichtig: Dieses Skript wurde für Systeme entwickelt, die den NetworkManager (mit nmcli) verwenden.

## 📂 Projektstruktur

Das Projekt wurde vollständig **modularisiert** (Separation of Concerns) in dedizierte Ordner und Dateien, um die Wartbarkeit und Erweiterbarkeit zu maximieren.

| Datei / Ordner | Zweck | Details |
| :--- | :--- | :--- |
| `main.sh` | **Einstiegspunkt** | Lädt alle Konfigurationen und Funktionen und enthält die Haupt-Menüschleife. |
| `config.sh` | **Globale Variablen** | Enthält alle konfigurierbaren Variablen wie `IP_ADDRESS`, `PRIMARY_SLAVE`, `SPEEDTEST_SERVER_IDS`. |
| **`funcs/`** | **Funktionsbibliothek** | Beinhaltet alle modularen Skriptteile (Kernlogik, Menüsteuerung, Tools). |
| `funcs/funcs_utils.sh` | Utilities | Enthält Hilfsfunktionen wie das **Übersetzungstool `tr()`**, `show_menu` und das **Backup/Restore-System**. |
| `funcs/funcs_core.sh` | Kernlogik | Enthält die kritischen Funktionen zur **Bonding-Steuerung** (`activate_bonding`, `deactivate_bonding`, etc.). |
| `funcs/funcs_menu.sh` | Menü-Logik | Verwaltet die Benutzeroberfläche und die Erfassung der Konfigurationsparameter (z.B. Adapterauswahl). |
| `funcs/funcs_tools.sh` | Tool-Funktionen | Implementiert Diagnose- und Verwaltungstools (`run_speedtest`, `manage_packages`). |
| **`langs/`** | **Sprachdateien** | Enthält alle Text-Arrays für die Lokalisierung. |
| `langs/lang_de.sh` | Deutsch (DE) | Enthält alle deutschen Übersetzungen. |
| `langs/lang_en.sh` | Englisch (EN) | Enthält alle englischen Übersetzungen. |

## 🛠️ Konfigurationsdetails (`config.sh`)

Die Datei **`config.sh`** ist das zentrale Element zur Anpassung des Skriptverhaltens. Viele dieser Variablen können auch über das Menü (Option 7) zur Laufzeit geändert werden.

| Variable | Standardwert | Beschreibung |
| :--- | :--- | :--- |
| `BOND_IFACE` | `"bond0"` | Der **Name des Bond-Masters**, der erstellt wird. |
| `BOND_MODE` | `"active-backup"` | Der **Bonding-Modus** (wird im Skript auf `active-backup` fest codiert). |
| `PRIMARY_SLAVE` | `""` | Definiert den **bevorzugten (aktiven) Slave** im Active-Backup-Modus. Leer lassen für automatische Auswahl. |
| `SLAVES` | `()` | Ein **Array** der physischen Netzwerknamen (`eth0`, `enp1s0`, etc.), die gebondet werden sollen. |
| `IP_ADDRESS` | `""` | Die **statische IP-Adresse** (z.B. `192.168.1.100/24`) für die Bond-Schnittstelle. |
| `GATEWAY` | `""` | Der Standard-Gateway. |
| `DNS_SERVERS` | `""` | Komma-getrennte Liste der DNS-Server (z.B. `"8.8.8.8,8.8.4.4"`). |
| `BOND_MIIMON` | `"100"` | Intervall zur **Link-Überwachung** in Millisekunden. |
| `SPEEDTEST_TOOL` | `"speedtest-cli"` | Das zu verwendende Speedtest-Programm. |
| `SPEEDTEST_SERVER_IDS` | `""` | **Manuelle ID** des Servers für konsistente Geschwindigkeitstests. |

### ✏️ Beispiel (`config.sh`)

Ein Konfigurationsbeispiel, um die Adapter `eth0` und `eth1` mit einer statischen IP zu bonden:

```
#!/bin/bash

# --- Netzwerk Konfiguration ---
BOND_IFACE="bond0"
PRIMARY_SLAVE="eth0"
SLAVES=("eth0" "eth1") 
IP_ADDRESS="192.168.10.50/24"
GATEWAY="192.168.10.1"
DNS_SERVERS="8.8.8.8,1.1.1.1"

# --- Bonding Parameter ---
BOND_MODE="active-backup"
BOND_MIIMON="100"

# --- Tools ---
SPEEDTEST_TOOL="speedtest-cli"
SPEEDTEST_SERVER_IDS=""
```
## 📜 Changelog / Versionsverlauf

### Version 5.4 (Aktuell)

* **Versionsnummer:** 5.4
* **Status:** Stabile, modularisierte Version.
* **Neu:** Vollständiges **Refactoring und Modularisierung** des gesamten Skripts in dedizierte `funcs/` und `langs/` Ordner.
* **Fix:** Fehlerbehebung der `read -rp` Prompts in der Paketverwaltung für eine korrekte, sprachabhängige Ausgabe.
* **Status:** Erfolgreicher initialer Commit und Push auf GitHub abgeschlossen.

### Version 5.0

* **Versionsnummer:** 5.0
* **Neu:** Einführung der **Backup- und Restore-Funktionen** für NetworkManager-Profile zur Gewährleistung der Rückwärtskompatibilität.
* **Neu:** Erstmalige Implementierung des **NMCLI-Backends** für die persistente Bond-Erstellung.
* **Neu:** Erkennung des System-Paketmanagers (`apt`, `pacman` etc.) implementiert.

### Version 3.1

* **Versionsnummer:** 3.1
* **Neu:** Implementierung der **Notfall-Reparatur (`Emergency Repair`)** Funktion zur aggressiven Rücksetzung der Adapter auf DHCP-Profile.
* **Fix:** Verbesserung der Adapter-Auswahllogik, um nur physische Ethernet-Adapter anzuzeigen.

### Version 2.0

* **Versionsnummer:** 2.0
* **Neu:** Einführung eines **interaktiven Menüsystems** anstelle einfacher Kommandozeilen-Argumente.
* **Neu:** Implementierung der **Basis-Bonding-Funktionalität** im Active-Backup-Modus.
* **Neu:** Erste Implementierung der **Diagnose- und Statusprüfung**.

### Version 1.0 (Initial Release)

* **Versionsnummer:** 1.0
* **Neu:** Erstellung der ersten rudimentären **Bash-Skript-Logik** zur Konfiguration von Netzwerk-Bonds über die Konfigurationsdateien (Legacy-Methode).
* **Neu:** Definition der globalen Variablen (`BOND_IFACE`, `PRIMARY_SLAVE`).

---

## 🤝 Mitwirken (Contributing)

Beiträge zur Verbesserung dieses Projekts sind herzlich willkommen! 

[Image of GitHub Pull Request workflow]


1.  **Forken** Sie das Repository.
2.  Erstellen Sie einen neuen Branch für Ihre Funktion:
    ```bash
    git checkout -b feature/IhreFunktion
    ```
3.  Committen Sie Ihre Änderungen:
    ```bash
    git commit -m 'feat: Neue Funktion hinzugefügt'
    ```
4.  Pushen Sie den Branch:
    ```bash
    git push origin feature/IhreFunktion
    ```
5.  Erstellen Sie einen **Pull Request**.

---

## ⚖️ Lizenz

Dieses Projekt steht unter der **MIT License**. Details finden Sie in der [LICENSE](LICENSE)-Datei.
