
---

## 📄 `docs/architecture.md`

```markdown
# 🏗️ Architecture

## Overview

The lab is built on a fully isolated **Host-Only / Internal Network** to prevent any interaction with production networks. All virtual machines communicate on the `192.168.100.0/24` subnet.

---

## Virtual Machines

| VM Name | OS | IP Address | vCPU | RAM | Role |
|---------|----|-----------|------|-----|------|
| **DC01** | Windows Server 2022 | 192.168.100.10 | 2 | 4 GB | Domain Controller + Wazuh Agent |
| **CLIENT01** | Windows 10/11 | 192.168.100.50 | 2 | 2 GB | Domain-joined workstation + Wazuh Agent |
| **KALI** | Kali Linux | 192.168.100.30 | 2 | 2 GB | Attack machine |
| **WAZUH** | Ubuntu Server 22.04 | 192.168.100.40 | 2 | 4 GB | Wazuh SIEM (All-in-one) |

---

## Network Topology
┌─────────────────────────────────────────────────────────────┐
│ LAB-NET (192.168.100.0/24) │
│ │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
│ │ DC01 │ │ CLIENT01 │ │ KALI │ │
│ │ Win Server │ │ Windows 10 │ │ Kali Linux │ │
│ │ .10 │ │ .50 │ │ .30 │ │
│ │ │ │ │ │ │ │
│ │ AD DS │ │ Domain Join │ │ Attack Tools │ │
│ │ Sysmon │ │ Sysmon │ │ BloodHound │ │
│ │ Wazuh Agent │ │ Wazuh Agent │ │ Impacket │ │
│ └──────┬───────┘ └──────┬───────┘ └──────────────┘ │
│ │ │ │
│ └──────────┬───────┘ │
│ │ │
│ ▼ │
│ ┌──────────────────────────────┐ │
│ │ WAZUH SERVER │ │
│ │ Ubuntu Server │ │
│ │ .40 │ │
│ │ │ │
│ │ ┌────────────────────────┐ │ │
│ │ │ Wazuh Manager │ │ ← Rules & Decoders │
│ │ │ Wazuh Indexer │ │ ← Log storage (OpenSearch) │
│ │ │ Wazuh Dashboard │ │ ← Web UI (443) │
│ │ └────────────────────────┘ │ │
│ └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘




---

## Network Configuration

| Setting | Value |
|---------|-------|
| **Subnet** | 192.168.100.0/24 |
| **Gateway** | 192.168.100.1 (optional, not needed) |
| **DNS** | 192.168.100.10 (DC01) |
| **Network Type** | Host-Only / Internal Network |
| **Adapter** | Intel PRO/1000 MT Desktop |



## Active Directory Configuration

| Setting | Value |
|---------|-------|
| **Domain Name** | lab.local |
| **NetBIOS Name** | LAB |
| **Forest Level** | Windows Server 2016 |
| **DNS** | Integrated with AD DS |
| **Organizational Unit** | OU=LAB-Users,DC=lab,DC=local |



## Users & Accounts

| Account | Type | Password | Purpose |
|---------|------|----------|---------|
| `Administrator` | Domain Admin | `Admin@lab2024!` | DC management |
| `user1` | Standard user | `User@1234` | Normal user |
| `svc_sql` | Service account | `P@ssw0rd123` | Vulnerable SPN (Kerberoasting target) |
| `svc_sql_gmsa` | gMSA | Auto-managed | Hardened replacement |



## Detection & Monitoring Stack

| Component | Purpose |
|-----------|---------|
| **Sysmon** | Process creation, network connections, file changes |
| **auditpol** | Kerberos Service and Authentication auditing |
| **Wazuh Agent** | Collects Windows Event Logs and Sysmon telemetry |
| **Wazuh Manager** | Applies decoders and custom detection rules |
| **Wazuh Indexer** | Stores and indexes all security events (OpenSearch) |
| **Wazuh Dashboard** | Visualizes alerts, events, and MITRE ATT&CK mapping |



## Wazuh Communication Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| **1514** | TCP | Agent → Manager (event data) |
| **1515** | TCP | Agent enrollment (registration) |
| **55000** | TCP | Wazuh API |
| **443** | TCP | Wazuh Dashboard (HTTPS) |
| **9200** | TCP | Wazuh Indexer (OpenSearch) |



## Data Flow

1. **DC01** and **CLIENT01** generate Windows Security Events and Sysmon telemetry.
2. **Wazuh Agents** forward events to the Wazuh Manager on port `1514`.
3. The **Wazuh Manager** applies decoders and custom rules.
4. **Alerts** are indexed in the Wazuh Indexer and shown in the Dashboard.
5. **Kali** attacks trigger Event ID 4769 (Kerberoasting) and NTLM logons (Pass-the-Hash).
6. Custom rules alert on these events with **MITRE ATT&CK** tags.
7. Defensive hardening is applied on **DC01** to remediate vulnerabilities.

---

## MITRE ATT&CK Mapping

| Tactic | Technique | ID | Detection Rule |
|--------|-----------|-----|----------------|
| Credential Access | Kerberoasting | T1558.003 | 100001, 100002, 100003 |
| Credential Access | Golden Ticket | T1558.001 | 100004 |
| Lateral Movement | Pass the Hash | T1550.002 | 100005 |
| Discovery | Account Discovery | T1087 | Built-in |
| Execution | Windows Management Instrumentation | T1047 | Built-in |

---

## Security Considerations

- ⚠️ **Never connect this lab to a production network**
- ⚠️ **Use isolated Host-Only or Internal Network only**
- ⚠️ **All credentials in this lab are intentionally weak**
- ⚠️ **Take snapshots before running attacks**



