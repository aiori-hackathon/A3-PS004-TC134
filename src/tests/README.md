# Automated Test Suite (`src/tests/`)

This directory contains automated functional, security, and protocol-compliance test suites for evaluating the gateway-assisted DNSSEC prototype.

---

## Test Categories

### 1. Functional DNSSEC Validation Tests (`test_dnssec_states.py`)
- **T1**: Verify resolution of `secure.iotlab.internal` returns status `SECURE`, `ad_flag=True`, and valid IP addresses.
- **T2**: Verify resolution of `insecure.iotlab.internal` returns status `INSECURE`, `ad_flag=False`, and valid IP addresses.
- **T3**: Verify resolution of `bogus.iotlab.internal` returns status `BOGUS`, `ad_flag=False`, and **strictly empty data/no IP address**.

### 2. Transport & Identity Security Tests (`test_security.py`)
- **T4**: Client connects to gateway presenting a valid certificate; handshake succeeds, query processed.
- **T5**: Client connects to a rogue gateway presenting a self-signed untrusted certificate; **client strictly rejects connection during TLS handshake**.
- **T6**: Client connects to a gateway presenting a certificate with mismatched hostname/SAN; **client strictly aborts**.
- **T7**: Attempted plaintext HTTP downgrade on port 8443; connection immediately rejected.

### 3. Protocol & Resiliency Tests (`test_negative_caching.py`)
- **RFC 9520 Compliance**: Rapid sequential queries to `bogus.iotlab.internal` verify that Unbound and Gateway cache the validation failure (1s–300s) and do not flood upstream authoritative nameservers.
- **Timeout Handling**: Simulated packet drop to upstream authoritative server verifies safe gateway timeout and graceful operational error reporting.

---

## Running the Automated Test Suite

```bash
# Activate Python environment
source .venv/bin/activate

# Run full pytest suite with verbose output
pytest -v src/tests/
```
