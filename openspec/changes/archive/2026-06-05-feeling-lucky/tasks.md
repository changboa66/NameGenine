## 1. Worker: Random Mode Support

- [x] 1.1 Add `random` prompt template requesting 3 distinct name styles (classic, modern, unique)
- [x] 1.2 Add `random` flag detection in worker `fetch` handler
- [x] 1.3 Wire random flag to use the random prompt template instead of preference prompt

## 2. API Client: Random Mode

- [x] 2.1 Add `random: Bool = false` parameter to `NameGenieAPI.generateNames()`
- [x] 2.2 Pass `random: true` in request body when random mode is active
- [x] 2.3 Ensure random results bypass the result cache

## 3. UI: Lucky Button & Re-roll

- [x] 3.1 Add "🎲 I'm Feeling Lucky" button below existing "Generate Names" button (secondary visual style)
- [x] 3.2 Wire Lucky button to call `generateNames(preferences:random: true)`
- [x] 3.3 Add re-roll prompt ("不喜欢？再摇一次 → 🎲") below random results section
- [x] 3.4 Wire re-roll to trigger fresh random generation

## 4. Verification

- [x] 4.1 Verify Lucky button returns 3 names across distinct styles *(manual — open app, tap 🎲 I'm Feeling Lucky, confirm 3 results)*
- [x] 4.2 Verify partial preferences are respected (e.g. gender=female → female names only) *(manual — set gender only, tap Lucky, confirm names match gender)*
- [x] 4.3 Verify re-roll generates different results each tap *(manual — tap 不喜欢？再摇一次 → 🎲, confirm new results)*
- [x] 4.4 Verify random results can be favorited and viewed in detail *(manual — tap a random result, confirm detail loads, favorite it)*
- [x] 4.5 Verify normal preference generation still works unchanged *(manual — tap Generate Names, confirm normal flow)*
