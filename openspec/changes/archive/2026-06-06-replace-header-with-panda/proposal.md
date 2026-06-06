## Why

"取名"文字图标过于朴素，体现不出 App 的个性。App 已经用了 flying panda Lottie 作为加载动画，首屏 banner 换成同一只熊猫的静态截图，能建立统一的视觉品牌，让首页第一印象更有记忆点。

## What Changes

- 替换 `GenerateView` 的 `headerSection`：移除圆形"取名"文字，改为截取 `panda-fly.json` 第 0 帧渲染的熊猫静态图
- 新增一个工具方法：从 Lottie 动画截取指定帧为 `UIImage`
- 图在 `GenerateView` 首次出现时异步截取一次，缓存到 `@State`，后续直接复用

## Capabilities

### New Capabilities

无 — 纯 UI 改动，不引入新能力。

### Modified Capabilities

无 — 不涉及 spec 级别的行为变化。

## Impact

- `GenerateView.swift`：`headerSection` 重写，新增异步截图逻辑
- `LottieView.swift` 或新工具文件：`lottieSnapshot(name:size:progress:)` 方法
- 无新增依赖，无 API 变更
