## MODIFIED Requirements

### Requirement: Favorites grouped by date

The favorites list SHALL group saved names by exact calendar day sections with English "Month Day" headers for easier browsing.

#### Scenario: Favorites from a specific date
- **WHEN** the user has saved favorites with `createdAt` set to a specific date
- **THEN** they SHALL appear under a section titled with the English month and day (e.g., "May 8", "June 1")

#### Scenario: Favorites from multiple dates
- **WHEN** the user has saved favorites on different dates
- **THEN** sections SHALL be ordered reverse-chronologically (newest first)

#### Scenario: Date with no favorites
- **WHEN** a date has no favorites
- **THEN** no section SHALL appear for that date

## REMOVED Requirements

### Requirement: Date labels on favorite items

**Reason**: Date/time label on each row is redundant when section header already shows the date

**Migration**: Remove the `dateLabel` computed property and badge UI from `FavoriteRow`. Section header serves as the date indicator.
