# Performance Benchmarking Suite (`src/benchmarks/`)

This directory contains benchmarking harnesses, telemetry collectors, and automated statistical analysis scripts evaluating the client-side resource overhead and latency trade-offs.

---

## Experimental Design

The performance of the proposed architecture is evaluated against an identical baseline across $\ge 100$ repeated trials under controlled LAN conditions:

1. **Baseline Mode**: Conventional unencrypted, unvalidated DNS over UDP port 53 (`lwip_getaddrinfo` on ESP32).
2. **Proposed Mode**: Authenticated Gateway-Assisted DNSSEC over TLS port 8443 (ESP32 $\rightarrow$ FastAPI $\rightarrow$ Unbound).

---

## Metrics Captured

| Metric | Measurement Mechanism | Unit | Significance |
| :--- | :--- | :---: | :--- |
| **End-to-End Latency** | `esp_timer_get_time()` | Microseconds ($\mu s$) / Milliseconds ($ms$) | Measures round-trip lookup overhead (TCP + TLS + DNSSEC resolution). |
| **Statistical Latency** | Median ($p50$), 95th Percentile ($p95$), IQR | Milliseconds ($ms$) | Evaluates latency consistency and tail-latency outliers. |
| **Client Memory (Heap)** | `esp_get_free_heap_size()` | Bytes / Kilobytes ($KB$) | Dynamic RAM footprint before and after query resolution. |
| **Client Peak Memory** | `esp_get_minimum_free_heap_size()` | Bytes / Kilobytes ($KB$) | Minimum lifetime watermark of free heap; evaluates risk of stack/heap exhaustion. |
| **Client CPU Cost** | `esp_cpu_get_cycle_count()` | Clock cycles | Processing effort for TLS handshake, symmetric crypto, and JSON parsing. |
| **Gateway Memory & CPU** | Linux `psutil` sampling | $MB$ / % CPU | Edge gateway resource footprint under load. |

---

## Data Management & Analysis

- **Raw Data**: Stored in `data/baseline_trials.csv` and `data/gateway_trials.csv`.
- **Analysis Script**: `scripts/analyze_benchmarks.py` generates statistical comparison tables and plots for the technical report.
