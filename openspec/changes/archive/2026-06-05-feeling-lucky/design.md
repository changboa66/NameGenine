## Context

NameGenie currently requires users to fill out a preference form before generating names. This creates friction for casual explorers who want to quickly see what the app can do. The "I'm Feeling Lucky" feature adds a zero-input entry point that showcases the AI's range while respecting any preferences the user has set.

## Goals / Non-Goals

**Goals:**
- Add "🎲 I'm Feeling Lucky" button below the existing "Generate Names" button
- Smart random: filled preferences are respected, empty ones are AI-free
- 3 distinct styles per random generation (classic, modern, unique)
- Re-roll prompt after results
- Random results can be favorited and viewed in detail

**Non-Goals:**
- Caching random results (each tap = fresh API call)
- Changing the existing preference-driven generation flow
- Adding new backend infrastructure

## Decisions

### Decision 1: Single API endpoint with `random` flag
**Choice:** Reuse the existing `/generate` endpoint with an added `random: true` boolean parameter.
**Rationale:** Avoids duplicating request handling logic. The worker checks the flag and selects the appropriate prompt template.
**Alternatives considered:**
- Separate `/random` endpoint — unnecessary complexity for the same behavior

### Decision 2: Three-style prompt in random mode
**Choice:** The random prompt template explicitly requests 3 styles: classic, modern, unique.
**Rationale:** Demonstrates the breadth of Chinese naming conventions in a single response. Users who like a particular style can then use the preference form to narrow down.
**Trade-off:** Less surprise variety across different Lucky taps, but more internal variety per tap.

### Decision 3: Re-roll reuses existing preferences
**Choice:** The re-roll button triggers the same `generate(random: true)` call with the current `preferences` state.
**Rationale:** If user selected "female" before Lucky, re-roll should respect that too. Keeps the flow consistent.
**Trade-off:** User cannot re-roll with different settings without manual adjustment.

## Risks / Trade-offs

- **[UX Risk] Lucky button ignored on small screens** → Two buttons stacked vertically may take too much space. Mitigation: Keep Lucky button visually lighter (secondary style, smaller emphasis).
- **[Cost Risk] No caching means repeated Lucky taps = repeated API calls** → Normal usage pattern is occasional taps, not rapid-fire. Acceptable given DeepSeek's low per-call cost.
- **[Quality Risk] "Three styles" constraint may feel formulaic** → If users notice the pattern too easily, the prompt can be iterated to add more variety.
