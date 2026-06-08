## ADDED Requirements

### Requirement: Worker records device on each request
Worker SHALL upsert a device record in D1 for every authenticated request with a valid `X-Device-ID`.

#### Scenario: First request from a device
- **WHEN** Worker receives a request with `X-Device-ID` that does not exist in D1 `devices` table
- **THEN** Worker inserts a new row with `id`, `first_seen`, `last_seen` set to current timestamp, `req_count = 1`, `blacklisted = 0`

#### Scenario: Subsequent request from a device
- **WHEN** Worker receives a request with `X-Device-ID` that already exists in D1 `devices` table
- **THEN** Worker updates `last_seen` to current timestamp and increments `req_count` by 1

#### Scenario: Record update does not block response
- **WHEN** Worker processes a request
- **THEN** D1 upsert SHALL happen via `ctx.waitUntil()` after the response is returned

#### Scenario: D1 write failure is silently ignored
- **WHEN** D1 upsert throws an error
- **THEN** Worker SHALL NOT return an error to the client; the error SHALL be silently caught

### Requirement: D1 devices table schema
Worker SHALL have a `devices` table in D1 with the following schema:

#### Scenario: Table exists
- **WHEN** D1 database is queried for `devices` table
- **THEN** the table SHALL exist with columns: `id TEXT PRIMARY KEY`, `first_seen INTEGER NOT NULL`, `last_seen INTEGER NOT NULL`, `req_count INTEGER DEFAULT 1`, `blacklisted INTEGER DEFAULT 0`
