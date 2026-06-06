## Why

iOS 17 上 `TabView` + 内部 `NavigationStack` 的组合导致系统 tab bar 布局异常——左右下三边出现不该有的间距，tab bar 悬浮在屏幕底部而非固定贴边。此问题通过 `UITabBarAppearance` 无法解决，属于 SwiftUI 布局层级的问题。需要替换为自定义 tab bar 以获得对位置、背景、交互的完全控制。

## What Changes

- **替换 `TabView` 为 `ZStack` 布局**：`ContentView` 不再使用 `TabView`，改用 `ZStack(alignment: .bottom)` + 手动的 `selectedTab` 状态控制
- **自定义 `CustomTabBar` 组件**：实现一个固定在屏幕底部的自定义导航栏，背景填满至 home indicator 区域
- **Tab Bar 跟随 NavigationStack**：tab bar 位于每个 NavigationStack 内部，推送详情页时随内容滑出（微信同款行为）
- **移除 `ContentView` 中所有 `UITabBarAppearance` 相关代码**（已不存在）

## Capabilities

### New Capabilities
- `custom-tab-bar`: 自定义底部导航栏，包含 Generate / Favorites / Culture 三个 tab，支持选中态切换、背景填满安全区

### Modified Capabilities
- （无修改——当前系统没有 tab bar 相关的 spec，name-generation spec 仅关乎生成逻辑，与导航无关）

## Impact

- `NameGenie/Views/ContentView.swift`：重构为 ZStack + 三 tab 切换
- `NameGenie/Views/CustomTabBar.swift`：新增自定义 tab bar 组件
- `NameGenie/Views/GenerateView.swift`：嵌套在 NavigationStack + VStack 结构中，content 区域改填满(.frame(maxHeight: .infinity))并移除 `.ignoresSafeArea(edges: .top)`
- `NameGenie/Views/FavoritesView.swift`：类似调整，包裹在 VStack + tab bar 结构中
- `NameGenie/Views/CultureView.swift`：类似调整
