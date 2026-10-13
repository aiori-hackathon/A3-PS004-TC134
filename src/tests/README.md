# Automated Test Suite

This directory contains test automation scripts verifying system security and correctness:
- **`test_dnssec_states.py`**: Automated queries for `SECURE`, `INSECURE`, and `BOGUS` zones.
- **`test_security.py`**: Tests proving rejection of bogus answers and rejection of unauthenticated gateway connections.
- **`test_negative_caching.py`**: Tests proving compliance with RFC 9520 (negative caching of validation failures).
