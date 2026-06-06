## Why

当前首页（GenerateView）排版有几个影响体验的问题：Header 占首屏约 25%，偏好区域标签太小不易扫读，生成结果后用户需手动往下滚动才能看到，结果卡片信息密度高但视觉较杂乱。优化可让首屏信息密度更高、操作路径更顺畅。

## What Changes

- **生成后自动滚到结果**：生成完成时 `ScrollViewReader.scrollTo` 定位到第一个结果行
- **Header 瘦身**：Panda 从 120x90 缩小到 80x60，标题 17pt→15pt，顶部 padding 15→10、底部 padding 24→16
- **Section 标签加大**：从 `11pt medium .tertiary` 改为 `12pt semibold .secondary`
- **分组卡片化**：偏好区域用卡片分组——BASIC（Gender + Count + Surname）、MEANINGS（tag gird）、ABOUT YOU（Name 输入框）
- **NameResultRow 重设计**：meaning 移到右侧与播放按钮同行，relevance 改为底边进度条装饰，整体更简洁

## Capabilities

### New Capabilities
- （无新增 capability——纯 UI 排版优化，不涉及新功能）

### Modified Capabilities
- （无 spec 级别修改——name-generation spec 仅涉及生成逻辑，UI 布局不在其范围内）

## Impact

- `NameGenie/Views/GenerateView.swift`：Header padding/尺寸调整、ScrollViewReader + scrollTo、section 标签样式、偏好分组卡片化、NameResultRow 重设计
