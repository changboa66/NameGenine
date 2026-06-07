## Context

App 目前有两个生成入口代码路径：
- `generate(random: false)` — 标准生成（对应 `GENERATION_PROMPT`），但页面上的 Generate 按钮已删除
- `generate(random: true)` — 随机灵感（对应 `RANDOM_PROMPT`），通过 "I'm Feeling Lucky" 触发

收藏页（`FavoritesView`）使用 SwiftData 的 `@Query` 按 `createdAt` 降序排列，但 UI 仅展示汉字、拼音、含义，未利用 `createdAt` 字段。

## Goals / Non-Goals

**Goals:**
- 移除标准生成的全部代码路径（iOS + Worker）
- 重命名 `generateCard` 为 `genderCountCard`
- 收藏页按日期分组展示（今天、昨天、本周、更早）
- 每组显示日期标题，行内显示收藏时间

**Non-Goals:**
- 不修改 `FavoriteName` 数据模型（`createdAt` 已存在）
- 不涉及 iCloud 同步
- 不添加编辑/删除分组功能

## Decisions

### 收藏日期分组策略

按 `createdAt` 将收藏分为 4 个区间：

| 分组 | 条件 |
|------|------|
| 今天 | `createdAt` 是今天（`Calendar.current.isDateInToday`）|
| 昨天 | `createdAt` 是昨天（`Calendar.current.isDateInYesterday`）|
| 本周 | `createdAt` 在本周内且不是今昨 |
| 更早 | 本周之前 |

### 日期显示格式

- 分组标题：中文 "今天" / "昨天" / "本周" / "更早"
- 行内时间标签：显示相对时间，如 "10:30"、"昨天"、"6/5"

### 数据流

```
FavoritesView
  └─ @Query(sort: \FavoriteName.createdAt, order: .reverse)
       └─ 按 createdAt 分组
            ├─ 今天: [name1, name2, ...]
            ├─ 昨天: [name3, ...]
            ├─ 本周: [name4, ...]
            └─ 更早: [name5, ...]
```

### Worker 清理

移除 `GENERATION_PROMPT` 常量及其 `buildPrompt` 调用，仅保留 `RANDOM_PROMPT`。`action === 'generate'` 分支直接使用随机 prompt。`random` 参数变为可选。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 已有用户收藏了标准生成的名字，删除标准路径不影响已存数据 | 收藏数据存于 SwiftData，生成路径删除不影响已存数据 |
| `GENERATION_PROMPT` 移除后无法恢复 | 保留在 git 历史中，可回滚 |
