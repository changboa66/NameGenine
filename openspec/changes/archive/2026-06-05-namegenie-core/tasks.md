## 1. Cloudflare Worker Setup

- [x] 1.1 Create `workers/namegenie-worker/` directory with `wrangler.toml` configuration
- [x] 1.2 Implement worker `fetch` handler with request validation (POST only, content-type check)
- [x] 1.3 Build generation prompt template with role instruction, preference injectors, and cultural guardrails
- [x] 1.4 Build detail prompt template for character breakdown, cultural context, and namesakes
- [x] 1.5 Implement DeepSeek API proxy with environment variable for API key
- [x] 1.6 Add error handling: timeout (10s), invalid responses, structured error JSON
- [x] 1.7 Deploy worker via `npx wrangler deploy` and document endpoint URL

## 2. Project Configuration & Data Models

- [x] 2.1 Add iCloud entitlement to XcodeGen `project.yml` for CloudKit sync
- [x] 2.2 Create SwiftData `@Model` for `FavoriteName` with fields: hanzi, pinyin, meaning, detailData (Data?), createdAt
- [x] 2.3 Create `NameCandidate` struct (Codable) for API response parsing: hanzi, pinyin, meaning, relevance
- [x] 2.4 Create `NameDetail` struct (Codable) for detail API response: characterBreakdown, pronunciation, culturalBackground, namesakes
- [x] 2.5 Create `GenerationPreferences` struct for user input: gender, phoneticInput, meanings, characterCount, surname
- [x] 2.6 Create API client class `NameGenieAPI` with methods: `generateNames(_:)`, `nameDetail(hanzi:pinyin:)`

## 3. Core UI: Name Generation Flow

- [x] 3.1 Build preference input form: gender picker (male/female/neutral), phonetic text field, meaning tag selector (multi-select chips), character count picker (1/2), surname text field
- [x] 3.2 Implement form validation and sensible defaults for empty fields
- [x] 3.3 Build loading state with animated indicator during generation
- [x] 3.4 Build results list view showing name candidates (hanzi, pinyin, meaning, relevance badge)
- [x] 3.5 Implement result caching (last 5 generations, in-memory cache)
- [x] 3.6 Add error state UI with retry button and user-friendly message
- [x] 3.7 Wire up "Generate More" button for new generation with same preferences

## 4. Core UI: Name Detail View

- [x] 4.1 Build name detail view with scrollable sections: character breakdown, pronunciation guide, cultural background, celebrity namesakes
- [x] 4.2 Implement detail call on tap with loading spinner
- [x] 4.3 Implement per-name detail caching (dictionary cache keyed by hanzi)
- [x] 4.4 Add "Save to Favorites" button in detail view
- [x] 4.5 Add "Share" button triggering Share Sheet with formatted text card

## 5. Favorites & Sync

- [x] 5.1 Build favorites list view with SwiftData `@Query` sorted by creation date descending
- [x] 5.2 Add swipe-to-delete with confirmation
- [x] 5.3 Add bookmark toggle icon on name candidate cells (filled/unfilled state)
- [x] 5.4 Implement search bar filtering by hanzi or pinyin
- [x] 5.5 Configure SwiftData iCloud sync (`NSPersistentCloudKitContainer` options)
- [ ] 5.6 Add sync status indicator (optional: last sync timestamp) — skipped, can add in future iteration

## 6. Tab Navigation & App Structure

- [x] 6.1 Create main tab view with tabs: Generate, Favorites, Culture
- [x] 6.2 Set up `ModelContainer` with iCloud config in `NameGenieApp`
- [x] 6.3 Build Culture tab with locally bundled JSON content cards
- [x] 6.4 Create cultural content JSON schema and seed data file (5-10 initial snippets)
- [x] 6.5 Wire Share Sheet via `ShareLink` or `UIActivityViewController` bridge

## 7. Polish & Error Handling

- [x] 7.1 Handle network errors with `URLError` mapping to user-facing messages
- [x] 7.2 Handle JSON decoding errors gracefully
- [x] 7.3 Add empty states for favorites list and culture tab
- [x] 7.4 Add pull-to-refresh on generation results for manual retry
- [x] 7.5 Configure SwiftData migration support for future model changes

## 8. Verification

- [ ] 8.1 Build and run on iOS 17 simulator — full generation flow from input to results
- [ ] 8.2 Test detail expansion and caching (tap same name twice, verify no duplicate API call)
- [ ] 8.3 Test save to favorites and verify persistence across app relaunch
- [ ] 8.4 Test share sheet output formatting
- [ ] 8.5 Test error states: no network, invalid API response
- [ ] 8.6 (If possible) Test iCloud sync between two simulator instances
