## ADDED Requirements

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

## REMOVED Requirements

*(无)*
