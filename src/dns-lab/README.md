# Controlled DNSSEC Test Environment (`src/dns-lab/`)

This directory contains the authoritative DNS server configurations, zone signing scripts, cryptographic key management routines, and zone definitions for the controlled laboratory environment.

---

## Controlled Test Scenarios

To ensure scientific rigor and complete reproducibility, validation outcomes do not depend on external, fluctuating public Internet zones. A local authoritative DNS server (running Knot DNS, NSD, or BIND 9 on `127.0.0.1:5300`) serves three controlled test zones:

| Test Zone | Status | Description & Configuration | Expected Unbound Resolver Outcome |
| :--- | :---: | :--- | :--- |
| **`secure.iotlab.internal`** | `SECURE` | Properly signed with valid KSK and ZSK key pairs; matching DS record published in parent zone. | `AD` flag = 1, `RCODE` = 0 (`NOERROR`), IP address returned. |
| **`insecure.iotlab.internal`** | `INSECURE` | Legitimately unsigned delegated zone; parent zone contains signed proof of non-existence of DS (`NSEC`). | `AD` flag = 0, `RCODE` = 0 (`NOERROR`), IP address returned. |
| **`bogus.iotlab.internal`** | `BOGUS` | Signed zone with deliberately corrupted RRSIG signature (or key mismatch) simulating on-path cache poisoning or tampering. | `AD` flag = 0, `RCODE` = 2 (`SERVFAIL`), Extended DNS Error `EDE: 6` (DNSSEC Bogus). |

---

## Directory Layout

```
dns-lab/
├── zones/
│   ├── iotlab.internal.zone          # Root lab parent zone
│   ├── secure.iotlab.internal.zone   # Secure child zone
│   ├── insecure.iotlab.internal.zone # Unsigned child zone
│   └── bogus.iotlab.internal.zone    # Tampered signature child zone
├── keys/
│   ├── generate_keys.sh              # Generates KSK and ZSK key pairs (ECDSA P-256 / Algorithm 13)
│   └── lab_trust_anchor.ds           # Delegation signer record for Unbound
├── config/
│   └── authoritative.conf            # Authoritative server configuration (port 5300)
├── sign_zones.sh                     # Automated zone signing and signature corruption script
└── start_authoritative.sh            # Service launcher script
```

---

## Verification with `dig`

```bash
# 1. Test SECURE zone (expect AD flag)
dig @127.0.0.1 -p 5353 secure.iotlab.internal A +dnssec

# 2. Test INSECURE zone (expect NOERROR, no AD flag)
dig @127.0.0.1 -p 5353 insecure.iotlab.internal A +dnssec

# 3. Test BOGUS zone (expect SERVFAIL, EDE code 6)
dig @127.0.0.1 -p 5353 bogus.iotlab.internal A +dnssec
```
