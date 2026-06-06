## Why

SURNAME 和 PRONUNCIATION 两个输入框目前分属两张卡片——SURNAME 在 generateCard，PRONUNCIATION 在 aboutYouCard。但两者语义上是同类输入（都是"关于你"的文字信息），分开反而增加认知负担。合并后减少一张卡片，布局更紧凑，逻辑更清晰。

## What Changes

- 从 generateCard 移除 SURNAME 输入框
- 移除 aboutYouCard（原只有 PRONUNCIATION）
- 新增一张 "YOUR NAME" 卡片，包含 SURNAME 和 PRONUNCIATION 两个输入框，垂直堆叠
- 卡片标题改为 "YOUR NAME"
- 三段卡布局变为三段，但内容重新分配

## Capabilities

### New Capabilities
- *无* — 纯 UI 重构，没有新能力

### Modified Capabilities
- *无* — 没有 spec 级别的行为变更，输入输出不变

## Impact

- `GenerateView.swift`: 修改 `generateCard`（移除 surname），删除 `aboutYouCard`，新增合并卡片
- `GenerationPreferences.swift`: 模型不变，不需要改
- 预览效果：三段卡从 [GENDER/COUNT/SURNAME] [MEANINGS] [PRONUNCIATION] 变为 [GENDER/COUNT] [MEANINGS] [YOUR NAME(SURNAME+PRONUNCIATION)]
