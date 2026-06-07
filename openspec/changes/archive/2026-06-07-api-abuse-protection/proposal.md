## Why

当前 iOS App 直连 Cloudflare Worker API，没有任何认证或限流机制。攻击者抓包即可获取请求格式，无限制调用 DeepSeek API 导致资损。虽然 DeepSeek 单价极低（~$0.00014/请求），但无防护下十万级请求即可造成显著损失。需要建立多层防御体系，在不影响用户体验的前提下控制 API 滥用风险。

## What Changes

- **Phase 1**: 配置 Cloudflare WAF Rate Limiting，按 IP 维度限流（无需代码变更）
- **Phase 2**: Worker + Cloudflare KV 实现滑动窗口限流，支持 IP 和 Device-ID 双维度
- **Phase 3**: 客户端 (iOS) 与 Worker 之间增加 HMAC 请求签名，防止请求格式被直接重放
- iOS 端新增 Device-ID 生成与存储逻辑（Keychain），每次请求携带标识
- Worker 新增 KV binding 配置，用于存储限流计数器

## Capabilities

### New Capabilities
- `rate-limiting`: API 请求限流能力，支持 WAF 边缘限流 + Worker 层滑动窗口限流（IP + Device-ID 双维度）
- `request-signing`: 客户端请求 HMAC 签名与服务器端验签，防止请求被重放和篡改

### Modified Capabilities

- None

## Impact

- **workers/namegenie-worker/src/index.js**: 新增限流逻辑、验签逻辑、KV binding 集成
- **workers/namegenie-worker/wrangler.toml**: 新增 KV namespace 绑定配置
- **NameGenie/Services/NameGenieAPI.swift**: 新增 Device-ID 发送、请求签名逻辑
- **NameGenie/NameGenieApp.swift** 或新 Service 文件：首次启动生成 Device-ID 并存储至 Keychain
- **Cloudflare Dashboard**: 配置 WAF Rate Limiting 规则
- **Cloudflare KV**: 创建 rate-limit KV namespace
- **iOS 无新增依赖**：HMAC 使用 CommonCrypto（系统库），Device-ID 使用 Foundation UUID + Keychain Services
