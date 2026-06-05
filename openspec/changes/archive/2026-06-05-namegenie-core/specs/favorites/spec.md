## ADDED Requirements

### Requirement: User can save names to favorites
The system SHALL allow users to save any generated name (with its hanzi, pinyin, and meaning summary) to a favorites list. The favorites data model SHALL be backed by SwiftData with iCloud sync enabled.

#### Scenario: Save a name from generation results
- **WHEN** user taps the bookmark icon on a name candidate
- **THEN** the name is saved to SwiftData persistent store and the icon becomes filled

#### Scenario: Save a name from detail view
- **WHEN** user taps "Save" in the detail view
- **THEN** the name is saved to favorites with all detail information attached

### Requirement: Favorites sync across devices via iCloud
The system SHALL use SwiftData with iCloud CloudKit integration to sync favorites across all devices signed into the same Apple ID. Conflict resolution SHALL use last-write-wins.

#### Scenario: Name saved on iPhone appears on iPad
- **WHEN** user saves a name on iPhone
- **THEN** the same name appears in favorites on iPad within a reasonable sync window (< 30 seconds on same network)

### Requirement: User can browse and manage favorites
The system SHALL display a favorites list sorted by save date (newest first). Users SHALL be able to swipe to delete, tap to view detail, and search by hanzi or pinyin.

#### Scenario: Browse favorites
- **WHEN** user navigates to the favorites tab
- **THEN** all saved names are displayed in a scrollable list sorted by save date descending

#### Scenario: Delete a favorite
- **WHEN** user swipes left on a favorite item and taps delete
- **THEN** the item is removed from the SwiftData store and the list updates immediately

### Requirement: User can share names
The system SHALL support iOS Share Sheet integration. Sharing a name SHALL generate a formatted text card containing: hanzi, pinyin, meaning, and a brief cultural note.

#### Scenario: Share a name
- **WHEN** user taps the share button on a name
- **THEN** the iOS Share Sheet is presented with a pre-formatted text card
