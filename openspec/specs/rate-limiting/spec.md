## ADDED Requirements

### Requirement: WAF edge rate limiting
The system SHALL configure Cloudflare WAF Rate Limiting to block excessive requests at the edge before they reach the Worker.

#### Scenario: Request within WAF limit
- **WHEN** a client sends fewer than 120 POST requests per minute from the same IP address
- **THEN** the request SHALL pass through to the Worker normally

#### Scenario: Request exceeds WAF limit
- **WHEN** a client sends more than 120 POST requests per minute from the same IP address
- **THEN** Cloudflare SHALL return HTTP 429 to the client WITHOUT forwarding to the Worker

### Requirement: Worker-side IP rate limiting
The Worker SHALL enforce per-IP rate limiting using Cloudflare KV with a sliding window algorithm.

#### Scenario: IP within limit
- **WHEN** a request arrives from an IP that has made fewer than 200 requests in the last 60 seconds
- **THEN** the Worker SHALL increment the counter and process the request normally

#### Scenario: IP exceeds limit
- **WHEN** a request arrives from an IP that has made 200 or more requests in the last 60 seconds
- **THEN** the Worker SHALL return HTTP 429 with a JSON error body and SHALL NOT call DeepSeek API

### Requirement: Worker-side Device-ID rate limiting
The Worker SHALL enforce per-Device-ID rate limiting using Cloudflare KV with a sliding window algorithm.

#### Scenario: Request with valid Device-ID within limit
- **WHEN** a request includes a `X-Device-ID` header with a non-empty value, and that device has made fewer than 100 requests in the last 60 seconds
- **THEN** the Worker SHALL increment the counter and process the request normally

#### Scenario: Request with Device-ID exceeds limit
- **WHEN** a request includes a `X-Device-ID` header with a non-empty value, and that device has made 100 or more requests in the last 60 seconds
- **THEN** the Worker SHALL return HTTP 429 with a JSON error body and SHALL NOT call DeepSeek API

#### Scenario: Request without Device-ID
- **WHEN** a request does not include the `X-Device-ID` header
- **THEN** the Worker SHALL fall back to IP-only rate limiting for that request

### Requirement: KV rate limit data structure
The Worker SHALL use Cloudflare KV to store rate limit counters with automatic expiration.

#### Scenario: KV key format for IP
- **WHEN** the Worker stores an IP rate limit entry
- **THEN** the KV key SHALL follow the format `rl:ip:{ip}:{timestamp}` with a TTL of 120 seconds

#### Scenario: KV key format for Device-ID
- **WHEN** the Worker stores a Device-ID rate limit entry
- **THEN** the KV key SHALL follow the format `rl:device:{deviceId}:{timestamp}` with a TTL of 120 seconds

### Requirement: Rate limit response headers
The Worker SHALL include rate limit information in every response.

#### Scenario: Successful response includes rate limit headers
- **WHEN** the Worker processes a request successfully
- **THEN** the response SHALL include `X-RateLimit-Remaining` and `X-RateLimit-Reset` headers reflecting the current device's or IP's remaining quota

#### Scenario: Rate limited response
- **WHEN** the Worker returns HTTP 429
- **THEN** the JSON body SHALL contain an `error` field with message `Rate limit exceeded. Please try again later.`

### Requirement: Device-ID generation on iOS
The iOS app SHALL generate a persistent unique identifier on first launch and include it in API requests.

#### Scenario: First launch generates Device-ID
- **WHEN** the iOS app launches for the first time
- **THEN** the app SHALL generate a UUID string and store it in the system Keychain

#### Scenario: Subsequent launches reuse Device-ID
- **WHEN** the iOS app launches again
- **THEN** the app SHALL read the existing Device-ID from Keychain rather than generating a new one

#### Scenario: Device-ID sent with every API request
- **WHEN** the iOS app sends any request to the Worker
- **THEN** the request SHALL include the `X-Device-ID` header with the stored identifier
