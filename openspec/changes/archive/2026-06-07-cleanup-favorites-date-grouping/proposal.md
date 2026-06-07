## Why

App 目前残留了标准生成（non-random）的逻辑代码，但页面上已删除对应的 Generate 按钮，导致无用代码路径和混淆的命名。同时收藏页仅以简单列表展示，缺少时间分组信息，用户无法直观看到收藏的时间脉络。

## What Changes

- **删除标准生成逻辑**：移除 `generate(random: false)` 路径、"Generate More" 按钮、"Try Again" 调用，移除 Worker 端 `GENERATION_PROMPT`（仅保留 `RANDOM_PROMPT`）
- **重命名 `generateCard`** → `genderCountCard`，消除误导
- **收藏页按日期分组**：按 "今天 / 昨天 / 本周 / 更早" 分组显示，每组显示日期标题

## Capabilities

### New Capabilities
- `favorites-date-grouping`: 收藏列表按日期分组展示

### Modified Capabilities
- `name-generation`: 移除标准生成模式，仅保留随机灵感模式

## Impact

- **GenerateView.swift**: 删除 `generate(random: false)` 相关代码、重命名 `generateCard`、移除 "Generate More" 按钮
- **NameGenieAPI.swift**: 移除 `generateNames(preferences:random:)` 中的 `random: false` 路径调用（API 层保留但仅传 `true`）
- **workers/namegenie-worker/src/index.js**: 移除 `GENERATION_PROMPT` 及相关 `buildPrompt` 调用
- **FavoritesView.swift**: 实现日期分组 UI、Section 标题
- **FavoriteRow**: 新增日期标签展示
