# 🛡️ Active Directory Simulation - Purple Team Lab

<div align="center">

![Windows Server](https://img.shields.io/badge/Windows_Server-2022-0078D6?style=for-the-badge&logo=windows)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557C94?style=for-the-badge&logo=kalilinux)
![Active Directory](https://img.shields.io/badge/Active_Directory-003366?style=for-the-badge&logo=microsoft)
![Wazuh](https://img.shields.io/badge/Wazuh_SIEM-3C9EEA?style=for-the-badge&logo=wazuh)

**A complete Purple Team lab environment for simulating attacks and implementing defensive hardening on Active Directory**

[Overview](#-overview) • [Architecture](#-architecture) • [Installation](#-installation) • [Attack Simulation](#-attack-simulation) • [Hardening](#-defensive-hardening) • [Monitoring](#-monitoring-with-wazuh)

</div>



## 📋 Overview

This project is a **Purple Team laboratory** designed to:

- 🎯 **Simulate real-world attacks** against an Active Directory environment (Kerberoasting, lateral movement, credential dumping)
- 🛡️ **Implement defensive hardening** measures (gMSA, tiering model, LLMNR/NetBIOS disabling)
- 📊 **Monitor and detect** malicious activity using Sysmon, Windows Event Logs, and **Wazuh SIEM**

The lab reproduces a typical enterprise AD infrastructure and demonstrates the full attack lifecycle — from reconnaissance to domain compromise — followed by remediation and detection engineering.

---

## Architecture

### Virtual Machines

| VM | OS | IP | Role |
|----|----|----|------|
| **DC01** | Windows Server 2022 | `192.168.100.10` | Domain Controller + Wazuh Agent |
| **CLIENT01** | Windows 10/11 | `192.168.100.50` | Domain-joined workstation + Wazuh Agent |
| **KALI** | Kali Linux | `192.168.100.30` | Attack machine |
| **WAZUH** | Ubuntu Server 22.04 | `192.168.100.40` | Wazuh SIEM (Manager + Indexer + Dashboard) |

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
| **Monitoring** | **Wazuh SIEM** (Manager, Indexer, Dashboard), Windows Event Logs |
| **Scripting** | PowerShell, Bash |



## Quick Start

### 1. Clone the repository
git clone https://github.com/M-med/Active-Directory-Simulation-Attack-.git
cd Active-Directory-Simulation-Attack-

### 2. Read the installation guide
cat docs/installation.md

### 3. Deploy the lab (follow docs/installation.md)
Full setup: docs/installation.md


# ⚔️ Attack Simulation
The lab covers the following attack chain:

- Reconnaissance — BloodHound / SharpHound
- Kerberoasting — SPN enumeration and TGS hash extraction
- Hash Cracking — John the Ripper / Hashcat
- Lateral Movement — Impacket psexec / secretsdump

See docs/attack-scenarios.md for detailed steps.

# 🛡️ Defensive Hardening
After simulating attacks, the lab implements:
✅ gMSA (Group Managed Service Accounts) to eliminate Kerberoasting
✅ Tiering Model (Tier 0/1/2) to restrict privileged access
✅ LLMNR / NetBIOS disabling to prevent poisoning attacks
✅ Kerberos audit policies for detection

# 📊 Monitoring with Wazuh
- Wazuh Manager + Indexer + Dashboard deployed on Ubuntu Server
- Wazuh Agents installed on DC01 and CLIENT01
- Sysmon integration for deep process/network visibility

# 📚 References
- MITRE ATT&CK - Kerberoasting (T1558.003)
- Microsoft - Group Managed Service Accounts
- SwiftOnSecurity Sysmon Config
- Impacket Toolkit
- BloodHound
- Wazuh Documentation
- Custom detection rules for Kerberoasting (Event ID 4769 + RC4 encryption)
- MITRE ATT&CK mapping in all alerts
- Detection rules: rules/kerberoasting_rules.xml

Full guide: docs/installation-wazuh.md



# 👤 Author
Med MAMOR
- 💼 LinkedIn: linkedin.com/in/mohamed-mamor

---

<div align="center">
⭐ If you found this project useful, please consider giving it a star! ⭐
</div>
