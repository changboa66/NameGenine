## Why

收藏页当前完全使用系统灰色系，没有任何品牌色或视觉点缀，与 GenerateView 和 NameDetailView 形成明显反差。在 FavoriteRow 中引入风格色小圆点可以同时解决"太素了"的问题和传递"这个收藏属于哪种风格"的有用信息。

## What Changes

- Section header 日期文字改为 `Color.accentColor`，与 app 品牌色统一
- FavoriteRow 新增风格色小圆点（`circle.fill` 8pt），放在含义文本前
- 从 `FavoriteName.meaning` 解析风格前缀（Classic/Modern/Unique），映射为对应颜色（orange/blue/purple），圆点使用该颜色
- 含义文本移除风格前缀（已有 `cleanMeaning` 逻辑可复用），只显示纯含义

## Capabilities

### New Capabilities

*(无 — 纯视觉改动，不引入新的规范级能力)*

### Modified Capabilities

- `day-grouped-list`: FavoriteRow 新增风格指示器（colored dot），含义文本不再显示风格前缀；Section header 使用 accentColor

## Impact

- **`Views/FavoritesView.swift`**: FavoriteRow 新增 `style` 计算属性 + `styleColor` 映射 + 小圆点 UI；Section header 添加 `.foregroundStyle(Color.accentColor)`；含义文本需要清理前缀
- **其他文件**: 无直接影响
