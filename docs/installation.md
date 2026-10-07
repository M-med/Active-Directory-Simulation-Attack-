# 🚀 Installation Guide

## Prerequisites

- **VirtualBox** 7.x installed
- **18 GB RAM** minimum (4 GB DC + 2 GB Client + 2 GB Kali + 4 GB Wazuh + 2 GB OS overhead)
- **120 GB free disk space**
- Basic knowledge of Windows Server and Linux

---

## Phase 1 — VM Creation & Network Setup

### 1.1 Create VMs via VirtualBox CLI

#### Create Domain Controller
VBoxManage createvm --name "DC-lab" --ostype "Windows2022_64" --register
VBoxManage modifyvm "DC-lab" --memory 4096 --cpus 2 --nic1 intnet --intnet1 "lab-net"

#### Create Client
VBoxManage createvm --name "Client-lab" --ostype "Windows10_64" --register
VBoxManage modifyvm "Client-lab" --memory 2048 --cpus 2 --nic1 intnet --intnet1 "lab-net"

#### Create Kali
VBoxManage createvm --name "Kali-lab" --ostype "Debian_64" --register
VBoxManage modifyvm "Kali-lab" --memory 2048 --cpus 2 --nic1 intnet --intnet1 "lab-net"

#### Create Wazuh Server
VBoxManage createvm --name "Wazuh-lab" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "Wazuh-lab" --memory 4096 --cpus 2 --nic1 intnet --intnet1 "lab-net"


### 1.2 Configure DC Network (PowerShell on DC01)
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.100.10 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "127.0.0.1"

### 1.3 Promote DC to Domain Controller
$SecurePass = ConvertTo-SecureString "Admin@lab2024!" -AsPlainText -Force
Install-ADDSForest `
  -DomainName "lab.local" `
  -DomainNetbiosName "LAB" `
  -SafeModeAdministratorPassword $SecurePass `
  -Force -NoRebootOnCompletion
Restart-Computer

### 1.4 Join Client to Domain
- On CLIENT01
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.100.50 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses "192.168.100.10"

Add-Computer -DomainName "lab.local" -Credential (Get-Credential "LAB\Administrator") -Restart

### 1.5 Configure Kali Network
// # /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.100.30
    netmask 255.255.255.0

sudo systemctl restart networking

### 1.6 Configure Wazuh Server Network
// # /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    ens33:
      dhcp4: no
      addresses: [192.168.100.40/24]
  version: 2

sudo netplan apply

## Phase 2 — Active Directory Configuration (Vulnerable Setup)
### 2.1 Create Users and Vulnerable Service Account
Run the script: .\scripts\powershell\02-create-users.ps1
Or manually: 
New-ADOrganizationalUnit -Name "LAB-Users" -Path "DC=lab,DC=local"

New-ADUser -Name "user1" -SamAccountName "user1" `
  -UserPrincipalName "user1@lab.local" `
  -Path "OU=LAB-Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "User@1234" -AsPlainText -Force) `
  -Enabled $true -PasswordNeverExpires $true

New-ADUser -Name "svc_sql" -SamAccountName "svc_sql" `
  -UserPrincipalName "svc_sql@lab.local" `
  -Path "OU=LAB-Users,DC=lab,DC=local" `
  -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
  -Enabled $true -PasswordNeverExpires $true

setspn -A MSSQLSvc/sql.lab.local:1433 lab.local\svc_sql

### 2.2 Install Sysmon
Invoke-WebRequest -Uri "https://live.sysinternals.com/sysmon64.exe" -OutFile "C:\sysmon64.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "C:\sysmon-config.xml"

C:\sysmon64.exe -accepteula -i C:\sysmon-config.xml
Get-Service -Name Sysmon64

### 2.3 Enable Kerberos Auditing
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /get /category:"Account Logon"
gpupdate /force

## Phase 3 — Tooling on Kali
### 3.1 Install Impacket
sudo apt update
sudo apt install -y python3-pip
pip3 install impacket

### 3.2 Install BloodHound
sudo apt install -y bloodhound neo4j
sudo neo4j start
bloodhound &

### 3.3 Install John / Hashcat
sudo apt install -y john hashcat

## Phase 4 — Wazuh SIEM Deployment
See the dedicated guide: docs/installation-wazuh.md

Quick steps:
// # On Wazuh server (Ubuntu)
curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh
sudo bash ./wazuh-install.sh -a

// # Retrieve admin credentials
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

Then on Windows endpoints: .\scripts\powershell\04-install-wazuh-agent.ps1 -WazuhManagerIP "192.168.100.40"
Finally, deploy the custom rules on the Wazuh Manager: 
sudo cp rules/kerberoasting_rules.xml /var/ossec/etc/rules/
sudo chown wazuh:wazuh /var/ossec/etc/rules/kerberoasting_rules.xml
sudo systemctl restart wazuh-manager

## ✅ Verification Checklist
- ping 192.168.100.10 from CLIENT01 → OK
- GetUserSPNs.py returns a hash for svc_sql
- john cracks the hash → P@ssw0rd123
- impacket-psexec gives a shell on DC
- Wazuh agent status is Active on both DC01 and CLIENT01
- Wazuh dashboard shows rule.id:100001 after Kerberoasting
- MITRE ATT&CK tag T1558.003 is visible on the alert

## 🔄 Snapshots
Before running attacks:
VBoxManage snapshot "DC-lab" take "DC-clean-base" --pause
VBoxManage snapshot "Client-lab" take "Client-clean" --pause
VBoxManage snapshot "Kali-lab" take "Kali-tools" --pause
VBoxManage snapshot "Wazuh-lab" take "Wazuh-clean" --pause

Restore if needed:
VBoxManage snapshot "DC-lab" restore "DC-clean-base"

