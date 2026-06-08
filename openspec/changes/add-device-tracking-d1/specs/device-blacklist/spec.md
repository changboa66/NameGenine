## ADDED Requirements

### Requirement: Worker checks blacklist before processing
Worker SHALL check the `blacklisted` field of a device record before processing the request. Blacklisted devices SHALL receive a 403 Forbidden response.

#### Scenario: Device is blacklisted
- **WHEN** Worker receives a request with `X-Device-ID` that has `blacklisted = 1` in the `devices` table
- **THEN** Worker SHALL return HTTP 403 Forbidden with a JSON error message, and SHALL NOT process the request further

#### Scenario: Device is not blacklisted
- **WHEN** Worker receives a request with `X-Device-ID` that has `blacklisted = 0` in the `devices` table
- **THEN** Worker SHALL continue normal processing (rate limiting, AI API call)

#### Scenario: Device ID not found in D1
- **WHEN** Worker receives a request with `X-Device-ID` that does not exist in the `devices` table
- **THEN** Worker SHALL treat it as not blacklisted and continue normal processing (a new record will be inserted later)

### Requirement: Blacklist check is synchronous
Worker SHALL check the blacklist status synchronously before the rate limiting check, not via background task.

#### Scenario: Check order
- **WHEN** Worker processes a request
- **THEN** blacklist check SHALL happen after signature verification but before rate limiting checks
