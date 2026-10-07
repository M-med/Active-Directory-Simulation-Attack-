# 🛡️ Active Directory Simulation - Purple Team Lab

<div align="center">

![Windows Server](https://img.shields.io/badge/Windows_Server-2022-0078D6?style=for-the-badge&logo=windows)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557C94?style=for-the-badge&logo=kalilinux)
![Active Directory](https://img.shields.io/badge/Active_Directory-003366?style=for-the-badge&logo=microsoft)
![Zabbix](https://img.shields.io/badge/Zabbix-D40000?style=for-the-badge&logo=zabbix)

**A complete Purple Team lab environment for simulating attacks and implementing defensive hardening on Active Directory**

[Overview](#-overview) • [Architecture](#-architecture) • [Installation](#-installation) • [Attack Simulation](#-attack-simulation) • [Hardening](#-defensive-hardening) • [Monitoring](#-monitoring-with-zabbix)

</div>

---

## Overview

This project is a **Purple Team laboratory** designed to:

- 🎯 **Simulate real-world attacks** against an Active Directory environment (Kerberoasting, lateral movement, credential dumping)
- 🛡️ **Implement defensive hardening** measures (gMSA, tiering model, LLMNR/NetBIOS disabling)
- 📊 **Monitor and detect** malicious activity using Sysmon, audit policies, and Zabbix SIEM

The lab reproduces a typical enterprise AD infrastructure and demonstrates the full attack lifecycle — from reconnaissance to domain compromise — followed by remediation and detection engineering.

---

## Architecture

### Virtual Machines

| VM | OS | IP | Role |
|----|----|----|------|
| **DC01** | Windows Server 2022 | `192.168.100.10` | Domain Controller |
| **CLIENT01** | Windows 10/11 | `192.168.100.50` | Domain-joined workstation |
| **KALI** | Kali Linux | `192.168.100.30` | Attack machine |
| **ZABBIX** | Ubuntu Server | `192.168.100.40` | Monitoring server |

### Network

- **Subnet:** `192.168.100.0/24`
- **Domain:** `lab.local`
- **NetBIOS:** `LAB`

See [docs/architecture.md](docs/architecture.md) for full details.

---

## Technologies Used

| Category | Tools |
|----------|-------|
| **Virtualization** | VirtualBox |
| **OS** | Windows Server 2022, Windows 10, Kali Linux, Ubuntu Server |
| **AD Services** | Active Directory Domain Services (AD DS), DNS |
| **Offensive** | BloodHound, SharpHound, Impacket, John the Ripper, Hashcat |
| **Defensive** | Sysmon, auditpol, gMSA, GPO |
| **Monitoring** | Zabbix 6.4, SIEM (Event Logs) |
| **Scripting** | PowerShell, Bash |

---

## Quick Start

### 1. Clone the repository
git clone https://github.com/M-med/Active-Directory-Simulation-Attack-.git
cd Active-Directory-Simulation-Attack-

### 2. Read the installation guide
cat docs/installation.md

### 3. Deploy the lab (follow docs/installation.md)
