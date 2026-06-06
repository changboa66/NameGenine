## Context

当前加载状态仅在按钮内显示系统 `ProgressView()` + "Generating..." 文字，视觉上不够有趣。探索模式下已确认走 Lottie 路线。

## Goals / Non-Goals

**Goals:**
- 添加 Lottie iOS SDK（SPM）依赖
- 创建 `LottieView`（UIViewRepresentable 桥接）
- 选取一个免费可商用奔跑熊猫 Lottie JSON
- GenerateView 加载态显示奔跑熊猫动画，结束后平滑过渡到结果
- Lucky 按钮共享同一加载动画

**Non-Goals:**
- 不改变现有按钮布局和交互逻辑
- 不改动结果展示方式
- 不涉及 detail/favorites 等其他视图
- 不做多动画素材切换

## Decisions

### 动画位置：全屏 overlay 居中

加载时在整个 ScrollView 上方覆盖一个半透明遮罩层，熊猫动画居中展示：

```
┌──────────────────────────────┐
│         取名                   │
│    Tell us about yourself     │
│                              │
│   [Gender │ Phonetic│ ...]   │ ← 表单变暗（被遮罩覆盖）
│                              │
│   ┌──────────────────────┐   │
│   │   Generate Names      │   │
│   └──────────────────────┘   │
│                              │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│ ← 半透明遮罩 (black.opacity(0.3))
│                              │
│          🐼🏃🏃🏃              │ ← 居中，无视滚动
│        正在取名中...          │
│                              │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
└──────────────────────────────┘
```

**理由**: ①视觉效果更有沉浸感/仪式感 ②奔跑动画需要足够尺寸才能看清 ③遮罩层强调"正在处理中，请稍候" ④不依赖 ScrollView 滚动位置

### 动画素材

**选定**: [LottieFiles: Fly](https://lottiefiles.com/free-animation/fly-xMowoXhjMh) — 飞翔熊猫动画

用户确认视觉效果满意。实现时从该页面下载 Lottie JSON 文件，添加到 `NameGenie/Resources/panda-fly.json`。

**许可证**: Lottie Simple License（免费商用）

### LottieView 桥接

```
┌──────────────────────────────┐
│  LottieView                  │
│  ┌────────────────────────┐  │
│  │ UIViewRepresentable     │  │
│  │  └─ LottieAnimationView│  │
│  │    .loop()              │  │
│  │    .play()              │  │
│  └────────────────────────┘  │
│                              │
│  Parameters:                 │
│  • name: String              │
│  • loopMode: .loop           │
│  • contentMode: .scaleAspectFit│
└──────────────────────────────┘
```

### 动画生命周期

```
状态机:

IDLE ──[tap generate]──→ LOADING ──[API返回]──→ RESULTS
                           │                      │
                           │                      │
                      ┌────┴────┐           ┌────┴────┐
                      │ Panda   │           │ Results │
                      │ fade in │           │ fade in │
                      │ .loop() │           │         │
                      └─────────┘           └─────────┘
                           │
                      ┌────┴────┐
                      │ Panda   │
                      │ fade out│
                      └─────────┘
```

过渡使用 SwiftUI `.transition(.opacity)`，duration 0.25s

### project.yml 配置

```yaml
packages:
  Lottie:
    url: https://github.com/airbnb/lottie-spm
    version: ~> 4.5

targets:
  NameGenie:
    dependencies:
      - package: Lottie
```

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 找不到合适的免费奔跑熊猫 Lottie | 放宽到"动态熊猫"即可；极端情况下可退回到 bounce + rotate emoji 🐼 |
| Lottie JSON 文件体积较大 | 选素材时优先选 < 50KB 的；Lottie 本身比 GIF 小 600% |
| SPM 依赖增加构建时间 | Lottie 是常用库，增量构建影响很小 |
| iOS 17+ Lottie 兼容性 | lottie-spm 4.5+ 已支持 iOS 17 |

## Open Questions

_无 — 素材已选定。_
