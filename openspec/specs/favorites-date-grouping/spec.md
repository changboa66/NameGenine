## Favorites Date Grouping

### Requirement: Favorites grouped by date
The favorites list SHALL group saved names by date sections (Today, Yesterday, This Week, Earlier) for easier browsing.

#### Scenario: Favorites from today
- **WHEN** the user has saved favorites with `createdAt` set to today's date
- **THEN** they SHALL appear under a section titled "今天"

#### Scenario: Favorites from yesterday
- **WHEN** the user has saved favorites with `createdAt` set to yesterday's date
- **THEN** they SHALL appear under a section titled "昨天"

#### Scenario: Favorites from this week
- **WHEN** the user has saved favorites with `createdAt` within the current week but not today or yesterday
- **THEN** they SHALL appear under a section titled "本周"

#### Scenario: Favorites from earlier
- **WHEN** the user has saved favorites with `createdAt` before the current week
- **THEN** they SHALL appear under a section titled "更早"

### Requirement: Date labels on favorite items
Each favorite row SHALL display a relative date label (e.g., "10:30", "昨天", "6/5").

#### Scenario: Favorite from today
- **WHEN** a favorite was created today
- **THEN** the date label SHALL show the time in "HH:mm" format

#### Scenario: Favorite from yesterday
- **WHEN** a favorite was created yesterday
- **THEN** the date label SHALL show "昨天"

#### Scenario: Favorite from this week
- **WHEN** a favorite was created this week but not today or yesterday
- **THEN** the date label SHALL show the day name (e.g., "周一", "周二")

#### Scenario: Favorite from earlier
- **WHEN** a favorite was created before this week
- **THEN** the date label SHALL show "M/d" format (e.g., "6/5")
