## Context

NameGenie Worker 目前使用 KV 做限流（`rl:device:<uuid>`），key 带 TTL，不会持久化。服务器无法知道有多少唯一设备使用过 app，也无法拉黑异常设备。

客户端通过 `DeviceIDService` 在 Keychain 生成并持有一个 UUID，随每个请求的 `X-Device-ID` header 发送。这个机制保留不变。

## Goals / Non-Goals

**Goals:**
- 持久化每个 device 的首次使用时间、最后活跃时间、总请求次数
- 在请求链路中增加黑名单检查，被拉黑的设备返回 403
- 提供 SQL 查询能力：总用户数、活跃用户数、设备列表排序

**Non-Goals:**
- 客户端逻辑改动（Keychain / DeviceIDService 不动）
- 不做用户账户系统、不做认证
- 不做实时分析仪表盘

## Decisions

### 1. D1 而非 KV

KV 不支持 COUNT/WHERE 查询，统计用户量必须遍历所有 key。D1 的 SQL 能力恰好满足需求。

### 2. 异步写入，不阻塞响应

```
请求入口 → 签名验证 → 黑名单检查(同步) → 限流 → 处理 DeepSeek → 返回响应
                                                                  ↓
                                                          ctx.waitUntil(
                                                            更新 D1 devices 表
                                                          )
```

黑名单检查需要同步（否则恶意设备已消耗资源），设备记录不紧急，后台写入。

### 3. client 侧 UUID 不变

不引入"服务器生成 ID 返回客户端"的鸡生蛋问题。继续用 Keychain UUID，D1 以 UUID 为主键 upsert。

### 4. ON CONFLICT upsert

```
INSERT INTO devices (id, first_seen, last_seen, req_count) VALUES (?, ?, ?, 1)
ON CONFLICT(id) DO UPDATE SET last_seen = excluded.last_seen, req_count = req_count + 1
```

`first_seen` 仅 INSERT 时写入，UPDATE 不改。`req_count` 每次累加。

### 5. 黑名单用 D1 而非 KV

黑名单设备也在 devices 表中用 `blacklisted` 字段标记，一次查询就能同时获取设备信息和状态。

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| D1 写入失败不应影响主流程 | 后台写入 + try/catch，静默吞掉错误 |
| 黑名单查询增加延迟 | 查询 `WHERE id=?` 走主键索引，常数时间 |
| Device ID 可被伪造 | 已有 HMAC 签名验证 + IP 限流双重保护 |
