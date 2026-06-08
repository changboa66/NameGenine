## Context

收藏页当前使用 `List.insetGrouped`，所有元素均为系统灰色系。FavoriteRow 显示完整 `meaning` 字符串（含 "Classic: " 等风格前缀）。Section header 为纯文本日期。

相比之下，GenerateView 大量使用 `Color.accentColor` 和风格色（orange/blue/purple），NameDetailView 也用 accentColor 做播放高亮。收藏页是唯一完全没有品牌色的页面。

## Goals / Non-Goals

**Goals:**
- Section header 日期文字使用 `.foregroundStyle(Color.accentColor)`
- FavoriteRow 含义文本前显示 8pt 风格色圆点（`circle.fill`）
- 圆点颜色映射自风格前缀：Classic → orange, Modern → blue, Unique → purple
- 含义文本从 `meaning` 中剥离风格前缀，只显示纯含义
- 保持现有 `FavoriteName` 数据模型不变

**Non-Goals:**
- 不改动 GenerateView、CultureView、NameDetailView
- 不新增数据字段（风格从现有 meaning 字符串解析）
- 不大幅改变行布局结构

## Decisions

### 1. 风格解析复用 GenerateView 逻辑

GenerateView 中的 `NameCandidate` 已有 `style` 和 `cleanMeaning` 计算属性。FavoriteRow 需要实现等价的逻辑。

```swift
private var style: String? {
    if favorite.meaning.hasPrefix("Classic") { "Classic" }
    else if favorite.meaning.hasPrefix("Modern") { "Modern" }
    else if favorite.meaning.hasPrefix("Unique") { "Unique" }
    else { nil }
}

private var cleanMeaning: String {
    style.map { String(favorite.meaning.dropFirst($0.count + 2)) } ?? favorite.meaning
    // "Classic: A talented child" → "A talented child"
}

private var styleColor: Color {
    switch style {
    case "Classic": .orange
    case "Modern": .blue
    case "Unique": .purple
    default: .gray
    }
}
```

**不抽取为共享方法**，因为只有两个地方用到，且逻辑简单重复成本低。如果后续出现第三个消费者，再考虑抽取。

### 2. 圆点视觉样式

```swift
Image(systemName: "circle.fill")
    .font(.system(size: 8))
    .foregroundStyle(styleColor)
```

放在含义文本之前，与含义文本同一行，间距 4pt。当 style 为 nil（无风格前缀）时，不显示圆点，含义文本正常显示。

### 3. Section header accentColor

当前 section header 由 `List` 的 `Section(group.displayDate)` 自动生成。List 对 section header 的自定义度有限。使用 `Section {
     header: { Text(...).foregroundStyle(.accent) }
}` 自定义 header 来应用 accentColor。

或者更简单：在 listContent 的 List 外层添加 `.accentColor(.accent)` — 但这会影响所有行。所以使用自定义 section header。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 部分收藏可能没有风格前缀（从旧版本或手动添加） | style 为 nil 时不显示圆点，含义文本正常展示 |
| style 前缀格式可能变化 | 解析逻辑只匹配 "Classic/Modern/Unique" 开头，不假定分隔符格式 |
| accentColor 在 List 自定义 section header 中表现不一致 | 使用 `Section { ForEach {} } header: { Text(...).foregroundStyle(.accent) }` 格式，这是 List 的标准用法 |
