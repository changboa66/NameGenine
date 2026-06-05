## Context

NameGenie is an iOS app for foreigners to discover meaningful Chinese names. The project currently exists as a bare XcodeGen scaffold with a single "Hello, NameGenie!" view. This change builds the entire core functionality: name generation via AI, favorites with iCloud sync, and cultural content.

The app targets iOS 17+ using SwiftUI, with a Cloudflare Workers edge function as a thin proxy to the DeepSeek API. No existing backend infrastructure exists.

## Goals / Non-Goals

**Goals:**
- Functional name generation with user preference inputs
- On-demand name detail expansion (character breakdown, cultural context)
- iCloud-synced favorites via SwiftData
- Share Sheet integration
- Culturally appropriate outputs (no bad homophones, outdated styles)
- Cloudflare Workers proxy for secure DeepSeek API access

**Non-Goals:**
- Phoneme mapping engine (replaced by AI prompt engineering)
- User authentication system (no accounts needed — favorites sync via Apple ID)
- Server-side caching or rate limiting beyond basic Worker safeguards
- Push notifications or server-side content delivery
- Android or web versions

## Decisions

### Decision 1: AI-powered generation over rule-based engine
**Choice:** Use DeepSeek API with curated prompts instead of building a phoneme-to-hanzi mapping engine.
**Rationale:** Building a phoneme inventory, compression rules, and character database requires massive data engineering. AI provides equivalent or better quality at a fraction of the build cost. The prompt can be iterated quickly based on user feedback.
**Alternatives considered:**
- Rule-based phoneme mapping — too much data work, brittle
- GPT-4o-mini — more expensive per call, marginal quality difference in Chinese naming

### Decision 2: Two-stage API flow
**Choice:** Generation returns lightweight data (hanzi, pinyin, meaning summary). Detail expansion is a separate API call triggered by user tap.
**Rationale:** Users see results fast (~1-2s). Detail calls are on-demand so cost scales with engagement depth, not surface-level browsing. Typical user flow: see 3 names → tap the 1 interesting one → saves it = 2 calls instead of 3-4x tokens.
**Trade-off:** Detail view has a loading spinner. Acceptable given the richness of returned content.

### Decision 3: Cloudflare Workers as API proxy
**Choice:** Single edge function validates requests, injects DeepSeek API key from environment variable, and forwards structured prompts.
**Rationale:** Zero infrastructure management, $0 cost at NameGenie's scale (free tier: 100k requests/day), API key never exposed to client. Workers is simpler than Vercel Edge Functions (no framework dependency) and lighter than Firebase (no SDK).
**Trade-off:** Vendor lock-in to Cloudflare, but migration path is trivial — the Worker is ~20 lines of JS.

### Decision 4: SwiftData with iCloud sync for favorites
**Choice:** Apple's native SwiftData framework with CloudKit-backed iCloud sync.
**Rationale:** No user accounts needed — sync is automatic via Apple ID. Zero backend cost. SwiftData is the modern replacement for CoreData with simpler API. Works offline-first with conflict resolution handled by CloudKit.
**Trade-off:** Locked to Apple ecosystem. A future Android/web version would need its own sync solution.

### Decision 5: DeepSeek over OpenAI
**Choice:** DeepSeek API as the AI backend.
**Rationale:** Native Chinese training corpus means better cultural intuition. Significantly cheaper than GPT-4o-mini (~1/10th price). Good English understanding for foreign user input.
**Risk:** DeepSeek API reliability and latency from Chinese infrastructure. Mitigation: Worker can implement a 10s timeout with fallback error messaging; consider OpenAI as fallback in future.

## Risks / Trade-offs

- **[Product Risk] AI output quality variance** → Prompt engineering will require iteration. Start with a comprehensive prompt and refine based on user feedback. Include guardrail instructions in the prompt itself.
- **[Technical Risk] DeepSeek API latency** → Chinese-hosted API may have variable latency for international users. Mitigation: Worker sets 10s timeout; UI shows loading states gracefully; consider multi-region or fallback provider.
- **[Platform Risk] SwiftData + iCloud sync maturity** → SwiftData is relatively new (iOS 17). iCloud sync can be unpredictable. Mitigation: Keep data model simple (no relationships); test sync thoroughly; fall back to local-only if sync issues arise.
- **[Cost Risk] AI API costs at scale** → At $0.001/call (DeepSeek), 100k monthly users doing 10 generations each = $1,000/month. Mitigation: Cache identical requests at Worker level; optimize prompt token length; introduce rate limiting per device.
- **[UX Risk] Non-native speakers misunderstanding pinyin** → Foreign users may not distinguish tones. Mitigation: Include audio pronunciation guide text ("say it like...") in addition to tone-marked pinyin; consider adding audio playback in future.

## Open Questions

- Should generation return 3 or 5 candidates? Start with 3 for speed, increase if users want more variety.
- Should the prompt be configurable per-locale? English prompt may work for all, but French/Spanish users may need localized instructions for phonetic approximation.
- How to handle names with special characters or rare hanzi? AI may occasionally suggest obscure characters. Should we add a character frequency filter?
