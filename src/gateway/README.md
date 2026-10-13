# Validating Gateway Service

This directory contains the FastAPI gateway and Unbound DNSSEC-validating resolver service.

### Key Components
- **`app.py`**: FastAPI application exposing `POST /api/v1/resolve` and `GET /health`.
- **`unbound/`**: Unbound configuration files (`unbound.conf`, trust anchor files).
- **`certs/`**: Gateway server TLS certificate and private key (generated for port 8443).
- **`resolver.py`**: Python DNSSEC query dispatcher communicating with Unbound via loopback (`127.0.0.1:5353`).
