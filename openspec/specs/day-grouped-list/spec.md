# day-grouped-list Specification

## Purpose
TBD - created by archiving change favorites-grouped-list. Update Purpose after archive.
## Requirements
### Requirement: Favorites displayed in per-day grouped list

The favorites list SHALL display saved names grouped by exact calendar day, using the system `.insetGrouped` list style. Each day's items SHALL appear as a grouped block with system separators between rows. Days with no favorites SHALL NOT appear.

#### Scenario: Multiple favorites on the same day
- **WHEN** the user has multiple favorites created on the same calendar day
- **THEN** they SHALL appear in a single section block with system separators between each row, header showing the date in "Month Day" format

#### Scenario: Favorites across multiple days
- **WHEN** the user has favorites on different calendar days
- **THEN** each day SHALL appear as its own section block, ordered reverse-chronologically (newest first)

#### Scenario: Day with no favorites
- **WHEN** a calendar day has no favorites
- **THEN** no section header or block SHALL appear for that day

### Requirement: Left-swipe to delete

The favorites list SHALL support left-swipe to delete individual items via the system `.onDelete` modifier.

#### Scenario: Swipe to delete a favorite
- **WHEN** the user swipes left on a favorite row
- **THEN** a red "Delete" button SHALL appear on the trailing edge

#### Scenario: Confirm deletion
- **WHEN** the user taps the "Delete" button after swiping
- **THEN** the favorite SHALL be removed from SwiftData and the list SHALL update immediately

### Requirement: Visual style indicators on favorite rows

Each favorite row SHALL display a colored circular indicator next to the meaning text when the stored meaning string contains a style prefix (Classic/Modern/Unique). The indicator SHALL use the corresponding color: orange for Classic, blue for Modern, purple for Unique.

#### Scenario: Favorite with Classic style
- **WHEN** a favorite's `meaning` starts with "Classic:"
- **THEN** the row SHALL display an orange filled circle before the cleaned meaning text

#### Scenario: Favorite with Modern style
- **WHEN** a favorite's `meaning` starts with "Modern:"
- **THEN** the row SHALL display a blue filled circle before the cleaned meaning text

#### Scenario: Favorite with Unique style
- **WHEN** a favorite's `meaning` starts with "Unique:"
- **THEN** the row SHALL display a purple filled circle before the cleaned meaning text

#### Scenario: Favorite without style prefix
- **WHEN** a favorite's `meaning` does not start with "Classic", "Modern", or "Unique"
- **THEN** the row SHALL display the meaning text as stored, without any colored indicator

### Requirement: Accent-colored section header

The favorites list section headers (date labels) SHALL use the app's accent color for visual emphasis.

#### Scenario: Section header displayed
- **WHEN** a section header showing a date (e.g., "May 8") is rendered
- **THEN** the date text SHALL use `.foregroundStyle(.accent)` or equivalent accent color

