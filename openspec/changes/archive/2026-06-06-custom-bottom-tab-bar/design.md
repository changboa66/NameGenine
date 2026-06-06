## Context

当前 `ContentView` 使用 `TabView` + 3 个 `NavigationStack` 子视图。iOS 17 上 `TabView` 与内部 `NavigationStack` 组合导致 tab bar 的 safe area 计算异常——左右下三边出现间距，tab bar 悬浮而非固定贴底。`UITabBarAppearance` 无法解决此问题。

## Goals / Non-Goals

**Goals:**
- 自定义 tab bar 填满屏幕底部（包括 home indicator 区域），左右下无间距
- 切换 tab 时即时切换内容（不保留跨 tab 的 NavigationStack 状态）
- 推送详情页时 tab bar 随 NavigationStack 滑出（微信同款行为）
- 选中的 tab 以 accentColor 高亮，未选中为 secondary
- 保持三个 tab 的现有页面结构不变（Generate / Favorites / Culture）

**Non-Goals:**
- 不实现 badge（当前不需要）
- 不实现 tab 切换动画（立即切换即可）
- 不实现 scroll-to-top 双击 tab 行为
- 不改变各 tab 页面的内部功能

## Decisions

### 1. ZStack 布局替代 TabView

`ContentView` 用 `ZStack(alignment: .bottom)` 包裹三个 tab 页面。通过 `selectedTab` 枚举控制显示。

```swift
ZStack(alignment: .bottom) {
    GenerateFlow(selectedTab: $selectedTab)
        .opacity(selectedTab == .generate ? 1 : 0)
    FavoritesFlow(selectedTab: $selectedTab)
        .opacity(selectedTab == .favorites ? 1 : 0)
    CultureFlow(selectedTab: $selectedTab)
        .opacity(selectedTab == .culture ? 1 : 0)
}
.ignoresSafeArea(edges: .bottom)
```

各 tab 页面通过 `.opacity` 保持同时存在（防止 NavigationStack 状态丢失）。非活跃 tab 不响应触摸——不需要 `.disabled()`，opacity 0 的视图不接收 hit test。 **结果：** ±50% 的视图仍在渲染，但三个 tab 都很轻量，性能开销可忽略。

### 2. CustomTabBar 位于 NavigationStack 内部

每个 tab 的根结构：

```swift
struct GenerateFlow: View {
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GenerateViewContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab, thisTab: .generate)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
```

这样在 `NavigationStack` push `NameDetailView` 时，`VStack` 整体滑出，tab bar 自然跟随消失。返回时滑回。

### 3. CustomTabBar 视觉规格

```
┌─────────────────────────────────────────────┐
│              Content Area                   │
├────── hairline divider (0.5pt) ────────────┤
│                                             │
│   8pt                                        │
│   ✨22pt  Generate  │  🔖22pt  Favorites    │
│   📖22pt  Culture                           │
│   8pt                                        │
│                                             │
├─────────────────────────────────────────────┤
│          34pt (home indicator)              │
│          .systemBackground                  │
└─────────────────────────────────────────────┘

总高度: 8 + 22 + 4(图标文字间距) + 11 + 8 + 34 ≈ 87pt
```

| 元素 | 规格 |
|------|------|
| 分割线 | `Divider()` / hairline |
| 图标 | SF Symbol, 22pt |
| 标签 | system 11pt |
| 选中态 | `accentColor` |
| 未选中 | `.secondary` |
| Home indicator 背景 | `Color(.systemBackground)`, height: 34pt |
| 总 bar 区域 | `.ignoresSafeArea(edges: .bottom)` |

### 4. 各 tab 页面适配

现有页面（GenerateView/FavoritesView/CultureView）需要做以下调整：
- **移除** `NavigationStack` 包裹（移到 `*Flow` 层）
- **移除** `.ignoresSafeArea(edges: .top)`（tab bar 不再需要顶部边缘的背景延伸）
- **填充** `VStack(spacing: 0)` 中，content area 填满：`.frame(maxWidth: .infinity, maxHeight: .infinity)`

具体细节：
- `GenerateViewContent`：提取原 `GenerateView` 的 ScrollView 及其内部内容。`.ignoresSafeArea(edges: .top)` 只需要在 header 的 Rectangle 背景上保留。
- `FavoritesViewContent`：提取原 `FavoritesView` 的 Group 内容。无需 `.ignoresSafeArea`。
- `CultureViewContent`：提取原 `CultureView` 的 ScrollView 内容。无需 `.ignoresSafeArea`。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 三个 tab 同时渲染增加内存 | 页面轻量（几个 text/button），可忽略 |
| Tab 切换丢失子页面 NavigationStack 状态 | 当前需求不需要跨 tab 保留导航状态；每页只到一级详情 |
| 自定义 tab bar 不遵循系统 tab bar accessibility 标准 | 使用 SF Symbol + 标准 Button，VoiceOver 可识别 |
| opacity 0 的 tab 仍在后台执行 onAppear | 如果某个 tab 有重 onAppear 逻辑，需要改用 `if selectedTab == ...` + `.transition()`。当前三个 tab 的 onAppear 都只做简单加载，无副作用 |
