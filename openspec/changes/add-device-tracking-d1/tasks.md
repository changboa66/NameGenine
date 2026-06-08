## 1. D1 Database Setup

- [x] 1.1 Create D1 database via `wrangler d1 create namegenie-devices`
- [x] 1.2 Create migration file `migrations/0001_create_devices.sql` with devices table schema
- [x] 1.3 Add d1_databases binding to wrangler.toml (default and production environments)
- [x] 1.4 Run `wrangler d1 migrations apply namegenie-devices --remote` for production

## 2. Worker: Blacklist Check

- [x] 2.1 Add synchronous blacklist query after signature verification: `SELECT blacklisted FROM devices WHERE id = ?`
- [x] 2.2 Return 403 Forbidden with JSON error if device is blacklisted
- [x] 2.3 Handle device-not-found case (treat as not blacklisted, continue processing)

## 3. Worker: Device Recording

- [x] 3.1 After response is returned, add `ctx.waitUntil()` with D1 upsert
- [x] 3.2 Implement upsert SQL: `INSERT INTO devices ... ON CONFLICT(id) DO UPDATE SET last_seen = excluded.last_seen, req_count = req_count + 1`
- [x] 3.3 Wrap upsert in try/catch to silently swallow errors

## 4. Deploy

- [x] 4.1 Deploy worker to default environment
- [x] 4.2 Deploy worker to production environment
- [x] 4.3 Verify device records appear in D1 after a test request
