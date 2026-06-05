## Why

Users who want to explore Chinese names without filling out preference forms have no quick entry point. Adding a "I'm Feeling Lucky" button lets anyone get instant, curated name suggestions with zero friction — lowering the barrier to first use and encouraging playful exploration.

## What Changes

- New "🎲 I'm Feeling Lucky" button below the existing "Generate Names" button
- Smart random mode: respects filled preferences (gender, character count, surname), ignores empty ones
- Random generation always returns 3 names across 3 styles (classic, modern, unique)
- "不喜欢？再摇一次 → 🎲" prompt below random results for re-roll
- Random results are not cached (each tap is fresh)
- Random results can be favorited and viewed in detail like normal results

## Capabilities

### New Capabilities

*None — this is a modification to existing capability.*

### Modified Capabilities
- `name-generation`: Add random mode support. Existing preference form still works as before. New `random: true` flag sent to Worker triggers a different prompt template. UI adds a second button with distinct visual style.

## Impact

- **iOS**: `GenerateView.swift` — add button UI, `generate()` method gains a `random` parameter. `NameGenieAPI.swift` — `generateNames()` gains `random` parameter.
- **Worker**: `src/index.js` — add `random: true` detection, add random prompt template requesting 3 distinct styles.
