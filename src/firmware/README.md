# IoT Client Firmware (`src/firmware/`)

This directory contains the firmware implementation for the physical **ESP32-WROOM-32** microcontroller, implemented in C/C++ using the **Espressif IoT Development Framework (ESP-IDF)**.

---

## Architectural Role

The ESP32 operates as a **non-validating security-aware stub client** (RFC 4033 §7). Due to severe memory and processing constraints on microcontrollers, cryptographic DNSSEC verification is delegated to the trusted local gateway.

The client guarantees security by strictly establishing an **authenticated and encrypted TLS connection** to the gateway, verifying the gateway's certificate, and enforcing explicit client-side policies on the received DNS validation states.

---

## Directory Layout

```
firmware/
├── CMakeLists.txt              # Top-level ESP-IDF build configuration
├── certs/
│   └── root_ca.pem             # Pinned Gateway Root CA certificate (embedded in flash)
├── include/
│   ├── dnssec_client.h         # Client API definitions and validation data structures
│   └── wifi_manager.h          # Wi-Fi connection handlers and event callbacks
├── main/
│   ├── CMakeLists.txt          # Main component build definition
│   ├── dnssec_client.c         # HTTPS query dispatcher, cJSON response parser, policy engine
│   ├── main.c                  # Application entry point and FreeRTOS task coordinator
│   ├── tls_transport.c         # esp_http_client TLS configuration and certificate verification
│   └── wifi_manager.c          # WPA2/WPA3 Wi-Fi connection and auto-reconnect routines
├── baseline/
│   └── baseline_dns.c          # Unvalidated UDP DNS (lwip_getaddrinfo) for benchmark comparison
└── sdkconfig.defaults          # Default ESP-IDF configuration (heap tracing, TLS settings)
```

---

## Client Security Responsibilities

1. **Strict Transport Security (RFC 7858 §4.2)**: Connects to the gateway endpoint (`https://<gateway-ip>:8443/api/v1/resolve`) over TLS 1.2/1.3. Rejects connection downgrade attempts.
2. **Gateway Certificate Verification**: Verifies the server certificate against the embedded `root_ca.pem` trust anchor. Verifies the Subject Alternative Name (SAN) matches the gateway hostname/IP.
3. **Response Policy Enforcement**:
   - `SECURE` $\rightarrow$ Accepts the resolved IP address and continues application traffic.
   - `INSECURE` $\rightarrow$ Evaluates configurable policy (e.g., allow for non-critical telemetry with warning, or reject in strict mode).
   - `BOGUS` $\rightarrow$ **Strictly rejects** the response; discards data, logs a security alert, and refuses connection.
   - `UNAUTHENTICATED GATEWAY` $\rightarrow$ Aborts during TLS handshake; no application payload transmitted.
4. **Benchmarking Instrumentation**:
   - High-resolution timing via `esp_timer_get_time()` ($\mu s$ precision).
   - Free heap tracking via `esp_get_free_heap_size()` and `esp_get_minimum_free_heap_size()`.
   - CPU cycle measurement via `esp_cpu_get_cycle_count()`.
