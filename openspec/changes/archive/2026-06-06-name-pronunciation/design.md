## Context

当前 App 展示名字时只显示拼音文本（如 "Lì Huá"），用户（外国人）没有听觉反馈。iOS 17+ 内置 `AVSpeechSynthesizer` 支持高质量中文 TTS，零依赖即可实现发音功能。

## Goals / Non-Goals

**Goals:**
- `PronunciationService` 单例封装 `AVSpeechSynthesizer`，发布 `isSpeaking` 状态
- 逐字发音流程：单字 → 单字 → 全名（带停顿）
- 结果列表每行添加 🔊 按钮，点击播放发音
- 详情页 header 添加 🔊 按钮 + 逐字发音时高亮当前字符
- 无障碍支持：播放状态通知、按钮标签

**Non-Goals:**
- 不改变 API 数据模型（现有 pinyin 已足够）
- 不做跨视图播放同步（详情页和列表页独立控制）
- 不做录音/跟读比对功能

## Decisions

### PronunciationService 架构

```
┌────────────────────────────────────────────┐
│            PronunciationService             │
│               (ObservableObject)            │
│                                              │
│  AVSpeechSynthesizer ── delegate ──────┐     │
│       +                                │     │
│  发音队列管理                            │     │
│       +                                │     │
│  @Published isSpeaking: Bool           │     │
│  @Published currentCharIndex: Int?     │     │
│                                          │     │
│  func speak(hanzi: String, pinyin: String)   │
│  func stop()                               │
└────────────────────────────────────────────┘
```

单例模式，任意视图可触发、监听状态。

### 发音流程

```
speak("丽华", "Lì Huá")

Step 1: AVSpeechUtterance("丽")
         rate: 0.3, postUtteranceDelay: 0.25
         → currentCharIndex = 0
         → TTS 自动读 "Lì"（iOS TTS 对单字准确）

Step 2: AVSpeechUtterance("华")
         rate: 0.3, postUtteranceDelay: 0.25
         → currentCharIndex = 1
         → TTS 自动读 "Huá"

Step 3: AVSpeechUtterance("丽华")
         rate: 0.35
         → currentCharIndex = nil
         → TTS 自动读 "Lì Huá"
```

逐字节点的 `postUtteranceDelay` 利用 `AVSpeechSynthesizer` delegate `didFinish` 回调驱动。注意：iOS 的 `AVSpeechSynthesisIPANotationAttribute` 不支持 zh-CN，故不附加 IPA 注音，依赖 TTS 对常见名字用字的识别准确度。

### 列表页 - NameResultRow

```
┌──────────────────────────────────┐
│  丽华              🔊            │
│  Lì Huá                          │
│  Classic — bright radiance       │
│  ▓▓▓▓░░░░░░░░░░░░░░░░░░░░       │
└──────────────────────────────────┘

• 🔊 按钮点击 → PronunciationService.shared.speak(...)
• 播放中按钮变为 ⏹（停止）
• 可选 ProgressView 进度条
• 按钮 disabled 条件：isSpeaking
• accessibility: "播放丽华的发音" / "停止播放"
```

NameResultRow 当前定义在 `GenerateView.swift` 中，建议保持 inline 修改。

### 详情页 - NameDetailView header

```
播放前:                         播放中:
┌──────────────────┐           ┌──────────────────┐
│         🔊        │           │      🔊 ▶        │
│                   │           │                   │
│     丽华          │           │  ██ 丽 ██  华     │ ← 高亮
│   Lì Huá         │           │  Lì   Huá         │
│                   │           │                   │
│  Meaning: ...     │           │  Meaning: ...     │
└──────────────────┘           └──────────────────┘

• 播放时 currentCharIndex 驱动高亮
• 字符高亮: .foregroundStyle(.accentColor) + .scaleEffect(1.1)
• 对应拼音也高亮
• 播放结束所有高亮恢复
```

### 无障碍设计

| 元素 | 标签 | 附加 |
|------|------|------|
| 🔊 按钮 | "播放{名字}的发音" | `.startsMediaSession` trait |
| 播放中按钮 | "停止播放" | — |
| 逐字高亮 | "当前发音：丽 Lì" | post `.announcement` |
| 播放结束 | — | post `.announcement("播放结束")` |
| 列表进度条 | — | 移除 accessibility（纯装饰） |

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 多音字 TTS 读错 | iOS TTS 对常见名字用字准确度高；逐字发音时上下文明确，进一步降低错误率 |
| AVSpeechSynthesizer 被其他音频打断 | 使用 `.ambient` 音频 session category，不抢占其他音频 |
| 快速连点导致队列混乱 | `speak()` 内部先 `stop()` 清空队列再开始新发音 |
| iOS 语音引擎变化 | 使用系统默认 zh-CN 语音，不指定特定 voice identifier |
