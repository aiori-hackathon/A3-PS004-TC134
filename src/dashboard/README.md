# Telemetry & Visualization Dashboard (`src/dashboard/`)

This directory contains a lightweight, responsive web dashboard for monitoring real-time DNS queries, validation states, security alerts, and benchmark distributions during live demonstrations.

---

## Features

1. **Live Query Telemetry**:
   - Streams incoming IoT DNS requests in real time.
   - Highlights cryptographic validation state tags: `SECURE` (Green), `INSECURE` (Yellow), `BOGUS` (Red).
2. **Security Event Monitor**:
   - Real-time alert feed showing rejected bogus DNS records.
   - Logs aborted TLS handshakes from untrusted/rogue gateways.
3. **Comparative Benchmark Visualizations**:
   - Box-and-whisker latency distribution plots (Baseline UDP DNS vs. Proposed Gateway-Assisted).
   - ESP32 free heap memory watermarks over time.
   - Fail-rate and timeout frequency indicators.

---

## Architecture & Technology

- **Frontend**: Lightweight React / HTML5 + Tailwind CSS.
- **Charts**: Recharts / Chart.js for responsive performance metrics.
- **Backend Feed**: FastAPI Server-Sent Events (SSE) or lightweight WebSocket endpoint consuming structured JSON logs from `src/gateway/`.
