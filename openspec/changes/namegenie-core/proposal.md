## Why

Foreigners choosing Chinese names lack a structured, culturally informed tool. Existing solutions are either random generators without explanation, or human consultants who are expensive and slow. NameGenie bridges this gap: an iOS app that generates meaningful, phonetically appropriate Chinese names with full cultural context, powered by AI and grounded in Chinese naming conventions.

## What Changes

- New iOS app from template scaffold to fully functional name generation tool
- Name generation engine: AI-powered (DeepSeek) with fine-tuned prompt engineering
- Two-stage API flow: lightweight name generation, then on-demand name detail expansion
- Name preferences: gender, phonetic approximation, meaning/virtue preferences, character count, surname pairing
- Cloudflare Workers backend as secure AI API proxy
- iCloud-synced favorites via SwiftData
- Share sheet integration for name cards
- Optional: cultural knowledge push content

## Capabilities

### New Capabilities

- `name-generation`: Core name generation — accepts user preferences (gender, sound, meaning, character count, surname), calls Cloudflare Worker → DeepSeek API, returns structured name candidates with pinyin
- `name-detail`: On-demand deep dive into a specific name — character etymology, cultural典故, pronunciation guide, celebrity namesakes
- `favorites`: Save, browse, and manage favorite names with iCloud sync across devices
- `cultural-content`: Curated cultural knowledge snippets about Chinese naming traditions, character origins, and name etiquette

### Modified Capabilities

*None — first capability set.*

## Impact

- New iOS target: NameGenie (SwiftUI, iOS 17+, XcodeGen project)
- New backend: Cloudflare Workers (JS/TS) — 15-30 line edge function proxying DeepSeek API
- New dependency: DeepSeek API key in Workers environment variables
- New dependency: SwiftData + iCloud entitlements for cross-device sync
- No existing code modified — all greenfield additions
