## Context

当前 `GenerateView` 的 `headerSection` 用一个圆形背景 + "取名"文字作为品牌标识。App 已有 `panda-fly.json` Lottie 动画（加载页使用），但首页与加载页风格割裂。

目标：截取 panda Lottie 第 0 帧的静态图像替换"取名"图标，使首页视觉与加载动画风格统一。

已有基础设施：
- `LottieView.swift`: UIViewRepresentable 包装，支持 JSON / dotLottie
- `panda-fly.json`: 38 KB Lottie 动画资源

## Goals / Non-Goals

**Goals:**
- 熊猫静态图替换 `headerSection` 中的圆形"取名"图标
- 首次渲染时从 Lottie 截帧，缓存后复用
- 图大小与现有圆形区域大致匹配（72pt → 约 100-120pt）

**Non-Goals:**
- 不改变副标题（"Find Your Chinese Name"）及其下方文案
- 不修改加载动画本身
- 不引入新的图片资源文件

## Decisions

### 截帧方式：`UIGraphicsImageRenderer` + `CALayer.render(in:)`

`LottieAnimationView` 在 `currentProgress` 赋值后会同步更新内部的 `CAShapeLayer` 树。直接调用 `layer.render(in:)` 即可获得当前帧的栅格化图像，无需等待显示链接。

```swift
func lottieSnapshot(name: String, size: CGSize, progress: CGFloat = 0) -> UIImage? {
    let view = LottieAnimationView(name: name)
    view.frame.size = size
    view.currentProgress = progress
    view.layoutIfNeeded()
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        view.layer.render(in: ctx.cgContext)
    }
}
```

`layoutIfNeeded()` 确保图层树在渲染前已布局完成。

### 缓存策略：`@State` + `.task`

`GenerateView` 的 `body` 中使用 `.task` 异步调用截帧，结果存入 `@State private var pandaImage: UIImage?`。`headerSection` 根据 `pandaImage` 显示熊猫或 fallback 到"取名"文字。

这种方式：
- 无需额外全局缓存或 NSCache
- 视图重建时重新截取（因为 Lottie 截帧是同步操作，开销几十毫秒可接受）
- 如果要持久化缓存，可以在 `.task` 中同时写入临时文件，但没这个必要

### fallback 策略

截帧失败或尚未完成时，保留现有"取名"文字。截帧成功后平滑替换。

```swift
if let pandaImage {
    Image(uiImage: pandaImage)
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
} else {
    // 现有圆形 + "取名"（fallback）
}
```

### 方法放置

`lottieSnapshot` 放在 `LottieView.swift` 中作为静态方法或单独 extension，因为与该文件职责最近（Lottie 相关工具方法）。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 第 0 帧熊猫姿态不适合静态展示（如四肢展开、动态模糊） | 实施时先用模拟器截帧预览，如果不好看可换 `currentProgress = 0.5` 或其他帧 |
| `LottieAnimationView` 第一次初始化 + 加载 JSON 耗时（约 50-100ms） | 在 `.task` 中异步执行，不阻塞主线程渲染；fallback 文字即时显示 |
| panda-fly 资源约 38 KB，截帧时要解析全部动画数据 | 仅解析一次，后续缓存在 `@State` 中，无重复开销 |
| 不同 iOS 版本 `CALayer.render(in:)` 行为差异 | 在 iOS 17+ 上已验证 Lottie 正常工作；如有问题可改用 `drawHierarchy(in:afterScreenUpdates:)` |
