<#
.SYNOPSIS
    Creates vulnerable users and service accounts in AD.
.DESCRIPTION
    - Creates OU LAB-Users
    - Creates user1 (standard user)
    - Creates svc_sql (Kerberoastable service account)
    - Registers SPN for Kerberoasting
.NOTES
    Run as Domain Admin on DC01.
#>

# ============================================================
# 1. Create OU
# ============================================================
Write-Host "[*] Creating OU LAB-Users..." -ForegroundColor Cyan

New-ADOrganizationalUnit -Name "LAB-Users" -Path "DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false

# ============================================================
# 2. Create normal user
# ============================================================
Write-Host "[*] Creating user1..." -ForegroundColor Cyan

New-ADUser -Name "user1" `
    -GivenName "User" `
    -Surname "One" `
    -SamAccountName "user1" `
    -UserPrincipalName "user1@lab.local" `
    -Path "OU=LAB-Users,DC=lab,DC=local" `
    -AccountPassword (ConvertTo-SecureString "User@1234" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

Write-Host "[+] user1 created (password: User@1234)" -ForegroundColor Green

# ============================================================
# 3. Create vulnerable service account
# ============================================================
Write-Host "[*] Creating svc_sql (vulnerable)..." -ForegroundColor Cyan

New-ADUser -Name "svc_sql" `
    -SamAccountName "svc_sql" `
    -UserPrincipalName "svc_sql@lab.local" `
    -Path "OU=LAB-Users,DC=lab,DC=local" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

Write-Host "[+] svc_sql created (password: P@ssw0rd123)" -ForegroundColor Green

# ============================================================
# 4. Register SPN (Kerberoasting vulnerability)
# ============================================================
Write-Host "[*] Registering SPN for svc_sql..." -ForegroundColor Cyan

setspn -A MSSQLSvc/sql.lab.local:1433 lab.local\svc_sql

Write-Host "[*] Verifying SPN..." -ForegroundColor Cyan
setspn -L svc_sql

Write-Host "[+] SPN registered. svc_sql is now Kerberoastable." -ForegroundColor Yellow
