# Controlled DNSSEC Test Environment

This directory contains configuration and scripts for the local authoritative DNS server and controlled test zones.

### Test Scenarios
1. **`secure.iotlab.internal`**: Correctly signed with valid DNSKEY, DS, and RRSIG records.
2. **`insecure.iotlab.internal`**: Legitimately unsigned domain with valid proof of non-existence of DS.
3. **`bogus.iotlab.internal`**: Signed domain with deliberately corrupted RRSIG to simulate tampering.
