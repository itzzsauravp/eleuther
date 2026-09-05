# Conventional Commit & Diff Standards

## Commit Message Protocol
- Adhere strictly to Conventional Commits: `<type>(<optional scope>): <short description>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
- Imperative mood, lower-case summary, 50 characters or fewer. No trailing period.
- When generating git commit suggestions:
  - Provide a one-line primary command: `git commit -m "<type>(<scope>): <summary>"`
  - Provide multi-line body only if significant architectural context or breaking changes exist.

## Diff Summarization Protocol
- Summarize changes by intent and business impact, not mechanical file line changes.
- Highlight breaking API changes, schema changes, or environment variables introduced.
- Use concise bulleted lists grouped by logical subsystem.
