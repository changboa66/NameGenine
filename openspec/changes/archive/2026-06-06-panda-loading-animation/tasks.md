## 1. Dependency & Asset Setup

- [x] 1.1 Add Lottie SPM package to `project.yml` and regenerate with `xcodegen`
- [x] 1.2 Download Lottie JSON from https://lottiefiles.com/free-animation/fly-xMowoXhjMh → save to `NameGenie/Resources/panda-fly.json`

## 2. LottieView Wrapper

- [x] 2.1 Create `Views/LottieView.swift` with `UIViewRepresentable` bridging `LottieAnimationView`
- [x] 2.2 Expose parameters: animation name, loop mode, content mode

## 3. GenerateView Integration

- [x] 3.1 Add `isLoading` overlay to ScrollView: full-screen translucent backdrop (black 30%) + centered LottieView + "正在取名中…" caption
- [x] 3.2 Remove existing `ProgressView()` from both `generateButton` and `luckyButton` (no longer needed)
- [x] 3.3 Add fade-in transition for overlay, fade-out when loading completes and results appear
- [x] 3.4 Ensure overlay does not block tap-through to the navigation bar or sheet interactions

## 4. Verification

- [x] 4.1 Build project with `xcodegen generate && xcodebuild` ✓
- [x] 4.2 Verify panda animation plays on "Generate Names" tap (manual — confirmed on simulator)
- [x] 4.3 Verify panda animation plays on "I'm Feeling Lucky" tap (manual — confirmed on simulator)
- [x] 4.4 Verify smooth fade transition from animation to results (manual — confirmed on simulator)
- [x] 4.5 Verify error state still works (manual — confirmed on simulator)
