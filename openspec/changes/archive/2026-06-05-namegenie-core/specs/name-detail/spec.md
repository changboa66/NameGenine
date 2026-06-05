## ADDED Requirements

### Requirement: User can request name detail
The system SHALL allow users to tap any name candidate to request a detailed breakdown. The detail request SHALL send the hanzi and pinyin to the Cloudflare Worker, which calls DeepSeek with a detail-specific prompt.

#### Scenario: User taps a name candidate
- **WHEN** user taps "明辉"
- **THEN** a loading indicator appears and a detail request is dispatched

### Requirement: Detail response contains comprehensive information
The system SHALL return and display the following information for each name:
- Hanzi character decomposition: each character's meaning, radical, stroke count, and etymology notes
- Pronunciation: pinyin with tone marks, audio pronunciation guide (text-based description of pronunciation)
- Cultural background: idioms, literary references, or historical associations related to the name or its characters
- Celebrity namesakes: notable people with the same name or characters

#### Scenario: Successful detail retrieval
- **WHEN** the detail API responds successfully
- **THEN** the system displays all sections: character breakdown, pronunciation, cultural background, and namesakes

### Requirement: Detail is cached per name
The system SHALL cache detail responses locally so that viewing the same name detail again does not trigger a new API call.

#### Scenario: Same name detail viewed twice
- **WHEN** user requests detail for "明辉", then navigates away and requests it again
- **THEN** the second request uses cached data and shows no loading indicator
