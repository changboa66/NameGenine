## Context

当前 GenerateView 使用 VStack + ScrollView 布局，头图偏大、偏好区域标签过小、无卡片分组、生成结果后需手动滚动。改动范围限于 GenerateViewContent 内部，不涉及其他视图。

## Goals / Non-Goals

**Goals:**
- 生成完成后自动滚到第一个结果行
- 减少 header 占用的首屏空间（≈170pt → ≈110pt）
- 提高 section 标签可读性
- 偏好区域卡片化分组，提升视觉层次
- 结果行展示更清晰

**Non-Goals:**
- 不改按钮布局（两按钮维持分开）
- 不改 GenerateFlow / 其他 tab
- 不改生成逻辑/API 调用

## Decisions

### 1. ScrollToResults — ScrollViewReader + scrollTo

```swift
ScrollViewReader { proxy in
    ScrollView {
        LazyVStack(spacing: 0) {
            // ...
            resultsSection
                .id("results")
        }
    }
}
```

生成完成后调用 `proxy.scrollTo("results", anchor: .top)`。放在 `generate()` 末尾、`isLoading = false` 之后，用 `DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)` 延迟执行，确保视图已更新。

### 2. Header 瘦身

| 元素 | 当前 | 新值 |
|------|------|------|
| Panda 尺寸 | 120x90 | **80x60** |
| 标题字号 | 17pt | **15pt** |
| 顶部 padding | 15pt | **10pt** |
| 底部 padding | 24pt | **16pt** |

### 3. Section 标签样式

`font(.system(size: 12, weight: .semibold))` + `foregroundStyle(.secondary)`

### 4. 偏好分组卡片化

```
┌─ GENERATE ─────────────────────────┐
│  Gender    [M|F|Any]               │
│  Count     [1|2|3]                 │
│  Surname   [_______________]       │
├─ MEANINGS ─────────────────────────┤
│  [tag][tag][tag][tag]              │
│  [tag][tag][tag][tag]              │
├─ ABOUT YOU ────────────────────────┤
│  Your Name / Pronunciation         │
│  [____________________________]   │
└────────────────────────────────────┘
```

每组用 `VStack(spacing: 12)` + 分隔标题 + `.background(Color(.secondarySystemBackground).clipShape(.rect(cornerRadius: 12)))` 包裹。组间 spacing: 16。

### 5. NameResultRow 重设计

```
┌────────────────────────────────────────┐
│  王伟    wáng wěě    Wisdom    ▶      │
│  ████████████████░░░░░░░  85%          │
└────────────────────────────────────────┘
```

- 左列：hanzi(22pt) + pinyin(12pt)
- 右列上：meaning + 播放按钮（同行）
- 底部：relevance 进度条（矩形条，accentColor 填充百分比宽度）
- 不再使用单独的 relevance 百分比文字（进度条本身已表达）
- 卡片高度降低，适应新布局

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| ScrollTo 在动画完成前执行可能不生效 | 0.3s 延迟 + `.top` anchor 兜底 |
| 卡片化增加 ScrollView 嵌套层级 | 仅 VStack 层数增加，不影响性能 |
| Relevance 进度条替代文字精度降低 | 仍然保留百分比（写到 accessibilityLabel 或 tooltip 中） |
| Header 缩小后熊猫图可能看不清 | 80x60 仍足够展示 flying panda 姿态 |
