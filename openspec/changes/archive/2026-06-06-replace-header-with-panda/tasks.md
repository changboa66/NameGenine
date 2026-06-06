## 1. PausedLottieView

- [x] 1.1 在 `LottieView.swift` 中添加 `PausedLottieView`（UIViewRepresentable，停指定帧，不播放）
- [x] 1.2 移除不 WORK 的 `snapshot()` 静态方法

## 2. GenerateView Header 替换

- [x] 2.1 添加 `@State private var pandaLoaded = false`
- [x] 2.2 用 `PausedLottieView(name: "panda-fly", progress: 0)` 替换圆形"取名"，frame 120x120
- [x] 2.3 移除旧的 `pandaImage` / `.task` / `import Lottie` 等截图逻辑
- [x] 2.4 调整副标题与熊猫图的间距（原 `VStack(spacing: 8)` → 16）

## 3. 验证

- [x] 3.1 Build with `xcodegen generate && xcodebuild`
- [ ] 3.2 模拟器运行，确认熊猫完整显示，背景矩形铺满左右上边缘
- [ ] 3.3 确认退出页面再回来熊猫仍在
