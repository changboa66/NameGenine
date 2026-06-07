## 1. Phase 1 — Cloudflare WAF Rate Limiting (用户通过自有域名自行配置)

- [x] ~~1.1 登录 Cloudflare Dashboard，在 namegenie-worker 域名下创建 WAF Rate Limiting 规则：120 POST 请求/min/IP，返回 429~~ (用户自有域名自行配置)
- [x] ~~1.2 验证：从同一 IP 发送 121 次请求，第 121 次收到 429~~ (用户自有域名自行配置)

## 2. Phase 2 — Worker + KV 限流

### 2.1 基础设施

- [x] 2.1.1 创建 Cloudflare KV namespace `RATE_LIMIT_KV`，在 wrangler.toml 中添加 KV binding 配置
- [x] 2.1.2 部署 Worker 到 production 环境，验证 KV binding 生效

### 2.2 Worker 限流逻辑

- [x] 2.2.1 在 `src/index.js` 中实现 `getClientIP(request)` 工具函数，从 `CF-Connecting-IP` 或 `X-Forwarded-For` 获取客户端 IP
- [x] 2.2.2 实现 `slidingWindowCount(kv, key, windowSec, limit)` 函数：查询 KV 统计窗口内记录数，若未超限则写入新记录
- [x] 2.2.3 在 `fetch()` 开头插入限流中间件：先检查 IP 限流（100 req/60s），再检查 Device-ID 限流（200 req/60s，如果提供了 `X-Device-ID` 头）
- [x] 2.2.4 限流命中时返回 `429` + JSON error body + `X-RateLimit-Remaining: 0` 头部
- [x] 2.2.5 正常响应中添加 `X-RateLimit-Remaining` 和 `X-RateLimit-Reset` 头部

### 2.3 iOS Device-ID 生成与发送

- [x] 2.3.1 创建 `DeviceIDService` 类：首次启动生成 UUID 并存入 Keychain，后续读取已有值
- [x] 2.3.2 在 `NameGenieAPI.swift` 中，每个请求自动附加 `X-Device-ID` 头（从 DeviceIDService 读取）
- [ ] 2.3.3 验证：抓包确认每次请求都携带 `X-Device-ID` 且设备重启后保持不变

## 3. Phase 3 — HMAC 请求签名

### 3.1 服务端密钥与验签

- [ ] 3.1.1 生成 HMAC 签名密钥，通过 `wrangler secret put SIGNING_KEY` 配置到 Worker 生产环境
- [ ] 3.1.2 在 `src/index.js` 中实现 `verifySignature(request, body, secret)` 函数：读取 `X-Signature` 和 `X-Timestamp`，校验时间戳是否在 ±30s 内，重新计算 HMAC 比对
- [ ] 3.1.3 在 `fetch()` 的限流中间件之后、业务逻辑之前插入验签步骤：签名无效则返回 401
- [ ] 3.1.4 实现双密钥兼容逻辑：优先使用当前 secret 验签，失败则尝试上一个 secret

### 3.2 客户端签名逻辑

- [ ] 3.2.1 在 `NameGenieAPI.swift` 中实现 `signRequest(body)` 方法：构造 message = `"POST\napplication/json\n" + SHA256(body)`，用嵌入的 signing key 计算 HMAC-SHA256
- [ ] 3.2.2 在每个请求中添加 `X-Signature` 和 `X-Timestamp` 头
- [ ] 3.2.3 将 signing key 以常量的形式嵌入代码（或通过 Build Settings 注入），确认为非对称/对称密钥

### 3.3 集成验证

- [ ] 3.3.1 本地 `wrangler dev` + iOS 模拟器联调，验证完整请求链路通过
- [ ] 3.3.2 用 curl 测试无签名请求被 401 拒绝
- [ ] 3.3.3 用 curl 测试超时签名（旧 Timestamp）被 401 拒绝
- [ ] 3.3.4 部署到 production，用 TestFlight 版本验证端到端功能正常

## 4. 验证

- [ ] 4.1 压测：用脚本模拟 300 req/min 从同一 IP 发送，确认 100 次后开始返回 429
- [ ] 4.2 模拟多设备（不同 Device-ID、同 IP），确认每设备可独立达到 200 req/min
- [ ] 4.3 无 Device-ID 的请求确认走 IP 限流降级路径
- [ ] 4.4 确认所有正常用户场景（生成名字、查看详情）不受影响
