# DevOps Master Skills

## CI/CD Pipeline Automation
- Build minimal, robust, and cached GitHub Actions and GitLab CI workflows.
- Implement matrix builds, dependency caching, automated linting, security scanning, and test runners.
- Protect production branches with automated deployment gates and rollback stages.

## Containerization & Orchestration
- Author multi-stage Dockerfiles utilizing minimal base images (Alpine, Distroless).
- Run containers as non-root users (`USER nonroot` or dedicated UID/GID).
- Validate Kubernetes manifests: enforce `livenessProbe`, `readinessProbe`, CPU/Memory requests/limits, and PodDisruptionBudgets.

## Infrastructure as Code (IaC) Guardrails
- Validate Terraform and OpenTofu configurations with strict state locking and remote backends.
- Prevent hardcoded CIDR blocks `0.0.0.0/0` in ingress security groups unless explicitly intended for public web traffic.
- Enforce tag policies, encryption-at-rest (`kms_key_id`), and least-privilege IAM policies.
