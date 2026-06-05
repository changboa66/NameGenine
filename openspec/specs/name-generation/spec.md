## Name Generation

### Requirement: User can generate names in random mode
The system SHALL provide a "🎲 I'm Feeling Lucky" button that triggers random name generation. In random mode, the system SHALL respect any filled preference fields (gender, character count, surname) and use AI freedom for empty fields. If all fields are empty, the AI SHALL have complete creative freedom.

#### Scenario: User taps Lucky button with empty preferences
- **WHEN** user taps "I'm Feeling Lucky" with all preference fields at default values
- **THEN** the system returns 3 name candidates without any preference constraints

#### Scenario: User taps Lucky button with partial preferences
- **WHEN** user taps "I'm Feeling Lucky" after selecting gender="female"
- **THEN** the system returns 3 female name candidates, with other aspects randomized by AI

### Requirement: Random results show 3 distinct styles
In random mode, the AI SHALL generate 3 names across 3 distinct styles: one classic/traditional, one modern/popular, and one unique/literary. Each style SHALL be labeled in the result.

#### Scenario: Random results have varied styles
- **WHEN** the random generation completes successfully
- **THEN** the 3 candidates are visually distinct in style (classic, modern, unique)

### Requirement: Random results are not cached
The system SHALL NOT cache random mode results. Each "I'm Feeling Lucky" tap SHALL trigger a fresh API call. Normal (non-random) generation SHALL still use the existing cache.

#### Scenario: User taps Lucky twice
- **WHEN** user taps "I'm Feeling Lucky" twice in succession
- **THEN** two separate API calls are made and likely return different results

### Requirement: Re-roll prompt after random results
After displaying random results, the system SHALL show a re-roll prompt ("不喜欢？再摇一次 → 🎲") allowing users to generate a fresh set of random names.

#### Scenario: User taps re-roll
- **WHEN** user taps the re-roll prompt below random results
- **THEN** a new random generation is triggered with the same preference state
