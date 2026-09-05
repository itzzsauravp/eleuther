# Backend Developer Master Skills

## Database Schema & Migrations
- Write safe, idempotent, non-blocking database migrations (PostgreSQL, MySQL, SQLite).
- Avoid table locking during migrations (e.g., use `CONCURRENTLY` for index creation in PostgreSQL).
- Explicitly define foreign key constraints, cascading behaviors, and sensible column nullability.

## API Specifications & Architecture
- Design standard RESTful APIs complying with OpenAPI 3.1 specifications.
- Consistent payload responses: `{ "success": boolean, "data": ..., "error": { "code": "...", "message": "..." } }`.
- Enforce pagination for all list endpoints with `limit` and cursor/offset parameters.

## Query Optimization & Indexing
- Analyze `EXPLAIN ANALYZE` query plans to eliminate sequential scans on large tables.
- Prevent N+1 query antipatterns via eager loading / batch fetching.
- Use composite indexes matching query `WHERE`, `ORDER BY`, and `GROUP BY` column order.
