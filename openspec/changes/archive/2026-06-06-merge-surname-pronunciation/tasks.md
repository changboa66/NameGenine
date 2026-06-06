## 1. 修改 generateCard

- [x] 1.1 移除 generateCard 中的 SURNAME 段落（Text("SURNAME (OPTIONAL)") + TextField 块）

## 2. 替换 aboutYouCard 为合并卡片

- [x] 2.1 删除 aboutYouCard 计算属性
- [x] 2.2 新建 yourNameCard 计算属性，标题 "YOUR NAME"，包含 SURNAME + PRONUNCIATION 两个输入框垂直堆叠
- [x] 2.3 在 preferencesSection 中将 aboutYouCard 替换为 yourNameCard

## 3. 验证

- [ ] 3.1 xcodebuild 编译无报错（需在 Xcode 中验证）
- [ ] 3.2 模拟器运行确认三张卡布局正确（需在 Xcode 中验证）
