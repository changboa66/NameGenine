## 1. 整体背景

- [x] 1.1 `GenerateViewContent` 的 `ScrollView` 添加 `.background(Color(.systemGroupedBackground))`
- [x] 1.2 验证 header 背景（`accentColor 8%`）与 `.systemGroupedBackground` 过渡自然

## 2. 卡片背景

- [x] 2.1 `generateCard` 背景从 `.secondarySystemBackground` 改为 `.systemBackground`
- [x] 2.2 `meaningsCard` 背景从 `.secondarySystemBackground` 改为 `.systemBackground`
- [x] 2.3 `aboutYouCard` 背景从 `.secondarySystemBackground` 改为 `.systemBackground`

## 3. 未选中标签

- [x] 3.1 meaning 标签未选中背景从 `.tertiarySystemBackground` 改为 `.secondarySystemBackground`

## 4. 结果行

- [x] 4.1 `NameResultRow` 整体背景从 `.secondarySystemBackground` 改为 `.systemBackground`
- [x] 4.2 结果行 relevance 进度条颜色从 `accentColor 0.3` 不变（保持在白色背景上可见）

## 5. 验证

- [x] 5.1 `xcodebuild` 编译无报错
- [ ] 5.2 模拟器运行确认配色效果
