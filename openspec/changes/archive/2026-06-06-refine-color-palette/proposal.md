## Why

当前配色层次感弱——页面背景白、卡片灰（反向层级）、标签未选中底色与页面拉不开。优化配色让页面更有层次：页面灰色营造"画布"感，卡片白色形成"浮层"，视觉清晰度提升。

## What Changes

- **整体背景**从 `.systemBackground` 改为 `.systemGroupedBackground`（浅灰）
- **三个偏好卡片背景**从 `.secondarySystemBackground` 改为 `.systemBackground`（白）
- **未选中的 meaning 标签**从 `.tertiarySystemBackground` 改为 `.secondarySystemBackground`（与白色卡片拉开距离）
- **结果行背景**从 `.secondarySystemBackground` 改为 `.systemBackground`（白）
- **Tab bar**无改动

## Capabilities

### New Capabilities
- （无——纯 UI 配色调整，不涉及新功能）

### Modified Capabilities
- （无——无 spec 层级的行为变更）

## Impact

- `NameGenie/Views/GenerateView.swift`：卡片背景色、标签未选中背景色、结果行背景色
