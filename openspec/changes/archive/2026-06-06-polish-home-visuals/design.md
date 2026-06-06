## Context

当前 GenerateView 视觉单调：纯灰背景、白卡片、灰色标签、全局唯一色彩 accentColor。用户感知为"太单调"，需要在不破坏信息架构的前提下增加视觉层次。

## Goals / Non-Goals

**Goals:**
- 增加页面整体氛围感（渐变背景）
- 增强内容区分度（卡片阴影、标签图标、结果风格标签）
- 让颜色只在关键区分点出现，其他地方留白

**Non-Goals:**
- 不改信息架构（卡片顺序、内容不变）
- 不引入新依赖
- 不改 API 或数据模型

## Decisions

### 1. 页面背景：accentColor → .systemGroupedBackground 渐变
用 `LinearGradient` 从顶部 accentColor(5%) 到底部 `.systemGroupedBackground`，加在 ScrollView 的 background 上。

### 2. 卡片阴影
每张卡片加 `.shadow(color: .black.opacity(0.06), radius: 8, y: 2)`，让白卡在灰色背景上自然浮起。各卡片统一 shadow 参数。

### 3. 区段标签带图标
Gender 前加 `person.crop.circle`，Character Count 前加 `textformat.size`，Meanings 前加 `tag`，Your Name 前加 `person.text.rectangle`。用 label 或 HStack 实现。

### 4. 含义标签分色 + 渐变填充
给 `MeaningTag` 枚举添加 `color` 属性，按语义分配色相：
- 暖色（Wisdom/Beauty/Joy/Prosperity）
- 冷色（Nature/Strength/Talent）
- 中性（Bravery/Kindness/Harmony）

选中态用 `.fill(.linearGradient(...))` 替代纯色填充。

### 5. Header 大标题 + 渐变背景
- 标题改为 20-22pt semibold，subtitle 保持 13pt
- header 背景用 `accentColor.opacity(0.08)` → clear 的渐变

### 6. Results 风格标签
`NameCandidate` 已有 style 属性（classic/modern/unique），在结果行右上角加小标签：
- Classic: warm color tag
- Modern: cool color tag
- Unique: accent color tag

## Risks / Trade-offs

- [渐变背景叠加] 如果设备性能较差，LinearGradient 在 ScrollView 中可能掉帧 → 影响小，渐变范围窄，几乎不感知
- [标签分色] 10 个含义各分配不同色可能视觉过杂 → 选 3-4 组色相而非每个独立色
- [阴影] 不同 iOS 版本阴影渲染不一致 → 使用系统 shadow modifier，Radius 8 适中
