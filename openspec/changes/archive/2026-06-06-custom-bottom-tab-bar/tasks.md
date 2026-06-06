## 1. CustomTabBar 组件

- [x] 1.1 创建 `CustomTabBar.swift`：定义 `Tab` 枚举（generate/favorites/culture），每个 case 关联 SF Symbol 名称和标签文字
- [x] 1.2 实现 `CustomTabBar` View：HStack 布局，三个 tab 平分宽度，选中的 tab 以 `accentColor` 高亮，未选中为 `.secondary`
- [x] 1.3 添加分割线（`Divider()`）在 tab bar 顶部
- [x] 1.4 添加 home indicator 区域背景色（`Color(.systemBackground)`, `frame(height: 34)`），填满底部安全区
- [x] 1.5 确保 `CustomTabBar` 使用 `.ignoresSafeArea(edges: .bottom)` 使其背景延伸

## 2. ContentView 重构

- [x] 2.1 移除 `TabView`，改用 `ZStack(alignment: .bottom)` + `selectedTab` 状态
- [x] 2.2 集成 `GenerateFlow` / `FavoritesFlow` / `CultureFlow` 三个视图，通过 `.opacity` 切换显示
- [x] 2.3 为 ZStack 应用 `.ignoresSafeArea(edges: .bottom)`
- [x] 2.4 移除不再需要的 `import UIKit`

## 3. GenerateView 适配

- [x] 3.1 从 `GenerateView` 中移除 `NavigationStack` 包裹，body 直接返回 `ScrollView` 内容
- [x] 3.2 将原有 `toolbarBackground(.hidden, for: .navigationBar)` 迁移到 `GenerateFlow`
- [x] 3.3 保留 headerSection 的 `.ignoresSafeArea(edges: .top)` 仅用于 Rectangle 背景
- [x] 3.4 创建 `GenerateFlow`：`NavigationStack` + `VStack(spacing: 0)` { `GenerateViewContent` + `CustomTabBar`(thisTab: .generate) }，应用 `.ignoresSafeArea(edges: .bottom)`，添加 `.navigationDestination`

## 4. FavoritesView 适配

- [x] 4.1 从 `FavoritesView` 中移除 `NavigationStack` 包裹，body 直接返回 `Group` 内容
- [x] 4.2 创建 `FavoritesFlow`：`NavigationStack` + `VStack(spacing: 0)` { `FavoritesView` + `CustomTabBar`(thisTab: .favorites) }，应用 `.ignoresSafeArea(edges: .bottom)`

## 5. CultureView 适配

- [x] 5.1 从 `CultureView` 中移除 `NavigationStack` 包裹，body 直接返回 `ScrollView` 内容
- [x] 5.2 创建 `CultureFlow`：`NavigationStack` + `VStack(spacing: 0)` { `CultureView` + `CustomTabBar`(thisTab: .culture) }，应用 `.ignoresSafeArea(edges: .bottom)`

## 6. 验证

- [x] 6.1 `xcodegen generate` 生成项目文件
- [x] 6.2 `xcodebuild` 编译无报错
- [ ] 6.3 模拟器运行确认 tab bar 贴边无间距，切换 tab 正常工作
- [ ] 6.4 确认推送详情页时 tab bar 随内容滑出
