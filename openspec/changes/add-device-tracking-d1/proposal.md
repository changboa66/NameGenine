## Why

服务端没有持久化 device ID，无法统计用户量、无法拉黑频繁触发限流的异常设备。

## What Changes

- 新增 Cloudflare D1 数据库，持久化 device records
- Worker 每次请求时记录/更新 device 信息（首次时间、最后活跃、请求次数）
- Worker 增加黑名单检查，黑名单设备直接 403
- 客户端不变，继续 Keychain 生成 UUID 作为 X-Device-ID

## Capabilities

### New Capabilities
- `device-tracking`: Device 注册、活跃记录、使用统计
- `device-blacklist`: 黑名单管理，拉黑异常设备

### Modified Capabilities

- 无

## Impact

- **Worker**: 新增 D1 binding、请求链路增加黑名单检查 + 异步设备记录
- **wrangler.toml**: 新增 d1_databases 配置（default + production 环境）
- **客户端**: 无改动
