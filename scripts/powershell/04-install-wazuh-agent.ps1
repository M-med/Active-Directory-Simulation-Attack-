<#
.SYNOPSIS
    Installs and configures the Wazuh agent on a Windows endpoint.
.DESCRIPTION
    - Downloads the Wazuh agent MSI
    - Installs it with the Wazuh Manager IP
    - Starts the Wazuh service
    - Adds Sysmon event channel to ossec.conf
.NOTES
    Run as Administrator on DC01 or CLIENT01.
#>

param(
    [string]$WazuhManagerIP = "192.168.100.40",
    [string]$AgentName = $env:COMPUTERNAME,
    [string]$MsiUrl = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.7-1.msi"
)

# ============================================================
# 1. Download the Wazuh agent
# ============================================================
Write-Host "[*] Downloading Wazuh agent..." -ForegroundColor Cyan

$MsiPath = "$env:TEMP\wazuh-agent.msi"
Invoke-WebRequest -Uri $MsiUrl -OutFile $MsiPath

if (-not (Test-Path $MsiPath)) {
    Write-Host "[!] Download failed." -ForegroundColor Red
    exit 1
}

Write-Host "[+] Agent downloaded: $MsiPath" -ForegroundColor Green

# ============================================================
# 2. Install the agent silently
# ============================================================
Write-Host "[*] Installing Wazuh agent..." -ForegroundColor Cyan

$InstallArgs = @(
    "/i", "`"$MsiPath`"",
    "/q",
    "WAZUH_MANAGER=`"$WazuhManagerIP`"",
    "WAZUH_AGENT_NAME=`"$AgentName`""
)

Start-Process msiexec.exe -ArgumentList $InstallArgs -Wait -NoNewWindow

Write-Host "[+] Agent installed." -ForegroundColor Green

# ============================================================
# 3. Start the Wazuh service
# ============================================================
Write-Host "[*] Starting Wazuh service..." -ForegroundColor Cyan

Start-Service wazuhsvc -ErrorAction SilentlyContinue
Set-Service wazuhsvc -StartupType Automatic

Write-Host "[+] Wazuh service started." -ForegroundColor Green

# ============================================================
# 4. Add Sysmon event channel to ossec.conf
# ============================================================
$OssecConf = "C:\Program Files (x86)\ossec-agent\ossec.conf"

if (Test-Path $OssecConf) {
    $Content = Get-Content $OssecConf -Raw

    if ($Content -notmatch "Microsoft-Windows-Sysmon/Operational") {
        Write-Host "[*] Adding Sysmon event channel to ossec.conf..." -ForegroundColor Cyan

        $SysmonBlock = @"
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
</ossec_config>
"@

        $Content = $Content -replace "</ossec_config>", $SysmonBlock
        Set-Content -Path $OssecConf -Value $Content -Encoding UTF8

        Write-Host "[+] Sysmon channel added." -ForegroundColor Green
    } else {
        Write-Host "[*] Sysmon channel already present." -ForegroundColor Yellow
    }

    # Restart the agent to apply changes
    Restart-Service wazuhsvc -ErrorAction SilentlyContinue
    Write-Host "[+] Wazuh agent restarted." -ForegroundColor Green
} else {
    Write-Host "[!] ossec.conf not found. Check installation path." -ForegroundColor Red
}

Write-Host "[+] Wazuh agent setup complete." -ForegroundColor Green
