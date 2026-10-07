<#
.SYNOPSIS
    Verifies that hardening measures are applied correctly.
.DESCRIPTION
    - Checks gMSA presence
    - Checks Kerberos audit policy
    - Checks LLMNR status
    - Checks Sysmon service
    - Checks Wazuh agent service
.NOTES
    Run as Administrator on DC01.
#>

function Test-Hardening {
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "       HARDENING VERIFICATION - DC01         " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan

    # 1. Check gMSA
    Write-Host "`n[1] Checking gMSA..." -ForegroundColor Yellow
    $gmsa = Get-ADServiceAccount -Filter {Name -like "*gmsa*"} -ErrorAction SilentlyContinue
    if ($gmsa) {
        Write-Host "    [OK] gMSA present: $($gmsa.Name)" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] No gMSA found" -ForegroundColor Red
    }

    # 2. Check Kerberos audit
    Write-Host "`n[2] Checking Kerberos audit..." -ForegroundColor Yellow
    $audit = auditpol /get /subcategory:"Kerberos Service Ticket Operations" | Select-String "Success"
    if ($audit) {
        Write-Host "    [OK] Kerberos audit active" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] Kerberos audit missing" -ForegroundColor Red
    }

    # 3. Check LLMNR
    Write-Host "`n[3] Checking LLMNR..." -ForegroundColor Yellow
    $llmnr = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
        -Name "EnableMulticast" -ErrorAction SilentlyContinue
    if ($llmnr.EnableMulticast -eq 0) {
        Write-Host "    [OK] LLMNR disabled" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] LLMNR active" -ForegroundColor Red
    }

    # 4. Check Sysmon
    Write-Host "`n[4] Checking Sysmon..." -ForegroundColor Yellow
    $sysmon = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue
    if ($sysmon -and $sysmon.Status -eq "Running") {
        Write-Host "    [OK] Sysmon running" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] Sysmon not running" -ForegroundColor Red
    }

    # 5. Check Wazuh agent
    Write-Host "`n[5] Checking Wazuh agent..." -ForegroundColor Yellow
    $wazuh = Get-Service -Name wazuhsvc -ErrorAction SilentlyContinue
    if ($wazuh -and $wazuh.Status -eq "Running") {
        Write-Host "    [OK] Wazuh agent running" -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] Wazuh agent not running" -ForegroundColor Red
    }

    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host "            VERIFICATION COMPLETE            " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
}

Test-Hardening
