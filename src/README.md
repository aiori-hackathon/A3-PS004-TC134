# Source Code Directory

This directory contains the complete source code, configuration files, test scripts, and deliverables for **PS-004: Authenticated Gateway-Assisted DNSSEC for IoT Clients**.

---

## Directory Structure

```
src/
├── firmware/         # ESP32-WROOM-32 IoT client implementation (ESP-IDF C/C++)
├── gateway/          # FastAPI gateway service and Unbound validating resolver configuration
├── dns-lab/          # Controlled authoritative DNSSEC test environment (SECURE, INSECURE, BOGUS)
├── tests/            # Automated security, policy, and DNSSEC validation test suites
├── benchmarks/       # Latency, CPU, and RAM benchmarking scripts and raw CSV datasets
├── dashboard/        # Lightweight web dashboard for query telemetry and metric visualization
└── documentation/    # Formal project documentation, report PDF, and pseudocode specifications
```

---

## Module Overview

| Directory | Focus Area | Primary Technologies | Primary Responsibility |
| :--- | :--- | :--- | :--- |
| **`firmware/`** | IoT Client | ESP-IDF (C/C++), FreeRTOS, mbedTLS, cJSON | Anusmriti Sinha Roy (Member A) |
| **`gateway/`** | Validating Gateway | Python 3.11, FastAPI, Uvicorn, Unbound | Anshuman Katyan Jha (Member B) |
| **`dns-lab/`** | Test Zones | Knot DNS / BIND 9, ldns-utils, dnssec-signzone | Anshuman Katyan Jha (Member B) |
| **`tests/`** | Verification | Pytest, Python DNS, curl, Shell scripts | Shared (Members A & B) |
| **`benchmarks/`** | Performance Evaluation | Python, Pandas, Matplotlib, ESP-IDF timers | Shared (Members A & B) |
| **`dashboard/`** | Telemetry UI | React / HTML5, Chart.js / Recharts | Anshuman Katyan Jha (Member B) |
| **`documentation/`** | Submission Deliverables | Markdown, LaTeX / PDF slides | Shared (Members A & B) |

---

## Getting Started

Refer to the specific `README.md` within each subdirectory for detailed setup and execution instructions.
