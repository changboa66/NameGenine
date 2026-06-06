## Why

首页（GenerateView）当前视觉层次单一——背景灰、卡片白、文字灰，唯一色彩 accentColor 只在选中态出现。整页缺少氛围感、内容区分度、和视觉趣味。目标是让页面有层次但不杂乱，颜色只用在关键区分点。

## What Changes

### 背景 + 页面氛围（1A, 1B 精简版）
- 页面背景从纯 `.systemGroupedBackground` 改为顶部到底部的微妙渐变（accentColor 5% → `.systemGroupedBackground`）
- 不加深色光晕，保持干净

### 卡片样式（2B）
- 三张卡片增加轻微阴影（shadow），增强浮起层次感
- 不加彩色竖条（2A）和内 header 底色（2C），避免过度设计

### 区段标签（3A + 3B）
- 标签文字用 accentColor 着色取代 `.secondary`
- 每个标签前加 SF Symbol 图标
- 不加 underline（3C），节省纵向空间

### MEANINGS 标签（4A + 4C）
- 每个含义分配不同色相（按语义分冷暖）
- 选中态用渐变填充取代纯色
- 不加 bordered（4B）和图标（4D），避免标签区太杂

### Header（5A + 5B）
- 标题 "Find Your Chinese Name" 加大字重排版
- header 背景改为渐变（非纯 tint）
- 不加装饰图形（5C）

### Results 行（6A + 6C）
- 每行显示风格小标签（Classic / Modern / Unique），不同颜色区分
- 添加按压效果（selected/disabled state 视觉反馈）
- 不加彩色竖条（6B）

## Capabilities

### New Capabilities
- *无* — 纯 UI 打磨，无新能力

### Modified Capabilities
- *无* — 没有 spec 级别的行为变更

## Impact

- `GenerateView.swift`：修改背景、header、卡片、标签、结果行样式
- `GenerationPreferences.swift`：如果需要给 MeaningTag 加颜色属性，涉及模型扩展
