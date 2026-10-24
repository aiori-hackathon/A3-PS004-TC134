#!/usr/bin/env bash
# ==============================================================================
# PS-004: Automated Controlled DNSSEC Lab Setup Script
# Configures Authoritative BIND (port 5300) and Validating Unbound (port 5353)
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================================${NC}"
echo -e "${BLUE}  PS-004: Setting Up Controlled DNSSEC Test Environment on Fedora  ${NC}"
echo -e "${BLUE}====================================================================${NC}"

# 1. Check Root Privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] This setup script must be run as root (use sudo ./setup_dnssec_lab.sh).${NC}"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DNS_LAB_DIR="${REPO_ROOT}/src/dns-lab"
GATEWAY_DIR="${REPO_ROOT}/src/gateway"
VAR_NAMED="/var/named"
KEYS_DIR="${DNS_LAB_DIR}/keys"

echo -e "${GREEN}[1/7] Ensuring required tools and directories are present...${NC}"
mkdir -p "${KEYS_DIR}"
mkdir -p "/etc/unbound"
mkdir -p "${VAR_NAMED}/data"

# 2. Generate Cryptographic DNSSEC Keys (Algorithm 13: ECDSAP256SHA256)
echo -e "${GREEN}[2/7] Generating DNSSEC Cryptographic Key Pairs (Algorithm 13: ECDSA P-256)...${NC}"
cd "${KEYS_DIR}"
rm -f Kiotlab.internal.*

# Generate Key Signing Key (KSK - Flags 257)
KSK_FILE=$(dnssec-keygen -a ECDSAP256SHA256 -f KSK -n ZONE iotlab.internal)
echo -e "  Generated KSK: ${KSK_FILE}"

# Generate Zone Signing Key (ZSK - Flags 256)
ZSK_FILE=$(dnssec-keygen -a ECDSAP256SHA256 -n ZONE iotlab.internal)
echo -e "  Generated ZSK: ${ZSK_FILE}"

# 3. Assemble and Sign Zone: iotlab.internal
echo -e "${GREEN}[3/7] Assembling and cryptographically signing iotlab.internal zone...${NC}"
ZONE_RAW="${DNS_LAB_DIR}/zones/db.iotlab.internal"
ZONE_SIGNED="${DNS_LAB_DIR}/zones/db.iotlab.internal.signed"
ZONE_TEMP="${KEYS_DIR}/db.iotlab.internal.temp"

# Merge zone records with public DNSKEYs
cat "${ZONE_RAW}" > "${ZONE_TEMP}"
echo "" >> "${ZONE_TEMP}"
echo "; DNSSEC Public Keys" >> "${ZONE_TEMP}"
cat "${KEYS_DIR}/${KSK_FILE}.key" >> "${ZONE_TEMP}"
cat "${KEYS_DIR}/${ZSK_FILE}.key" >> "${ZONE_TEMP}"

# Sign the zone with KSK and ZSK (valid for 30 days)
dnssec-signzone -S -K "${KEYS_DIR}" -o iotlab.internal -f "${ZONE_SIGNED}" "${ZONE_TEMP}"
echo -e "  Zone signed successfully: ${ZONE_SIGNED}"

# 4. Create the BOGUS Condition (Deliberate Signature Tampering)
echo -e "${GREEN}[4/7] Inducing controlled BOGUS condition (simulating DNS tampering/spoofing)...${NC}"
# Tamper with the A record of bogus.iotlab.internal in the signed file without updating the RRSIG!
# RFC 4035 §5.3: Signature verification will fail because the data hash no longer matches the RRSIG signature!
sed -i 's/bogus.iotlab.internal.\s*300\s*IN\s*A\s*192.168.1.102/bogus.iotlab.internal. 300 IN A 192.168.1.222/' "${ZONE_SIGNED}"
echo -e "  Tampered A record for bogus.iotlab.internal (IP changed to 192.168.1.222 without re-signing)."

# 5. Deploy Zones to BIND Authoritative Server
echo -e "${GREEN}[5/7] Deploying zone files and configuring BIND (named on port 5300)...${NC}"
cp "${ZONE_SIGNED}" "${VAR_NAMED}/db.iotlab.internal.signed"
cp "${DNS_LAB_DIR}/zones/db.insecure.iotlab.internal" "${VAR_NAMED}/db.insecure.iotlab.internal"
cp "${DNS_LAB_DIR}/config/named.conf" "/etc/named.conf"

chown -R named:named "${VAR_NAMED}"
chown named:named "/etc/named.conf"
chmod 640 "/etc/named.conf"

# Verify BIND configuration syntax
named-checkconf /etc/named.conf

# Restart and enable BIND service
systemctl restart named
echo -e "  BIND authoritative server running on 127.0.0.1:5300."

# 6. Configure Unbound Validating Resolver with Local Trust Anchor
echo -e "${GREEN}[6/7] Configuring Unbound with Lab Trust Anchor (port 5353)...${NC}"
TRUST_ANCHOR_CONF="/etc/unbound/local-trust-anchor.conf"

# Extract the KSK DNSKEY record format for Unbound's trust-anchor directive
KSK_PUB_KEY=$(grep -v '^;' "${KEYS_DIR}/${KSK_FILE}.key" | tr -d '\n' | sed 's/  */ /g')
cat <<EOF > "${TRUST_ANCHOR_CONF}"
server:
    trust-anchor: "${KSK_PUB_KEY}"
EOF

chmod 644 "${TRUST_ANCHOR_CONF}"
chown unbound:unbound "${TRUST_ANCHOR_CONF}"

# Deploy Unbound configuration
cp "${GATEWAY_DIR}/unbound/unbound.conf" "/etc/unbound/unbound.conf"
chown unbound:unbound "/etc/unbound/unbound.conf"

# Verify Unbound configuration
unbound-checkconf /etc/unbound/unbound.conf

# Restart Unbound
systemctl restart unbound
echo -e "  Unbound validating resolver running on 127.0.0.1:5353."

# 7. Verification Summary
echo -e "${BLUE}====================================================================${NC}"
echo -e "${GREEN}  SUCCESS: Controlled DNSSEC Lab is Ready!${NC}"
echo -e "${BLUE}====================================================================${NC}"
echo -e "Run the test script to verify all 3 states:"
echo -e "  ${YELLOW}${REPO_ROOT}/src/tests/test_dnssec_states.sh${NC}"
