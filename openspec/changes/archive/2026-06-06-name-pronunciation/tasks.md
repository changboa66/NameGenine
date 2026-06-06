## 1. PronunciationService

- [x] 1.1 Create `Services/PronunciationService.swift` as `ObservableObject` singleton wrapping `AVSpeechSynthesizer`
- [x] 1.2 Implement `speak(hanzi:pinyin:)` with three-step flow (char → char → full name) using delegate callbacks
- [x] 1.3 Implement `stop()` to cancel current playback
- [x] 1.4 Publish `isSpeaking: Bool` and `currentCharIndex: Int?` for UI binding

## 2. Results List Play Button

- [x] 2.1 Add 🔊 play button to `NameResultRow` in `GenerateView.swift`, aligned trailing
- [x] 2.2 Wire button to `PronunciationService.shared.speak(hanzi:pinyin:)`
- [x] 2.3 Change button to ⏹ during playback, disable when other name is playing
- [x] 2.4 Add accessibility labels: play → "播放{名字}的发音", stop → "停止播放"

## 3. Detail View Play Button & Highlight

- [x] 3.1 Add 🔊 play button to `NameDetailView` header section
- [x] 3.2 Wire to same `PronunciationService`, toggle to ⏹ during playback
- [x] 3.3 Add character highlight animation: accent color + subtle scale, driven by `currentCharIndex`
- [x] 3.4 Highlight corresponding pinyin text alongside each character
- [x] 3.5 Post accessibility announcements on character change and playback end

## 4. Verification

- [ ] 4.1 Build with `xcodegen generate && xcodebuild`
- [ ] 4.2 Verify three-step flow on results list (char → char → full name)
- [ ] 4.3 Verify three-step flow on detail view with character highlight
- [ ] 4.4 Verify stop button works mid-playback
- [ ] 4.5 Verify VoiceOver labels and announcements
- [ ] 4.6 Verify only one name plays at a time
