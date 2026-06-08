## ADDED Requirements

### Requirement: Detail loading shows flying panda animation
When NameDetailView is loading detail data, it SHALL display the flying panda Lottie animation instead of the system ProgressView.

#### Scenario: Detail loading
- **WHEN** `isLoading` is true
- **THEN** the view SHALL display `LottieView("panda-fly")` with loop mode, limited to reasonable frame size

#### Scenario: Header remains visible during loading
- **WHEN** `isLoading` is true
- **THEN** the header section (hanzi, pinyin, meaning) SHALL remain visible above the loading animation

#### Scenario: Smooth content transition
- **WHEN** loading completes
- **THEN** the loading animation SHALL fade out and the detail content SHALL fade in using `.transition(.opacity)`
