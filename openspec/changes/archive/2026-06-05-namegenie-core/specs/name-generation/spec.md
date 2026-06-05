## ADDED Requirements

### Requirement: User inputs generation preferences
The system SHALL accept the following user preferences for name generation:
- Gender: male, female, or neutral
- Phonetic input: user's name in native language (free text) or desired Chinese pronunciation (pinyin)
- Meaning preferences: one or more virtue tags from a predefined set (智慧, 美丽, 勇敢, 繁荣, 善良, 自然, 坚强, 才华, 和谐, 快乐)
- Character count: 1-character or 2-character given name
- Surname: optional Chinese surname input for compatibility

#### Scenario: User fills all preference fields
- **WHEN** user provides gender, phonetic input, meaning tag, character count, and surname
- **THEN** all fields are validated and the system is ready to generate

#### Scenario: User provides only phonetic input
- **WHEN** user provides only a phonetic input without other preferences
- **THEN** the system uses sensible defaults for missing fields (neutral gender, no meaning preference, 2-character name, no surname)

### Requirement: System generates name candidates via AI
The system SHALL send a request to the Cloudflare Worker endpoint with structured preferences. The Worker SHALL forward the request to DeepSeek API using a curated prompt template. The response SHALL contain an array of name candidates, each with: hanzi, pinyin (with tone marks), meaning summary, and a relevance score.

#### Scenario: Successful generation
- **WHEN** user submits valid preferences
- **THEN** the system returns 3 name candidates within 5 seconds

#### Scenario: DeepSeek API unavailable
- **WHEN** the DeepSeek API returns an error or times out
- **THEN** the system displays a user-friendly error message and offers retry

### Requirement: Response is structured JSON
The Cloudflare Worker SHALL return a JSON response with the following structure:
```json
{
  "candidates": [
    {
      "hanzi": "明辉",
      "pinyin": "Míng Huī",
      "meaning": "bright radiance",
      "relevance": 0.92
    }
  ]
}
```

#### Scenario: Valid JSON response received
- **WHEN** the Worker returns a valid JSON response with candidates array
- **THEN** the app parses and displays the candidates

### Requirement: Results are cached locally
The system SHALL cache the last 5 generation results in local storage so users can revisit previous results without re-calling the API.

#### Scenario: User taps back then returns to results
- **WHEN** user navigates away from results and returns within the same session
- **THEN** previous results are displayed from cache without a new API call

### Requirement: Prompt template is versioned and curated
The system SHALL use a carefully engineered prompt template stored as a constant in the Cloudflare Worker. The prompt SHALL include: role instruction (Chinese naming expert), structured output format, cultural appropriateness guardrails (avoid bad homophones, outdated styles, awkward tone combinations), and preference field injection points.

#### Scenario: Prompt includes all guardrails
- **WHEN** the prompt is constructed
- **THEN** it MUST contain instructions to avoid: 3rd-tone + 3rd-tone combinations, names with negative homophones, overly common 2010s-era names, and characters with negative connotations
