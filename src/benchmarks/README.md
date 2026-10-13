# Performance Benchmarks

This directory contains benchmarking scripts, experimental data, and evaluation reports comparing:
1. **Baseline Mode**: Standard unencrypted, unvalidated UDP DNS (port 53).
2. **Proposed Mode**: Authenticated Gateway-Assisted DNSSEC over TLS (port 8443).

### Metrics Collected
- End-to-end latency (median, p95)
- Client CPU time / cycle count
- Free heap memory and peak RAM usage
- Raw CSV trial outputs
