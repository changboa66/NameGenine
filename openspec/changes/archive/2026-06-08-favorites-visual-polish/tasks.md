## 1. FavoriteRow 风格解析

- [x] 1.1 在 `FavoriteRow` 中添加 `style` 计算属性（从 `favorite.meaning` 解析 Classic/Modern/Unique 前缀）
- [x] 1.2 在 `FavoriteRow` 中添加 `styleColor` 计算属性（orange/blue/purple 映射）
- [x] 1.3 在 `FavoriteRow` 中添加 `cleanMeaning` 计算属性，剥离风格前缀

## 2. FavoriteRow UI 更新

- [x] 2.1 在含义文本前添加 `Image(systemName: "circle.fill")`，大小 8pt，使用 `styleColor`
- [x] 2.2 修改含义文本绑定，使用 `cleanMeaning` 替代 `favorite.meaning`
- [x] 2.3 当 style 为 nil 时不显示圆点，含义文本正常展示

## 3. Section header accentColor

- [x] 3.1 将 `Section(group.displayDate)` 改为自定义 header 模式：`Section { ... } header: { Text(group.displayDate).foregroundStyle(Color.accentColor) }`
- [x] 3.2 验证 List 自定义 section header 在 `.insetGrouped` 样式下显示正常

## 4. 验证

- [x] 4.1 验证带风格前缀的收藏正确显示对应颜色的圆点
- [x] 4.2 验证无风格前缀的收藏兼容显示（无圆点）
- [x] 4.3 验证 section header 使用 accentColor
