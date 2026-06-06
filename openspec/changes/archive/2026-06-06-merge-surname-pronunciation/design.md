## Context

当前 `GenerateViewContent` 的偏好区有三张卡片：

1. **generateCard**: GENDER segmented picker + CHARACTER COUNT segmented picker + SURNAME text field
2. **meaningsCard**: MEANINGS 标签网格
3. **aboutYouCard**: YOUR NAME / PRONUNCIATION text field

SURNAME 和 PRONUNCIATION 语义上都是"关于你的文字输入"，分开在两张卡不直观。

## Goals / Non-Goals

**Goals:**
- 将 SURNAME 从 generateCard 移出，与 PRONUNCIATION 合并到同一张卡片
- 合并后卡片标题用 "YOUR NAME"
- 两个输入框垂直堆叠（方案 A）
- 无功能变化，纯 UI 重组

**Non-Goals:**
- 不改动 GenerationPreferences 模型
- 不改动 MEANINGS 卡片
- 不改动 GENDER / CHARACTER COUNT 交互

## Decisions

### 布局方案：垂直堆叠
将 SURNAME 和 PRONUNCIATION 放在同一张卡内上下两行，各自带 section label。

```
┌─ YOUR NAME ──────────────────┐
│ SURNAME (OPTIONAL)           │
│ ┌─────────────────────────┐  │
│ │ e.g. Wang, Li           │  │
│ └─────────────────────────┘  │
│                              │
│ PRONUNCIATION                │
│ ┌─────────────────────────┐  │
│ │ e.g. Christopher        │  │
│ └─────────────────────────┘  │
└──────────────────────────────┘
```

**备选方案 B（左右并排）** 被否决——在手机窄屏上两个 field 会挤在一起，label 也难排版。

### 卡片顺序
重组后整体三段卡顺序：
1. GENDER + CHARACTER COUNT（原 generateCard 去掉 SURNAME）
2. MEANINGS（不变）
3. YOUR NAME（SURNAME + PRONUNCIATION）

## Risks / Trade-offs

- **无** — 纯 UI 重构，不涉及数据流、API、或模型变更，回退只需恢复代码
- SURNAME label 从 "SURNAME (OPTIONAL)" 变为卡片内 sub-label，需注意视觉层级不要喧宾夺主
