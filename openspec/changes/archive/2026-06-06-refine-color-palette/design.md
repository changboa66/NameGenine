## Context

当前 GenerateView 配色：页面 `.systemBackground`（白）、卡片 `.secondarySystemBackground`（灰）。视觉层级颠倒了——标准 iOS 卡片设计是页面灰、卡片白。

## Goals / Non-Goals

**Goals:**
- 页面背景改为浅灰，让白色卡片浮在页面上
- 未选中标签底色与白色卡片有明确区分
- 结果行统一为白色卡片样式

**Non-Goals:**
- 不改 text 颜色（primary/secondary/tertiary 保留）
- 不改 accentColor
- 不改 tab bar 配色
- 不改其他 tab（Favorites/Culture）
- 不改字体/字号/间距

## Decisions

### 整体配色

| 元素 | 当前 | 改为 |
|------|------|------|
| 页面背景 | `.systemBackground` | `.systemGroupedBackground` |
| 卡片背景 | `.secondarySystemBackground` | `.systemBackground` |
| 未选中标签 | `.tertiarySystemBackground` | `.secondarySystemBackground` |
| 结果行背景 | `.secondarySystemBackground` | `.systemBackground` |

### 视觉对比

```
当前                          改进后
┌─────────────────────┐      ┌─────────────────────┐
│ 白底                  │      │ 浅灰底 .sysGroupedBg │
│                      │      │                     │
│ ┌─ 灰色卡片 ──────┐ │      │ ┌─ 白色卡片 ──────┐ │
│ │ Gender          │ │      │ │ Gender          │ │
│ │ [M] [F] [Any]   │ │      │ │ [M] [F] [Any]   │ │
│ └─────────────────┘ │      │ └─────────────────┘ │
│ ┌─ 灰色卡片 ──────┐ │      │ ┌─ 白色卡片 ──────┐ │
│ │ [Wisdom] [美]   │ │      │ │ [Wisdom] [美]   │ │
│ │   灰底 对 灰底  │ │      │ │ 灰底 对 白卡片  │ │  ← 区分度提高
│ └─────────────────┘ │      │ └─────────────────┘ │
│ ┌─ 灰色按钮 ──────┐ │      │ ┌─ 白色结果 ──────┐ │
│ │ 🎲 Lucky        │ │      │ │ 王伟  Wisdom ▶ │ │
│ └─────────────────┘ │      │ └─────────────────┘ │
└─────────────────────┘      └─────────────────────┘
```

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| `.systemGroupedBackground` 在 iOS 17 可能偏暗 | iOS 17 该色值 ≈ #F2F2F7，适中 |
| 白色卡片在浅灰背景上缺少分割线可能显得漂浮 | 卡片有 12pt 圆角 + 卡片间 8pt 间距，视觉上足够区分 |
| 浅灰背景可能导致整体偏冷 | `.systemGroupedBackground` 是中性灰，不影响 |
