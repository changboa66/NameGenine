## MODIFIED Requirements

### Requirement: Unified generation mode
The system SHALL have a single generation mode that respects all filled preference fields (gender, character count, phonetic input, meanings, surname). There is no separate "standard" vs "random" mode.

#### Scenario: User taps Lucky with all preferences
- **WHEN** user taps "I'm Feeling Lucky" with gender, phonetic input, and meanings filled
- **THEN** the system returns 5 name candidates across 3 styles (classic, modern, unique), respecting all the given preferences

#### Scenario: User taps Lucky with empty preferences
- **WHEN** user taps "I'm Feeling Lucky" with all preference fields at default values
- **THEN** the system returns 5 name candidates without any preference constraints

### Requirement: Results are not cached
The system SHALL NOT cache any generation results. Each "I'm Feeling Lucky" tap SHALL trigger a fresh API call.

#### Scenario: User taps Lucky twice
- **WHEN** user taps "I'm Feeling Lucky" twice in succession
- **THEN** two separate API calls are made and likely return different results

### Requirement: Re-roll prompt after results
After displaying results, the system SHALL show a re-roll prompt ("More Names 🎲") allowing users to generate a fresh set of names.
