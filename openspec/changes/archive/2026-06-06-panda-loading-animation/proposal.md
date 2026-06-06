## Why

当前生成姓名时的加载状态只有一个系统 `ProgressView()` 菊花，体验单调。加一个奔跑熊猫 Lottie 动画能让等待过程更生动有趣，提升整体品质感。

## What Changes

- 新增 Lottie iOS SDK 依赖（SPM）
- 添加 `LottieView` SwiftUI 桥接组件（UIViewRepresentable）
- 导入一个奔跑熊猫（或其他合适）的 Lottie JSON 动画素材
- 替换 GenerateView 加载中的 `ProgressView()` 为 Lottie 动画
- Lucky 按钮加载态同理替换
- 动画在加载结束后 fade out，结果 fade in

## Capabilities

### New Capabilities

_无新能力 —— 纯 UI 增强，不涉及新的功能契约。_

### Modified Capabilities

_无规范层面变更，仅视觉实现替换。_

## Impact

- **项目配置**: `project.yml` 新增 Lottie SPM package 依赖
- **新增文件**: `Views/LottieView.swift`, `Resources/panda-animation.json`
- **修改文件**: `Views/GenerateView.swift`（加载态动画替换）
- **素材选型**: 需从 LottieFiles 或 IconScout 选取一个免费可商用奔跑熊猫 Lottie JSON
