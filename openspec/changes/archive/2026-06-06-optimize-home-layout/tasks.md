## 1. Header 瘦身

- [x] 1.1 Panda 尺寸从 120x90 改为 80x60
- [x] 1.2 标题字体从 17pt 改为 15pt
- [x] 1.3 顶部 padding 从 15 改为 10，底部 padding 从 24 改为 16

## 2. Section 标签样式

- [x] 2.1 所有 section 标签改为 `font(.system(size: 12, weight: .semibold))` + `foregroundStyle(.secondary)`
- [x] 2.2 验证字符对齐：GENDER、CHARACTER COUNT 等长标签不会截断

## 3. 偏好分组卡片化

- [x] 3.1 抽出三个分组：GENERATE（Gender + Count + Surname）、MEANINGS（tag grid）、ABOUT YOU（Name 输入框）
- [x] 3.2 每组分隔标题（如 "GENERATE" 作为组标题居中或左对齐）
- [x] 3.3 每组用 `.background(Color(.secondarySystemBackground).clipShape(.rect(cornerRadius: 12)))` 包裹
- [x] 3.4 组间 spacing: 16，组内 spacing: 12

## 4. NameResultRow 重设计

- [x] 4.1 左列：hanzi 22pt + pinyin 12pt
- [x] 4.2 右列：meaning 与播放按钮同行
- [x] 4.3 底部添加 relevance 进度条（`GeometryReader` 按百分比填充宽度）
- [x] 4.4 移除旧的 relevance 百分比文字
- [x] 4.5 卡片整体高度调整，适应新布局

## 5. 生成后自动滚到结果

- [x] 5.1 添加 `ScrollViewReader` 包裹现有 `ScrollView`
- [x] 5.2 为 `resultsSection` 添加 `.id("results")`
- [x] 5.3 在 `generate()` 末尾通过 `scrollToResults` 触发 `proxy.scrollTo("results", anchor: .top)`

## 6. 验证

- [x] 6.1 `xcodebuild` 编译无报错
- [ ] 6.2 模拟器运行确认布局效果
- [ ] 6.3 生成结果后自动滚到结果区域
