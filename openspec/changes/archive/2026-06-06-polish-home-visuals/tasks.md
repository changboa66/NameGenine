## 1. 页面背景

- [x] 1.1 将 ScrollView 的 `.background(.systemGroupedBackground)` 替换为 `accentColor(5%) → systemGroupedBackground` 的 LinearGradient

## 2. 卡片阴影

- [x] 2.1 给 generateCard、meaningsCard、yourNameCard 统一添加 shadow 修饰符

## 3. 区段标签

- [x] 3.1 给 GENDER / MEANINGS / YOUR NAME 标签加 SF Symbol 图标
- [x] 3.2 标签文字颜色从 `.secondary` 改为 `accentColor`

## 4. MEANINGS 分色 + 渐变

- [x] 4.1 给 MeaningTag 枚举添加 `color` 属性，按语义分配色相
- [x] 4.2 选中标签填充改为 `.linearGradient` 效果

## 5. Header

- [x] 5.1 增大标题字号/字重
- [x] 5.2 header 背景改为 accentColor → clear 渐变

## 6. Results 风格标签

- [x] 6.1 在 NameResultRow 中根据 candidate 的 style 显示彩色小标签
- [x] 6.2 添加按压视觉效果

## 7. 验证

- [ ] 7.1 Xcode 编译无报错
- [ ] 7.2 模拟器运行确认整体配色效果
