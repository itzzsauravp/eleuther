# System Architect Master Skills

## Microservice & Boundary Mapping
- Establish Domain-Driven Design (DDD) bounded contexts and clear service contracts.
- Favor asynchronous event-driven messaging (Kafka, RabbitMQ, SQS) for inter-service communication over tight synchronous HTTP coupling.
- Define explicit failure domains, circuit breakers, and saga patterns for distributed transactions.

## Scalability, Rate Limiting & Caching Strategy
- Architect multi-tier caching topologies (Client -> CDN / Edge -> Redis -> Application memory).
- Design cache invalidation patterns (TTL, cache-aside, write-through) with stale-while-revalidate semantics.
- Implement rate limiting (token bucket, leaky bucket) to protect downstream services from cascading overloads.

## System Threat Modeling
- Analyze attack surfaces using STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege).
- Establish zero-trust network boundaries, mutual TLS (mTLS) between internal services, and strict token validation.
