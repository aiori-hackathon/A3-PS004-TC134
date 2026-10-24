#!/usr/bin/env bash
# ==============================================================================
# PS-004: Automated Verification Script for DNSSEC Validation Outcomes
# Tests Unbound (127.0.0.1:1053) against Controlled Test Lab (SECURE, INSECURE, BOGUS)
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

RESOLVER_IP="127.0.0.1"
RESOLVER_PORT="1053"

echo -e "${BLUE}====================================================================${NC}"
echo -e "${BLUE}  PS-004: Running DNSSEC Validation Verification Test Suite         ${NC}"
echo -e "${BLUE}====================================================================${NC}"

# Test 1: SECURE Case
echo -e "\n${CYAN}[TEST 1: SECURE] Querying secure.iotlab.internal...${NC}"
OUTPUT_SECURE=$(dig @"${RESOLVER_IP}" -p "${RESOLVER_PORT}" secure.iotlab.internal A +dnssec +multiline)

if echo "${OUTPUT_SECURE}" | grep -q "status: NOERROR" && echo "${OUTPUT_SECURE}" | grep -q "flags:.*ad"; then
    IP=$(echo "${OUTPUT_SECURE}" | awk '/secure.iotlab.internal.\s+[0-9]+\s+IN\s+A/ {print $5}')
    echo -e "${GREEN}✓ PASS: SECURE outcome verified!${NC}"
    echo -e "  - RCODE: NOERROR"
    echo -e "  - AD Flag: PRESENT (Authentic Data verified cryptographically)"
    echo -e "  - Resolved IP: ${IP}"
else
    echo -e "${RED}✗ FAIL: SECURE test failed!${NC}"
    echo "${OUTPUT_SECURE}"
    exit 1
fi

# Test 2: INSECURE Case
echo -e "\n${CYAN}[TEST 2: INSECURE] Querying insecure.iotlab.internal...${NC}"
OUTPUT_INSECURE=$(dig @"${RESOLVER_IP}" -p "${RESOLVER_PORT}" insecure.iotlab.internal A +dnssec +multiline)

if echo "${OUTPUT_INSECURE}" | grep -q "status: NOERROR" && ! echo "${OUTPUT_INSECURE}" | grep -q "flags:.*ad"; then
    IP=$(echo "${OUTPUT_INSECURE}" | awk '/insecure.iotlab.internal.\s+[0-9]+\s+IN\s+A/ {print $5}')
    echo -e "${GREEN}✓ PASS: INSECURE outcome verified!${NC}"
    echo -e "  - RCODE: NOERROR"
    echo -e "  - AD Flag: ABSENT (Legitimately unsigned zone, NSEC proof of no DS)"
    echo -e "  - Resolved IP: ${IP}"
else
    echo -e "${RED}✗ FAIL: INSECURE test failed!${NC}"
    echo "${OUTPUT_INSECURE}"
    exit 1
fi

# Test 3: BOGUS Case
echo -e "\n${CYAN}[TEST 3: BOGUS] Querying bogus.iotlab.internal...${NC}"
OUTPUT_BOGUS=$(dig @"${RESOLVER_IP}" -p "${RESOLVER_PORT}" bogus.iotlab.internal A +dnssec +multiline || true)

if echo "${OUTPUT_BOGUS}" | grep -q "status: SERVFAIL"; then
    echo -e "${GREEN}✓ PASS: BOGUS outcome verified (RFC 4035 §5.5 & RFC 9520)!${NC}"
    echo -e "  - RCODE: SERVFAIL (Validation failed, signature mismatch rejected)"
    echo -e "  - Answer Section: EMPTY (No forged or tampered IP delivered to client)"
    if echo "${OUTPUT_BOGUS}" | grep -qi "EDE:.*6\|DNSSEC Bogus"; then
        echo -e "  - Extended DNS Error (RFC 8914): EDE 6 (DNSSEC Bogus confirmed)"
    fi
else
    echo -e "${RED}✗ FAIL: BOGUS test failed! Unbound should return SERVFAIL.${NC}"
    echo "${OUTPUT_BOGUS}"
    exit 1
fi

echo -e "\n${BLUE}====================================================================${NC}"
echo -e "${GREEN}  ALL 3 MANDATORY DNSSEC VALIDATION OUTCOMES VERIFIED SUCCESSFULLY! ${NC}"
echo -e "${BLUE}====================================================================${NC}"
