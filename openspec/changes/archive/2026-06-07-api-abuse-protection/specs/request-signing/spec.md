## ADDED Requirements

### Requirement: Client-side request signing
The iOS app SHALL sign every API request using HMAC-SHA256 before sending.

#### Scenario: Signing payload construction
- **WHEN** the iOS app prepares an API request
- **THEN** the signing message SHALL be constructed as `HTTP-Method + "\n" + Content-Type + "\n" + SHA256(HTTP-Body)` and the method SHALL be HMAC-SHA256 using the embedded signing key

#### Scenario: Signature header included
- **WHEN** the iOS app sends a POST request to the Worker
- **THEN** the request SHALL include a `X-Signature` header containing the hex-encoded HMAC-SHA256 output

#### Scenario: Timestamp header included
- **WHEN** the iOS app sends a request
- **THEN** the request SHALL include a `X-Timestamp` header with the current Unix timestamp in seconds

### Requirement: Server-side signature verification
The Worker SHALL verify the HMAC signature of every request before processing.

#### Scenario: Valid signature
- **WHEN** a request has a valid `X-Signature` and `X-Timestamp` within ±30 seconds of server time
- **THEN** the Worker SHALL process the request normally

#### Scenario: Invalid signature
- **WHEN** a request has an `X-Signature` that does not match the expected HMAC
- **THEN** the Worker SHALL return HTTP 401 with a JSON error body and SHALL NOT call DeepSeek API

#### Scenario: Missing signature header
- **WHEN** a request does not include the `X-Signature` header
- **THEN** the Worker SHALL return HTTP 401 with a JSON error body

#### Scenario: Expired timestamp
- **WHEN** a request's `X-Timestamp` differs from server time by more than 30 seconds
- **THEN** the Worker SHALL return HTTP 401 with error message `Request expired`

### Requirement: Signing key management
The signing key SHALL be stored securely on both the server and client.

#### Scenario: Server key storage
- **WHEN** the Worker is deployed
- **THEN** the signing key SHALL be configured as a Worker secret via `wrangler secret put SIGNING_KEY` and accessed via `env.SIGNING_KEY`

#### Scenario: Client key embedded
- **WHEN** the iOS app is built
- **THEN** the signing key SHALL be embedded in the app binary (e.g., via a constant in code or Info.plist)

#### Scenario: Key rotation support
- **WHEN** the server operator wants to rotate the signing key
- **THEN** the Worker SHALL support verifying against both the current and the previous key for a configurable overlap period (e.g., 24 hours)
