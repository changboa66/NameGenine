-- Migration: 0001_create_devices
-- Description: Create devices table for device tracking and blacklisting

CREATE TABLE IF NOT EXISTS devices (
  id           TEXT PRIMARY KEY,
  first_seen   INTEGER NOT NULL,
  last_seen    INTEGER NOT NULL,
  req_count    INTEGER DEFAULT 1,
  blacklisted  INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_devices_blacklisted ON devices(blacklisted);
