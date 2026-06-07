## 1. 清理标准生成逻辑

- [x] 1.1 Worker: 移除 `GENERATION_PROMPT` 常量，`fetch()` 中 `action === 'generate'` 直接使用随机 prompt
- [x] 1.2 iOS: 重命名 `generateCard` → `genderCountCard`
- [x] 1.3 iOS: 移除 `preferencesSection` 中的 `generate(random: false)` 路径、"Generate More" 按钮、"Try Again" 按钮
- [x] 1.4 iOS: 清理 `loadMore()` 和 `generate()` 中的非随机逻辑，`NameGenieAPI.generateNames()` 默认 `random: true`
- [x] 1.5 iOS: 移除客户端的 `resultCache`（标准生成不再存在）和 `isRandomMode` 状态变量

## 2. 收藏页日期分组

- [x] 2.1 创建 `DateGroup` 辅助类型，按 `createdAt` 将 favorites 分组为 今天/昨天/本周/更早
- [x] 2.2 实现分组 Section 标题视图（"今天" / "昨天" / "本周" / "更早"）
- [x] 2.3 `FavoriteRow` 中新增日期标签，按相对时间显示（今天→"10:30"，昨天→"昨天"，本周→"周一"，更早→"6/5"）
- [x] 2.4 部署 Worker 到 production
- [x] 2.5 验证：收藏页正确分组，数据无丢失
