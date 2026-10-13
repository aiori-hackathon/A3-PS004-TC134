# IoT Client Firmware

This directory contains the ESP32-WROOM-32 client implementation built using ESP-IDF (C/C++).

### Key Components
- **`main/`**: Application source code (`dnssec_client.c`, `wifi_manager.c`, `tls_transport.c`).
- **`certs/`**: Gateway Root CA public certificate (`root_ca.pem`) embedded into firmware flash.
- **`include/`**: Header files and data structures.
