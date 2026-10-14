# Validating Gateway Service (`src/gateway/`)

This directory contains the **FastAPI Gateway Application** and the **Unbound Validating Recursive Resolver** running on the Fedora Linux host.

---

## Architectural Role

The gateway acts as the trusted intermediary between the resource-constrained IoT client and the DNS infrastructure:
1. Receives structured DNS lookup requests over an **authenticated TLS connection (Port 8443)**.
2. Dispatches queries over the loopback interface (`127.0.0.1:5353`) to **Unbound** with the `DO` (DNSSEC OK) bit enabled.
3. Interprets the cryptographic validation outcome from Unbound (`AD` bit, RFC 8914 Extended DNS Errors).
4. Enforces **RFC 9520** negative caching for resolution and validation failures (1s–300s backoff) to mitigate retry storms.
5. Formats the response into a structured JSON payload, strictly withholding IP addresses for bogus records.

---

## Directory Layout

```
gateway/
├── app/
│   ├── __init__.py
│   ├── config.py             # Server configuration, port bindings, trust anchor paths
│   ├── main.py               # FastAPI application, route handlers, error middleware
│   ├── models.py             # Pydantic schemas (ResolveRequest, ResolveResponse, ErrorResponse)
│   ├── rate_limiter.py       # Token-bucket rate limiter (DoS protection)
│   └── resolver.py           # Python DNS client querying Unbound via loopback
├── certs/
│   ├── generate_certs.sh     # Script to generate private Root CA and Gateway TLS cert with SANs
│   ├── gateway.crt           # Gateway server certificate (public)
│   ├── gateway.key           # Gateway server private key (chmod 600, not committed)
│   └── root_ca.crt           # Local Root CA certificate (distributed to clients)
├── unbound/
│   ├── unbound.conf          # Hardened Unbound configuration (loopback only, DNSSEC enabled)
│   ├── trust-anchor.key      # Lab root trust anchor for controlled zone validation
│   └── start_unbound.sh      # Service startup and health-check script
├── requirements.txt          # Python dependencies (fastapi, uvicorn, dnspython, pydantic)
└── Dockerfile                # Containerized deployment definition (optional)
```

---

## Defense-in-Depth Hardening (Threat Model)

* **Layer 1 (Prevent)**: Runs under unprivileged user (`iotgateway`). Port 8443 open to clients; Unbound (port 5353) bound strictly to `127.0.0.1`. Whitelist filtering prevents the gateway from becoming an open recursive proxy.
* **Layer 2 (Limit Impact)**: Strict process isolation between FastAPI and Unbound. Bounded timeouts (default 3s) on upstream queries.
* **Layer 3 (Detect & Recover)**: Comprehensive structured JSON audit logs recording every DNSSEC state, TLS handshake failure, and EDE error code.
