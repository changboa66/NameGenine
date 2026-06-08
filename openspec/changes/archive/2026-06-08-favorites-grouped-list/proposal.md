## Why

收藏页当前使用卡片式布局 + DateGroup 粗粒度分组（今天/昨天/本周/更早），视觉上不够紧凑，且缺少左滑删除功能。改为按精确日期分组的 native 列表样式，提升浏览效率和操作一致性。

## What Changes

- 分组逻辑从 `DateGroup`（今天/昨天/本周/更早）改为精确到日历日的 `DayGroup`
- 容器从 `LazyVStack + ScrollView` 改为 `List.insetGrouped`
- 每行从独立卡片改为系统分隔线连接的行（统一块结构）
- 移除行内日期/时间 badge（日期由 section header 承载）
- 添加左滑删除功能（`.onDelete`）
- Section header 使用英文月份+日期格式（如 "May 8"），无数据的日期不展示
- 移除 `DateGroup` 枚举和相关分组方法
- 新增 `DayGroup` 结构体和 `groupedByDay()` 方法

## Capabilities

### New Capabilities
- `day-grouped-list`: 按精确日期分组展示收藏列表，包含 block 样式、系统分隔线、section header 的 "Month Day" 英文日期格式、左滑删除

### Modified Capabilities
- `favorites-date-grouping`: 分组粒度从 4 个 DateGroup 桶改为精确到日，日期标题从中文改为英文 Month Day 格式，移除行内日期标签

## Impact

- **`Views/FavoritesView.swift`**: `FavoritesView` 重构（List 替换 LazyVStack）、`FavoriteRow` 简化（移除时间标签、日期 badge、chevron）、section header 改为英文日期格式
- **`Models/FavoriteName.swift`**: 新增 `DayGroup` 结构体 + `groupedByDay()` 方法；移除 `DateGroup` 枚举 + `groupedByDate()` 方法
- **`openspec/specs/favorites-date-grouping/spec.md`**: 更新 requirement 以反映新的分组和日期逻辑
- 其他文件：无直接影响
