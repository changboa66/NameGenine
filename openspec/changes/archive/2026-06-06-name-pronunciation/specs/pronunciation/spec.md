## Pronunciation

### Requirement: User can hear name pronunciation
The system SHALL provide an audio pronunciation feature for generated names. The pronunciation SHALL use iOS built-in TTS (AVSpeechSynthesizer) with zh-CN voice, requiring no additional dependencies or network access.

### Requirement: Two-step pronunciation flow
The pronunciation SHALL follow a three-step sequence: first character → second character → full name. Each step SHALL have a brief pause (0.25s) between utterances to help users distinguish individual character sounds.

#### Scenario: User taps play on a 2-character name
- **WHEN** user taps the play button for name "丽华"
- **THEN** the system plays: "丽" → pause → "华" → pause → "丽华"

### Requirement: Playback on results list
The results list (NameResultRow) SHALL display a play button for each name candidate. While playing, the button SHALL change to a stop button. Only one name SHALL play at a time.

#### Scenario: User plays a name from results list
- **WHEN** user taps 🔊 on a name candidate
- **THEN** the pronunciation plays and the button becomes ⏹
- **WHEN** user taps ⏹ during playback
- **THEN** the pronunciation stops immediately

### Requirement: Playback on detail view with visual feedback
The detail view (NameDetailView) SHALL include a play button in the header area. During character-by-character playback, the currently spoken character SHALL be visually highlighted (accent color). The corresponding pinyin SHALL also highlight.

#### Scenario: User plays a name from detail view
- **WHEN** user taps 🔊 on the detail view
- **THEN** the first character highlights and plays, then the second character highlights and plays, then the full name displays without highlight

### Requirement: Accessibility support
All pronunciation controls SHALL support VoiceOver with appropriate labels. Playback state changes SHALL post accessibility notifications.

#### Scenario: VoiceOver user interacts with pronunciation
- **WHEN** VoiceOver focuses on the play button
- **THEN** the accessibility label reads "Play {name} pronunciation"
- **WHEN** playback starts
- **THEN** the system announces each character as it plays
