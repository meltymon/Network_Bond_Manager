---
[![Deutsche Version](https://img.shields.io/badge/Sprache-Deutsch-blue)](README.md)
## 🇬🇧 Englische README.md (Für `README_EN.md`)

```
# 💻 Universal Network Bond Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/meltymon/Network_Bond_Manager/blob/main/LICENSE)
[![Deutsche Version](https://img.shields.io/badge/Sprache-Deutsch-blue)](README.md)
[![GitHub stars](https://img.shields.io/github/stars/meltymon/Network_Bond_Manager.svg?style=social)](https://github.com/meltymon/Network_Bond_Manager/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/meltymon/Network_Bond_Manager.svg?style=social)](https://github.com/meltymon/Network_Bond_Manager/network/members)

A robust and interactive Bash script for the easy management of **Network Bonding (Active-Backup Mode)** on Linux distributions that use **NetworkManager (nmcli)**. The tool offers menu-driven options for activation, diagnosis, and configuration of network interfaces.

---

## ✨ Features

The **Universal Network Bond Manager** offers the following main functions via an interactive menu:

### ⚡ Core Functions (Bonding)

* **Bonding Activation:** Creates and activates a **Bond Master (`bond0`)** in **Active-Backup Mode** and configures the selected physical adapters as slaves.
* **Backup System:** Creates a **backup** of all active NetworkManager profiles before bond activation and restores them upon deactivation.
* **Bonding Deactivation:** Deletes the bond profiles (`bond0` and all slaves) and restores the original profiles from the backup.
* **Emergency Repair:** Aggressively deletes all bond profiles and resets the slaves to **individual DHCP profiles**.

### ⚙️ Configuration & Diagnostics

* **Language Selection:** Dynamic switching between **German (DE)** and **English (EN)**.
* **Configuration Menu:** Allows changing bonding parameters (slaves, primary slave, static IP/Gateway/DNS).
* **Diagnosis/Status Check:** Displays the current bond status, active slave, and MII link status.
* **Package Management:** Integrated menu for installing/uninstalling helper tools (`speedtest-cli`, `net-tools`) using the automatically detected system package manager.
* **Speedtest Function:** Starts a speed test. Supports **manual input of a server ID** for consistent measurements.

---

```bash
git clone [https://github.com/meltymon/Network_Bond_Manager.git](https://github.com/meltymon/Network_Bond_Manager.git)
cd Network_Bond_Manager
