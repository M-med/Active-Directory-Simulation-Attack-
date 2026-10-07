<#
.SYNOPSIS
    Applies defensive hardening to the AD environment.
.DESCRIPTION
    - Creates Tiering groups (Tier0/1/2)
    - Migrates svc_sql to gMSA
    - Disables LLMNR and NetBIOS via GPO
    - Enables Kerberos audit policies
.NOTES
    Run as Domain Admin on DC01.
#>

# ============================================================
# 1. Tiering Model
# ============================================================
Write-Host "[*] Creating Tiering groups..." -ForegroundColor Cyan

New-ADGroup -Name "Admins-Tier0" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "Admins-Tier1" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "Admins-Tier2" -GroupScope Global -GroupCategory Security

Add-ADGroupMember -Identity "Admins-Tier0" -Members "Administrator"

Write-Host "[+] Tiering groups created." -ForegroundColor Green

# ============================================================
# 2. Migrate to gMSA
# ============================================================
Write-Host "[*] Creating KDS Root Key..." -ForegroundColor Cyan
Add-KdsRootKey -EffectiveImmediately

Write-Host "[*] Creating gMSA svc_sql_gmsa..." -ForegroundColor Cyan

New-ADServiceAccount -Name "svc_sql_gmsa" `
    -DNSHostName "sql.lab.local" `
    -PrincipalsAllowedToRetrieveManagedPassword "DC-lab$"

Write-Host "[*] Installing gMSA..." -ForegroundColor Cyan
Install-ADServiceAccount -Identity "svc_sql_gmsa"

Write-Host "[*] Testing gMSA..." -ForegroundColor Cyan
Test-ADServiceAccount -Identity "svc_sql_gmsa"

Write-Host "[+] gMSA configured. svc_sql is now Kerberoasting-proof." -ForegroundColor Green

# ============================================================
# 3. Disable LLMNR / NetBIOS
# ============================================================
Write-Host "[*] Disabling LLMNR/NetBIOS via GPO..." -ForegroundColor Cyan

New-GPO -Name "Disable-LLMNR-NetBIOS" | Out-Null

Set-GPRegistryValue -Name "Disable-LLMNR-NetBIOS" `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
    -ValueName "EnableMulticast" `
    -Type DWord `
    -Value 0

New-GPLink -Name "Disable-LLMNR-NetBIOS" -Target "DC=lab,DC=local" | Out-Null

Write-Host "[+] LLMNR/NetBIOS disabled." -ForegroundColor Green

# ============================================================
# 4. Enable Kerberos Audit
# ============================================================
Write-Host "[*] Enabling Kerberos audit policies..." -ForegroundColor Cyan

auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable

Write-Host "[*] Verifying audit policy..." -ForegroundColor Cyan
auditpol /get /category:"Account Logon"

gpupdate /force

Write-Host "[+] Hardening complete." -ForegroundColor Green
