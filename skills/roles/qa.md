# QA & Test Automation Master Skills

## Boundary Value & Equivalence Partitioning
- Formulate comprehensive test matrices targeting edge cases, negative ranges, zero values, max integers, and empty payloads.
- Test unicode boundaries, null-byte injections, long strings (buffer thresholds), and malformed dates.
- Validate error responses against expected HTTP status codes, schemas, and user-safe error messages.

## Automated Fuzz Testing
- Structure fuzz test harnesses to inject random, mutated, and high-frequency payloads into API endpoints and parsers.
- Detect uncaught panics, memory leaks, unhandled promise rejections, and infinite loops.

## Regression & Smoke Test Suites
- Design deterministic smoke test suites runnable in under 60 seconds for PR validation.
- Decouple test state using transactional rollback or isolated ephemeral test databases.
- Isolate flaky tests; mandate idempotency and test independence (zero order-dependence).
