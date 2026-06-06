## ADDED Requirements

### Requirement: Tab bar is fixed to bottom of screen
The custom tab bar SHALL be positioned at the absolute bottom of the screen, with its background filling the full width and extending into the home indicator safe area. There SHALL be no visual gap between the tab bar background and the left, right, or bottom edges of the screen.

#### Scenario: Tab bar fills bottom edge
- **WHEN** the app launches and displays the tab bar
- **THEN** the tab bar background extends to the left, right, and bottom screen edges without any visible gap

### Requirement: Tab bar has 3 tabs
The tab bar SHALL display exactly 3 tabs: Generate, Favorites, and Culture. Each tab SHALL display an SF Symbol icon and a text label below it.

#### Scenario: All 3 tabs visible
- **WHEN** the tab bar is rendered
- **THEN** it shows "Generate" (sparkles icon), "Favorites" (bookmark icon), and "Culture" (book icon)

### Requirement: Tap tab switches content
Tapping a tab SHALL switch the visible content to the corresponding page. The tapped tab's icon and label SHALL be highlighted in the accent color; other tabs SHALL appear in secondary color.

#### Scenario: User switches tabs
- **WHEN** user taps "Favorites" tab while on Generate page
- **THEN** the content switches to Favorites page and the Favorites tab is highlighted in accent color

### Requirement: Tab bar slides out on navigation push
When the active NavigationStack pushes a detail page (e.g., NameDetailView), the tab bar SHALL slide out of view along with the content, consistent with standard iOS navigation behavior.

#### Scenario: Push detail page hides tab bar
- **WHEN** user taps a name result to view details
- **THEN** the tab bar slides left and disappears as NameDetailView slides in

#### Scenario: Pop back shows tab bar
- **WHEN** user taps back from NameDetailView
- **THEN** the tab bar slides back into view with the content

### Requirement: Tab bar has divider line
The tab bar SHALL display a thin hairline divider at its top edge, separating it from the content area.

#### Scenario: Divider visible
- **WHEN** the tab bar is displayed
- **THEN** a thin divider line separates the content area from the tab bar

### Requirement: Tab bar respects dynamic type
The tab bar's icon and label sizes SHALL respect the user's dynamic type settings.

#### Scenario: Larger text size
- **WHEN** user sets larger dynamic type in system settings
- **THEN** the tab bar icon size adjusts proportionally (within reason) and labels remain readable
