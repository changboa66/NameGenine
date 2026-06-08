## Why

NameDetailView 加载详情时使用系统 ProgressView（菊花），与 GenerateView 的飞飞熊猫动画不一致，视觉体验割裂。

## What Changes

- NameDetailView 加载态从 `ProgressView()` 替换为 `LottieView("panda-fly")`
- 加载时 header（汉字+拼音+含义）保持可见
- 限制 panda 动画显示尺寸
- 内容切换添加 `.transition(.opacity)` 过渡动画

## Capabilities

### New Capabilities

- 无

### Modified Capabilities

- 无

## Impact

- **NameDetailView.swift**: 加载态视图替换，约 5-10 行改动
- **LottieView**: 已有，无需改动
