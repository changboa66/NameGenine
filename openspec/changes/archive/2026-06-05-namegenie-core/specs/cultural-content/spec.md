## ADDED Requirements

### Requirement: App displays cultural knowledge snippets
The system SHALL display curated cultural knowledge snippets about Chinese naming culture. Snippets SHALL be displayed on a dedicated tab or section. Content topics include: Chinese naming traditions, character origins (radicals, pictographs), naming taboos and etiquette, generational naming trends, and interesting name stories.

#### Scenario: User opens cultural content tab
- **WHEN** user navigates to the "Culture" tab
- **THEN** a list of knowledge snippet cards is displayed, sorted by topic category

### Requirement: Content is locally bundled initially
The initial set of cultural content SHALL be bundled as static JSON in the app bundle, allowing offline access. Each snippet SHALL contain: title, body text (1-3 paragraphs), topic tag, and an optional illustrative character or name example.

#### Scenario: App launches with no network
- **WHEN** user opens the Culture tab while offline
- **THEN** locally bundled snippets are displayed without any network-dependent loading

### Requirement: Content can be expanded via API (future)
The system SHOULD define an extensible content model so that future versions can fetch additional or updated content from a backend. The local JSON schema SHALL be compatible with a future API response schema.

#### Scenario: Content structure supports future API
- **WHEN** a future backend endpoint returns content in the same JSON schema
- **THEN** the app can merge or replace local content with remote content with minimal code changes
