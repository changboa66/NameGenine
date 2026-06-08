## Context

收藏页当前使用 `LazyVStack + ScrollView` 展示收藏名字，每行是独立卡片（`.secondarySystemBackground` + 圆角 10）。分组使用 `DateGroup` 枚举（今天/昨天/本周/更早）。没有左滑删除功能。

用户希望改为：按精确日期分块，同一天内的行用分隔线连接，日期以英文 "Month Day" 格式显示，并支持左滑删除。

## Goals / Non-Goals

**Goals:**
- 按日历日精确分组收藏列表
- 同一天内的行合并为一个视觉块，行间用系统分隔线
- 日期 section header 使用英文 "Month Day" 格式（如 "May 8"）
- 左滑删除功能
- 移除行内日期/时间标签
- 保持现有 FavoriteName 数据模型不变

**Non-Goals:**
- 不改动其他页面（GenerateView、CultureView、NameDetailView）
- 不改动后端或 API
- 不添加新的收藏相关交互（如批量操作、排序）

## Decisions

### 1. List + .insetGrouped 替代 LazyVStack + ScrollView

**选择：** 使用原生 `List(style: .insetGrouped)` 替代当前的 `ScrollView { LazyVStack { Section } }`。

**理由：**
- 系统 List 原生支持 section headers 固定、行间分隔线、左滑删除（`.onDelete`），不需要自建
- `.insetGrouped` 样式自动给每个 section 包裹圆角背景块，正好吻合"每天一个块"的需求
- 每行不再需要手动设置 `.background` + `.clipShape`，减少重复代码
- 左滑删除触感反馈和动画与系统一致

**替代方案拒绝：**
- LazyVStack + VStack 块 + `.swipeActions` — iOS 17 中 VStack 内嵌套的 `.swipeActions` 行为不确定，风险高
- LazyVStack + 自定义 DragGesture 左滑 — 实现复杂，需要处理手势冲突、弹簧动画、按钮点击区域

### 2. DayGroup 数据模型

```swift
struct DayGroup: Identifiable {
    let date: Date
    let items: [FavoriteName]
    
    var id: String { dateKey }
    var dateKey: String { ... } // "yyyy-MM-dd" 格式
    var displayDate: String { ... } // "May 8" 格式
}
```

新的 `groupedByDay()` 扩展方法替代旧的 `groupedByDate()`，按精确日期分组。保留 `DateGroup` 枚举不移除（避免影响现有引用），但收藏页不再使用。

### 3. 日期格式化

在 section header 中使用 `DateFormatter`：
```swift
let formatter = DateFormatter()
formatter.dateFormat = "MMMM d"  // "May 8"
```

使用 `dateFormat` 而非 `dateStyle` 以确保精确控制。locale 使用 `en_US_POSIX` 确保英文输出。

### 4. FavoriteRow 简化

- 移除行尾时间/日期 badge（`dateLabel` 计算属性和相关 UI 代码）
- 移除 `chevron.right`
- 保持 hanzi（22pt medium） + pinyin/meaning（13pt regular）的内容结构

### 5. Section header 简化

- 日期文本 + 左侧 SF Symbol 日历图标
- 不再显示计数（"N 个"）
- 使用 `List` 原生 section header，无需自定义背景

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| List 在 iOS 17 上的自定义度不如 LazyVStack（行样式、间距控制） | 收藏页不需要视觉定制；系统 .insetGrouped 样式已经满足"块+分隔线"需求 |
| List 的行点击区域和 NavigationLink 嵌套偶发冲突 | 使用 `.buttonStyle(.plain)` + 保持 FavoriteRow 内容简洁 |
| Section header 在 List 中不支持 pinned 效果 | 当前设计不需要 pinned header（日期是浏览上下文，非导航元素） |

## Open Questions

- 是否需要保留旧的 `DateGroup` 枚举供其他场景使用（如统计）？当前设计选择保留但不使用。
