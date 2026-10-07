# 📊 Monitoring with Wazuh

## Overview

This section describes the deployment of **Wazuh SIEM** to monitor the Active Directory lab. Wazuh collects Windows Security events, Sysmon telemetry, and applies custom detection rules to identify Kerberoasting and lateral movement attacks.

The architecture uses a **single-node Wazuh server** (all-in-one: Manager + Indexer + Dashboard) deployed on Ubuntu Server, with Wazuh agents installed on the Domain Controller (DC01) and the Client workstation (CLIENT01).

---

## Architecture
┌─────────────────────────────────────────────────────────────┐
│ LAB-NET (192.168.100.0/24) │
│ │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
│ │ DC01 │ │ CLIENT01 │ │ KALI │ │
│ │ Win Server │ │ Windows 10 │ │ Kali Linux │ │
│ │ .10 │ │ .50 │ │ .30 │ │
│ │ │ │ │ │ │ │
│ │ Wazuh Agent │ │ Wazuh Agent │ │ Attack Tools │ │
│ │ Sysmon │ │ Sysmon │ │ │ │
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
│ │ │ Wazuh Manager │ │ │
│ │ │ Wazuh Indexer │ │ │
│ │ │ Wazuh Dashboard │ │ │
│ │ └────────────────────────┘ │ │
│ └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

### 1.2 Retrieve Credentials
After installation, the admin credentials are displayed at the end of the output. If missed, run:
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

### 1.3 Verify Installation
Access the dashboard:
https://192.168.100.40 -- admin as credentiels

## Step 2 — Deploy Wazuh Agent on DC01
### 2.1 Download the Windows Agent
From the Wazuh dashboard, navigate to Agents → Deploy new agent, select Windows, and enter 192.168.100.40 as the Wazuh Manager IP.
Alternatively, download directly on DC01:
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.7-1.msi" -OutFile "$env:TEMP\wazuh-agent.msi"

### 2.2 Install the Agent (Command Line)
Run as Administrator:
msiexec.exe /i "$env:TEMP\wazuh-agent.msi" /q WAZUH_MANAGER="192.168.100.40" WAZUH_AGENT_NAME="DC01"

### 2.3 Start the Agent
Start-Service wazuhsvc


## Step 3 — Deploy Wazuh Agent on CLIENT01
Repeat Step 2 with the agent name CLIENT01:
msiexec.exe /i "$env:TEMP\wazuh-agent.msi" /q WAZUH_MANAGER="192.168.100.40" WAZUH_AGENT_NAME="CLIENT01"
Start-Service wazuhsvc

## Step 4 — Configure Sysmon Integration
Wazuh can ingest Sysmon events to enrich detection capabilities. First, install Sysmon on DC01 and CLIENT01 (see 01-install-dc.ps1), then configure Wazuh to collect the Sysmon event channel.

### 4.1 Edit ossec.conf on DC01
Open C:\Program Files (x86)\ossec-agent\ossec.conf and add the Sysmon event channel inside <ossec_config>:
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>

### 4.2 Restart the Wazuh Agent
Restart-Service wazuhsvc

### 4.3 Verify Sysmon Events
In the Wazuh dashboard, search for sysmon in the Security Events module. You should see Sysmon Event ID 1 (Process Creation) and other events.

## Step 5 — Enable Kerberos Audit Policy on DC01
Kerberoasting detection relies on Windows Event ID 4769 (Kerberos Service Ticket Request). Enable the required audit subcategory:
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /get /category:"Account Logon"
gpupdate /force

## Step 6 — Deploy Custom Detection Rules
### 6.1 Copy the Rule File
Copy the custom rule file (rules/kerberoasting_rules.xml) to the Wazuh Manager:
sudo cp kerberoasting_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/kerberoasting_rules.xml

### 6.2 Restart Wazuh Manager
sudo systemctl restart wazuh-manager

### 6.3 Verify Rules Are Loaded
sudo /var/ossec/bin/wazuh-logtest --Paste a sample Event ID 4769 log to test the rule. The rule should trigger an alert.

## Step 7 — Verify Detection
Run the Kerberoasting attack script from Kali:
./scripts/bash/01-kerberoasting.sh

Then check the Wazuh dashboard:
- Go to Security Events → Events
- Search for rule.id:100001 or Kerberoasting
- You should see an alert with level 12 (High severity)


