## Context

NameDetailView 当前加载态使用 `ProgressView()`（系统菊花），而 GenerateView 已使用 `LottieView("panda-fly")` 作为加载动画。两者视觉不一致。

`LottieView` 和 `PausedLottieView` 封装已存在于 `LottieView.swift`，`panda-fly` 动画资源已导入项目。

## Goals / Non-Goals

**Goals:**
- NameDetailView 加载态显示飞飞熊猫动画
- Header（汉字+拼音+含义）在加载时保持可见
- 动画限制定位尺寸
- 内容切换增加过渡动画

**Non-Goals:**
- 不改变 LottieView 封装
- 不改变加载逻辑（loadDetail 等）
- 不修改 GenerateView 的加载动画

## Decisions

### 1. 替换位置

```
当前:
┌─ ScrollView ──────────────────┐
│  headerSection                │  ← 可见 ✓
│  if isLoading → ProgressView  │  ← 替换
└───────────────────────────────┘

替换后:
┌─ ScrollView ──────────────────┐
│  headerSection                │  ← 可见 ✓
│  if isLoading → LottieView    │  ← panda-fly
│       .frame(120, 120)        │
│       .transition(.opacity)   │
└───────────────────────────────┘
```

### 2. 动画尺寸

限制 `.frame(width: 120, height: 120)`，与 GenerateView 的隐性尺寸保持一致，避免在 ScrollView 内过度撑大。

### 3. 过渡动画

`.transition(.opacity)` 配合 `.animation(.default, value: isLoading)`，内容加载完成后 panda 淡出、detail section 淡入。

## Risks / Trade-offs

无显著风险。纯 UI 替换，LottieView 已在 GenerateView 经过验证。
