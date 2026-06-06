## Why

生成的汉语名字目前只有拼音文本展示，用户（外国人）不知道怎么读。添加 TTS 发音功能，让用户能听到名字的正确读法，并且逐字发音帮助学习每个字的读音。

## What Changes

- 新建 `PronunciationService` 单例，封装 `AVSpeechSynthesizer`
- 新增逐字发音 + 完整名字发音流程（字→字→全名）
- 生成结果列表 `NameResultRow` 添加 🔊 发音按钮
- 详情页 `NameDetailView` 添加 🔊 发音按钮 + 逐字高亮动画
- 完整无障碍支持（VoiceOver 标签 + 播放状态通知）

## Capabilities

### New Capabilities

- `pronunciation`: TTS 发音能力，支持逐字朗读 + 完整名字朗读，列表页和详情页均可触发

### Modified Capabilities

_无_

## Impact

- **新增文件**: `Services/PronunciationService.swift`（AVSpeechSynthesizer 封装）
- **修改文件**: `Views/NameResultRow.swift`（加 🔊 按钮）、`Views/NameDetailView.swift`（加 🔊 按钮 + 逐字高亮）
- **依赖**: 无新增（AVSpeechSynthesizer 为 iOS 内置）
