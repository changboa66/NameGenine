## Context

NameGenie 的 iOS App 通过 POST 请求直接调用 Cloudflare Worker (namegenie-worker)，Worker 再调用 DeepSeek API。当前无认证、无签名、无限流，API URL 和请求格式完全暴露在客户端二进制和网络流量中。

```
[iOS App] ──POST──▶ [Cloudflare Worker] ──POST──▶ [DeepSeek API]
                      无认证  无限流  无签名
```

## Goals / Non-Goals

**Goals:**
- 防止攻击者无限制调用 API 导致 DeepSeek 资损
- 分三阶段渐进交付，每阶段独立可部署
- 对正常用户完全透明（无感知、无额外等待）
- 保证现有功能不变，不需要用户升级也可继续使用（阶段 1 无需客户端更新）

**Non-Goals:**
- 用户认证/账号系统（不引入登录注册）
- 数据加密（API 已通过 HTTPS 传输）
- Web 端防护（目前仅 iOS 客户端）
- 防逆向工程（App Attestation 留作未来 option）

## Decisions

### 识别维度选择

| 维度 | 优点 | 缺点 | 用于阶段 |
|------|------|------|---------|
| IP 地址 | 零客户端改动，立即可用 | 共享 IP 误杀，VPN 绕过 | 1 (WAF), 2 (KV) |
| Device-ID | 粒度精确，绑定设备 | 需客户端生成+存储+发送 | 2 (KV) |
| User-Agent | 简单 | 极易伪造 | 辅助识别 |

**决策**: 阶段 2 使用 IP + Device-ID 双维度，任一维度超限即阻断。

### KV 限流算法选择

```
Fixed Window:             Sliding Window:
  00:00 ┌──────┐          00:00 ┌──────┐
        │  200  │                │  180  │ ← 前窗口部分计数
  01:00 └──────┘          01:00 └──────┘
        │  200  │          当前: +20（新窗口部分）
        └──────┘
  问题: 窗口边界可能     更平滑，但 KV 实现略复杂
  双倍放行
```

**决策**: 使用 Sliding Window Log 模式。KV key 设计为 `rl:{ip|device}:{timestamp}`，TTL 自动过期。每次请求查询窗口内记录数。KV 的最终一致性意味着并发峰值可能多放行 1-2 个请求，但对防滥用来说可接受。如需精确限流，未来可迁移至 Durable Objects。

### HMAC 签名方案

```
iOS App → 签名:
  message = HTTP-Method + "\n" + Content-Type + "\n" + Body-SHA256
  signature = HMAC-SHA256(secret, message)
  Header: X-Signature: <hex(signature)>
  Header: X-Timestamp: <unix-ts>  ← 防重放

Worker → 验签:
  1. 校验 X-Timestamp 在 ±30s 内（防重放攻击）
  2. 用同样的方式计算期望签名
  3. 比对 → 不一致则 401
```

**密钥管理**: 签名密钥作为 Worker secret 存储（`wrangler secret put SIGNING_KEY`），iOS 端编译时通过 `Info.plist` 或代码常量嵌入。虽然密钥可被逆向提取，但提取门槛远高于直接抓包重放。

### 防止客户端密钥泄露的影响范围

即使密钥泄露，攻击者仍然需要面对：
- 阶段 1 + 2 的 IP 和 Device-ID 限流
- 签名中的 Timestamp 防 30s 以上重放
- 密钥可在不更新客户端的前提下轮换（服务端优先验证新密钥，兼容旧密钥）

## 整体架构

```
阶段 1: WAF Rate Limiting

[Internet] ──▶ [Cloudflare Edge] ──▶ [Worker] ──▶ [DeepSeek]
                    │
           Rate Limit Check: 60 req/min/IP
                    │
                 429 ← 超限


阶段 2: Worker + KV 限流

[iOS App]          [Worker]                      [KV]
   │     POST       │    sliding window read       │
   ├────────────────▶    ──────────────────────────▶│
   │ X-Device-ID    │                              │
   │                │    count within limit?        │
   │                │◀──────────────────────────────│
   │                │      │                        │
   │                │   YES / NO                    │
   │                │      │                        │
   │                │  YES ──▶ DeepSeek             │
   │◀───────────────│  NO  ──▶ 429                  │
   │                │                              │
   │  每个响应返回  │  X-RateLimit-Remaining: N     │
   │  限流头部      │  X-RateLimit-Reset: ts       │
   └────────────────┘                              └────┘


阶段 3: HMAC 请求签名

[iOS App]                         [Worker]
   │                                │
   │  Body + Secret                 │
   │  ──▶ HMAC-SHA256               │
   │  ──▶ X-Signature               │
   │                                │
   │  POST                          │
   │  X-Signature: <hex>            │
   │  X-Timestamp: <unix-ts>        │
   ├───────────────────────────────▶│
   │                                │  验签:
   │                                │  1. Timestamp ±30s?
   │                                │  2. HMAC 匹配?
   │                                │  3. 都通过 → 继续
   │                                │     否则 → 401
   │                                │
   │◀───────────────────────────────│
   │  200 OK / 401 Unauthorized     │
   └────────────────────────────────┘
```

## 三阶段合并后的请求/响应链路

```
[iOS] ──▶ [Cloudflare Edge] ──▶ [Worker] ──▶ [DeepSeek]
           ① WAF 限流         ② IP 限流
                              ③ Device-ID 限流
                              ④ HMAC 验签
                              ⑤ 处理请求

每个响应:
  X-RateLimit-Remaining: <剩余次数>
  X-RateLimit-Reset: <窗口重置时间>
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| KV 最终一致性导致超限漏放 | 将 limit 设为安全余量（如预期 * 0.8），漏放几个不会造成实质伤害 |
| Device-ID 被清空（用户重置 Keychain） | 下次启动重新生成，旧的限流记录自动过期 |
| 多设备共享同一公网 IP 误杀 | 双维度（IP + Device-ID），只要 Device-ID 正常就不影响 |
| 签名密钥在客户端泄露 | 密钥可服务端轮换，配合限流大幅降低泄露影响 |
| WAF 误杀正常用户 | 从宽松阈值开始（120/min），根据日志逐步收紧 |

## Open Questions

- WAF Rate Limiting 使用 Cloudflare Free 计划还是 Pro 计划？Free 计划有基础的 rate limiting（企业版需要 Pro）
- Device-ID 是否需要用户可选重置（隐私考虑）？
- 密钥轮换策略：是否需要在 iOS 端做远程配置下发？
