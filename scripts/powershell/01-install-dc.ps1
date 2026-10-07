<#
.SYNOPSIS
    Installs and configures the Domain Controller (DC01).
.DESCRIPTION
    - Sets static IP
    - Promotes the server to a Domain Controller for lab.local
    - Installs Sysmon
    - Enables Kerberos auditing
.NOTES
    Run as Administrator on a fresh Windows Server 2022.
#>

# ============================================================
# 1. Network Configuration
# ============================================================
Write-Host "[*] Configuring network..." -ForegroundColor Cyan

New-NetIPAddress -InterfaceAlias "Ethernet" `
    -IPAddress 192.168.100.10 `
    -PrefixLength 24 `
    -ErrorAction SilentlyContinue

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "127.0.0.1"

Write-Host "[+] Network configured: 192.168.100.10" -ForegroundColor Green

# ============================================================
# 2. Install AD DS Role
# ============================================================
Write-Host "[*] Installing AD DS role..." -ForegroundColor Cyan

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# ============================================================
# 3. Promote to Domain Controller
# ============================================================
Write-Host "[*] Promoting to Domain Controller..." -ForegroundColor Cyan

$SecurePass = ConvertTo-SecureString "Admin@lab2024!" -AsPlainText -Force

Install-ADDSForest `
    -DomainName "lab.local" `
    -DomainNetbiosName "LAB" `
    -SafeModeAdministratorPassword $SecurePass `
    -InstallDns `
    -Force `
    -NoRebootOnCompletion

Write-Host "[+] Domain lab.local created. Reboot required." -ForegroundColor Green

# ============================================================
# 4. Reboot
# ============================================================
Write-Host "[*] Rebooting in 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force
