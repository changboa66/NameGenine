## 1. Replace Loading Indicator

- [x] 1.1 Replace `ProgressView()` with `LottieView("panda-fly", loopMode: .loop)` in NameDetailView
- [x] 1.2 Set frame size `.frame(width: 120, height: 120)` on the LottieView
- [x] 1.3 Add `.transition(.opacity)` and `.animation(.default, value: isLoading)` for smooth content transition
- [x] 1.4 Verify header remains visible above the panda animation
