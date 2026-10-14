# AIORI-3-HACKATHON-PROJECTS
This repository will contain the code and resources for the AIORI-3 hackathon that will be developed during the AIORI-3

Here is a project overview for your AIORI-3 PS-004 project, following the same structure and level of detail as the AlgoRhythm example, with your YouTube team introduction video included.

# Authenticated Gateway-Assisted DNSSEC for IoT Clients

**Team:** TwinStacks · **Team ID:** TC134 · **Hackathon:** AIORI-3 · **Problem Statement:** PS-004\
**Domain:** Cloud Computing & IoT

**Team Introduction Video on YouTube:** [https://youtu.be/s7L061AeFTc](https://youtu.be/s7L061AeFTc)

## Overview

This project develops and evaluates an authenticated gateway-assisted DNSSEC architecture for resource-constrained IoT devices. It uses a physical ESP32-WROOM-32 client and a Fedora Linux gateway running FastAPI and Unbound to investigate how DNSSEC validation can be delegated without requiring the IoT device to perform complete cryptographic DNSSEC validation itself.

The system uses HTTPS over TLS to secure communication between the client and gateway, distinguishes secure, legitimately unsigned, and bogus DNS responses, and measures the performance trade-offs against conventional unvalidated DNS.

**Objective:** Demonstrate a reproducible, security-focused DNS resolution architecture that protects against bogus DNS data and unauthenticated gateways while evaluating latency, CPU usage, and memory consumption.

## Problem Statement

IoT devices rely on DNS to locate remote servers and services. However, conventional DNS does not inherently provide cryptographic authentication of DNS responses, making clients vulnerable to forged answers and malicious redirection.

DNS Security Extensions (DNSSEC), defined in RFC 4033 and RFC 4035, provide data-origin authentication and integrity verification. However, implementing complete DNSSEC validation on resource-constrained microcontrollers can introduce additional computational and memory overhead.

This project investigates whether a trusted gateway can perform DNSSEC validation on behalf of a constrained IoT client while maintaining authenticated, encrypted communication and enforcing explicit response-handling policies.

**Key challenges include:**

- Preventing the acceptance of DNS responses that fail DNSSEC validation.
- Authenticating the gateway and protecting client–gateway communication.
- Distinguishing `SECURE`, `INSECURE`, and `BOGUS` validation outcomes.
- Handling resolution failures and repeated retries safely.
- Measuring the security and resource-consumption trade-offs of gateway-assisted DNS resolution.
- Addressing the gateway trust boundary and the risks associated with gateway compromise.

## Proposed Methodology

1. **Environment Setup:** Configure a Fedora Linux gateway, a physical ESP32-WROOM-32 client, and a controlled DNSSEC testing environment.
2. **DNSSEC Infrastructure:** Configure Unbound as the validating recursive resolver and establish controlled `SECURE`, `INSECURE`, and `BOGUS` test scenarios.
3. **Gateway Development:** Build a FastAPI service that validates requests, forwards DNS queries to Unbound, interprets resolver outcomes, and applies response policies.
4. **Secure Communication:** Implement HTTPS over TLS 1.2/1.3 with certificate-chain and hostname verification on the ESP32.
5. **Client Integration:** Implement DNS request handling and explicit response policies using ESP-IDF.
6. **Security Testing:** Verify valid resolution, bogus-answer rejection, untrusted-gateway rejection, and appropriate handling of unsigned responses and operational errors.
7. **Performance Evaluation:** Compare gateway-assisted resolution against conventional unvalidated UDP DNS under controlled conditions.

## Experimental Design

The evaluation will use a healthy baseline and three controlled DNSSEC validation cases.

| **Test Case** | **Controlled Condition**                                                                                               |
| ------------- | ---------------------------------------------------------------------------------------------------------------------- |
| T1            | `SECURE` - Valid DNSSEC signatures and authenticated chain of trust                                                    |
| T2            | `INSECURE` - Legitimately unsigned zone with appropriate proof of non-delegation of trust                              |
| T3            | `BOGUS` - Deliberately corrupted DNSSEC signature or validation chain                                                  |
| T4            | Trusted gateway - Client verifies the gateway certificate and hostname                                                 |
| T5            | Untrusted gateway - Client rejects an untrusted or mismatched certificate                                              |
| T6            | Operational failure - Timeout or resolution failure handled without being misclassified as a DNSSEC validation failure |

Run at least **100 resolution trials per mode**, where practical, for the baseline and gateway-assisted configurations. Record the exact test conditions, cache state, network conditions, and client configuration.

The evaluation should use controlled local test zones wherever possible to ensure reproducibility and avoid dependence on fluctuating public DNS responses.

## Measurement and Analysis

**Primary metrics**

- End-to-end DNS resolution latency.
- Median (p50) and 95th-percentile (p95) latency.
- ESP32 CPU cycles consumed during resolution.
- Free heap memory and minimum free heap.
- Successful resolutions, rejected responses, timeouts, and other failures.
- Correct classification of `SECURE`, `INSECURE`, `BOGUS`, and operational errors.
- Successful rejection of untrusted gateway certificates.

The baseline and gateway-assisted modes will be evaluated under consistent test conditions. Raw measurements will be preserved in CSV files, and comparative results will be calculated from actual experimental data.

Energy consumption will be considered only if suitable measurement hardware is available.

## Expected Deliverables

- Physical ESP32 IoT client implementation.
- FastAPI gateway and Unbound resolver configuration.
- Controlled DNSSEC test zones for secure, insecure, and bogus outcomes.
- TLS certificate verification and untrusted-gateway rejection tests.
- Automated functional and security test scripts.
- Raw benchmark datasets and comparative performance analysis.
- Gateway threat model and security-hardening documentation.
- Pseudocode and technical report.
- Demonstration of the working prototype.

## Scientific and Security Principles

- The ESP32 is a **non-validating stub client**; DNSSEC validation is performed by the trusted gateway.
- Never claim end-to-end DNSSEC validation by the ESP32.
- Never disable TLS certificate verification to make a connection succeed.
- Never return a usable IP address for a `BOGUS` validation result.
- Distinguish DNSSEC validation failures from operational failures such as timeouts.
- Preserve actual test outputs and benchmark measurements; do not fabricate results.
- Document the gateway trust boundary and explain that TLS does not protect against a compromised gateway that deliberately returns false validation information.
- Use defense-in-depth controls, including least-privilege execution, access restrictions, rate limiting, and security logging.

## Standards and Related Work

- [RFC 4033 - DNS Security Introduction and Requirements](https://www.rfc-editor.org/rfc/rfc4033)
- [RFC 4035 - Protocol Modifications for the DNS Security Extensions](https://www.rfc-editor.org/rfc/rfc4035)
- [RFC 7858 - Specification for DNS over Transport Layer Security (TLS)](https://www.rfc-editor.org/rfc/rfc7858)
- [RFC 9520 - Negative Caching of DNS Resolution Failures](https://www.rfc-editor.org/rfc/rfc9520)
- [Unbound Documentation - NLnet Labs](https://unbound.docs.nlnetlabs.nl/en/latest/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/)

Our contribution is a controlled and evidence-driven evaluation of gateway-assisted DNSSEC for resource-constrained IoT devices, focusing on validation correctness, authenticated communication, gateway trust, and measurable resource overhead.

## Project Status

**Status:** Implementation and testing are being carried out incrementally. Final functionality, security results, and performance findings will be documented after verification through actual test runs.

**Team TwinStacks — Secure Resolution. Trusted Connections. Measurable Performance.**

### Team Roles & Responsibilities
- **Anshuman Katyan Jha (Team Member B - Platform & Gateway Lead)**: Gateway API development (FastAPI), Unbound validating resolver configuration, local controlled DNSSEC test environment, and automated performance benchmarking.
- **Anusmriti Sinha Roy (Team Member A - IoT & Security Lead)**: ESP32-WROOM-32 firmware development (ESP-IDF C/C++), TLS transport security, certificate verification, client-side response policy enforcement, and client resource measurement.
- **Jhalak Dutta (Faculty Mentor)**: Academic guidance, protocol verification, and architectural oversight.
