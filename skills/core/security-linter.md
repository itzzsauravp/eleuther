# Security Vulnerability & Secret Guardrails

## Secret Leak Prevention
- Never output hardcoded API keys, JWT tokens, database passwords, private keys, or credentials.
- Always use environment variables (`process.env.KEY`, `os.environ["KEY"]`, `$KEY`).
- Enforce exclusion of `.env`, `.env.local`, `*.key`, `*.pem`, `api-keys.env` in `.gitignore`.

## Secure Coding Rules
- Injection Prevention: Enforce parameterized queries for SQL/NoSQL; never concatenate raw user input into queries.
- Cross-Site Scripting (XSS): Ensure proper output encoding and sanitization in web templates and client-side DOM insertions.
- Authentication & Sessions: Secure cookie attributes (`HttpOnly`, `Secure`, `SameSite=Lax/Strict`).
- Safe Dependencies: Flag deprecated packages, dangerous deserialization calls (`eval()`, `pickle.loads()`, `yaml.load()` without safe loader), and unchecked shell execution (`exec()`, `system()`).
