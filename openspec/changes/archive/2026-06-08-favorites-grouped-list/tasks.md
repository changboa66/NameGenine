## 1. 数据模型

- [x] 1.1 在 `FavoriteName.swift` 中新增 `DayGroup` 结构体（`date: Date` + `items: [FavoriteName]` + `displayDate` 计算属性）
- [x] 1.2 新增 `Array<FavoriteName>.groupedByDay()` 扩展方法，按精确日历日分组并逆序排列（最新在前）
- [x] 1.3 保留 `DateGroup` 枚举不移除，但标注 `@available(*, deprecated)`

## 2. FavoritesView 重构

- [x] 2.1 将 `ScrollView { LazyVStack }` 替换为 `List`，应用 `.listStyle(.insetGrouped)`
- [x] 2.2 使用新的 `groupedByDay()` 替代 `groupedByDate()`，使用 `Section(group.displayDate)` 作为 section header
- [x] 2.3 为每个 ForEach item 添加 `.onDelete` 以支持左滑删除
- [x] 2.4 移除旧的 `sectionHeader()` 方法及其相关代码（`iconName()`、`favoritesCount()`）

## 3. FavoriteRow 简化

- [x] 3.1 移除 `dateLabel` 计算属性及其所有日期格式化逻辑
- [x] 3.2 移除行尾时间/日期 badge（`Text(dateLabel)` + `.padding` + `.background` + `.clipShape`）
- [x] 3.3 移除 `chevron.right` 图标
- [x] 3.4 移除行 `.background` 和 `.clipShape`（List 自动处理行样式）

## 4. 清理

- [x] 4.1 从 `FavoritesView` 移除未使用的 import（如有）
- [x] 4.2 验证左滑删除在模拟器上正常工作
- [x] 4.3 验证不同日期数据量的展示（单天单条、单天多条、跨天）
- [x] 4.4 验证空状态（无收藏时）正常显示
