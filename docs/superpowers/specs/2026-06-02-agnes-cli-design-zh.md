# Agnes CLI 与 npm 包双轨方案设计稿

日期：2026-06-02  
仓库：`jomeswang/agnes-ai-skill`  
状态：待评审

## 目标

为 Agnes 增加一个真正可执行的工具层，让 agent 在常见场景下不再优先手写原始
`curl`，同时继续保留当前 skill 仓库的轻量安装体验。

这套设计要同时满足：

- `agnes-ai-skill` 继续保持轻量，适合 `npx skills add ... -g`
- Agnes 的执行层单独沉淀为 npm 包和 CLI
- 图生图、图生视频等需要远程 URL 的场景，可以自动把本地文件转成临时公网 URL
- 后续 Node 自动流可以直接复用 JS API，而不只是调用命令行

## 核心结论

推荐采用**双轨方案**，而不是 Monorepo 根目录 skill + CLI 源码混放。

### 轨道 1：`agnes-ai-skill`

定位：

- 安装型 skill 仓库
- 面向 Codex / Claude Code / 其他 `SKILL.md` 兼容 agent
- 尽量轻，不把完整 CLI 源码打包进 skill 安装目录

职责：

- `SKILL.md`
- `README.md`
- 最少量必要脚本或 fallback helper
- Agnes 能力说明、模型选择、auth 指导、命令调用策略

### 轨道 2：`agnes-ai-cli`

定位：

- 执行型 npm 包
- 面向 agent、命令行用户、Node 自动流

职责：

- 提供 `agnes` CLI
- 提供 JS API
- 负责真实的 Agnes 请求执行
- 负责本地文件转临时公网 URL
- 负责视频轮询、参数归一化、稳定输出

## 为什么不推荐根目录 Monorepo 直接混放

当前 skill 安装器的典型行为是：**复制选中的 skill 目录**。

如果继续保持：

- 仓库根目录就是 skill
- CLI 源码也放在根目录下的 `packages/`

那么用户安装 skill 时，很可能会把 CLI 源码也一起复制进去。

这会带来几个问题：

- 安装体积变大
- skill 安装目录变重
- 图片、视频、示例、CLI 源码容易一起被带下去
- skill 仓库不再像“安装型 skill”，而更像“全量项目镜像”

所以更合理的边界是：

- `agnes-ai-skill` 只负责教 agent 怎么做
- `agnes-ai-cli` 负责真正去做

## 双轨结构

### 仓库 A：`agnes-ai-skill`

建议保留当前仓库名，继续作为 skill 分发入口。

建议结构：

```text
agnes-ai-skill/
  LICENSE
  README.md
  SKILL.md
  agents/
    openai.yaml
  scripts/
    agnes-media-url.sh
    extract_first_frames.swift
```

说明：

- `scripts/agnes-media-url.sh` 可以先保留，作为 fallback 或调试工具
- 不再把完整 npm CLI 源码塞进这个仓库

### 仓库 / 包 B：`agnes-ai-cli`

建议单独作为 npm 包维护。

建议结构：

```text
agnes-ai-cli/
  LICENSE
  README.md
  package.json
  bin/
    agnes.js
  src/
    cli.ts
    index.ts
    config.ts
    errors.ts
    output.ts
    auth/
      check.ts
      saveKey.ts
    media/
      toPublicUrl.ts
      litterbox.ts
    image/
      generateImage.ts
      normalizeImageRequest.ts
    video/
      generateVideo.ts
      pollVideo.ts
      normalizeVideoRequest.ts
  test/
    cli/
    unit/
```

## 两个轨道怎么衔接

`agnes-ai-skill` 不再鼓励 agent 直接拼原始 `curl`，而是优先按这个顺序执行：

1. 先尝试调用本机已安装的 `agnes` CLI
2. 如果没装 CLI，则尝试 `npx -y agnes-ai-cli ...`
3. 只有在 CLI 不可用或需要最小验证时，才退回原始 `curl`

这样有几个好处：

- skill 继续轻量
- 执行逻辑集中在 CLI
- agent 的调用方式更稳定
- 用户不用每次关心 Agnes 的底层 payload 细节

## CLI 设计

### 设计原则

- 不要把 `generate` 做成过重的层级，例如 `agnes video generate`
- 命令要尽量贴近任务场景，让 agent 好选、人也好记
- 内部实现统一，外部命令清晰

### 技术选型

推荐使用成熟开源库，不建议手写参数解析器。

建议组合：

- `commander`
  - 作为 CLI 主框架
  - 负责子命令、参数解析、`--help`、`--version`
- `zod`
  - 作为参数校验和内部 options 归一化层
  - 让 CLI 参数校验和 JS API 参数校验复用同一套规则
- Node 原生 `fetch` / `FormData`
  - 作为 Agnes API 与 Litterbox 上传的 HTTP 层
  - 尽量避免为简单请求额外引入过多网络依赖
- 可选 `picocolors`
  - 用于命令行输出的轻量着色
  - 不是必须依赖

不建议作为第一选择：

- `yargs`
  - 功能很强，但对这个项目来说偏重
- `cac`
  - 可以用，但在多层命令和帮助信息组织上不如 `commander` 稳妥

当前推荐结论：

- CLI 框架：`commander`
- 参数校验：`zod`
- HTTP / 上传：Node 原生 `fetch` + `FormData`
- 输出美化：可选 `picocolors`

### 推荐命令树

```text
agnes auth check
agnes auth save-key [--key <value>]

agnes media url <file-or-url> [--ttl 1h|12h|24h|72h]

agnes image text2img --prompt <text> [options]
agnes image img2img --image <path-or-url> --prompt <text> [options]
agnes image compose --image <path-or-url> --image <path-or-url> --prompt <text> [options]

agnes video text2video --prompt <text> [options]
agnes video img2video --image <path-or-url> --prompt <text> [options]
agnes video multivideo --image <path-or-url> --image <path-or-url> --prompt <text> [options]
agnes video keyframes --image <path-or-url> --image <path-or-url> --prompt <text> [options]
agnes video poll <task-id> [--interval 3] [--timeout 600]
```

### 为什么这样设计

- `text2img`、`img2img`、`text2video`、`img2video` 足够直观
- `keyframes` 单独暴露更清晰，因为它本来就是 Agnes 的特殊模式
- `poll` 是视频异步任务的一等操作，不应该被埋掉
- 比 `video generate` 更利落，也更容易让 agent 命中

### `--help` 设计要求

CLI 必须内建完整帮助系统，而不是只在 README 里说明。

至少要支持：

```bash
agnes --help
agnes auth --help
agnes media --help
agnes image --help
agnes image img2img --help
agnes video --help
agnes video keyframes --help
```

每一层帮助都应包含：

- 这个命令的用途
- 必填参数
- 可选参数
- 至少 1 个最小示例
- 与 Agnes request shape 对应的场景说明

例如 `agnes video keyframes --help` 应明确说明：

- 这是 Agnes `keyframes` 模式
- 需要 2 张或以上图片
- `--image` 可重复传入
- 常用参数：
  - `--width`
  - `--height`
  - `--num-frames`
  - `--frame-rate`
  - `--seed`
  - `--json`

帮助信息应同时面向：

- 人类开发者
- 直接读取命令输出的 agent

### 是否保留别名

可以保留，但不作为主入口：

- `agnes image generate` -> `agnes image text2img`
- `agnes video generate` -> `agnes video text2video`

skill 文档和 agent 提示里应该优先使用明确命令，不优先使用别名。

## JS API 设计

CLI 面向人和 agent，JS API 面向 Node 自动流。

### 公共导出建议

```ts
mediaUrl(input, options?)
checkAuth()
saveKey(key, options?)
generateImage(options)
generateVideo(options)
pollVideo(taskId, options?)
```

### 为什么内部要统一成 `generateImage` / `generateVideo`

因为 Agnes 的能力并不是单一路径：

图片：

- 文生图
- 图生图
- 多图合成

视频：

- 文生视频
- 单图生视频
- 多图生视频
- keyframes 生视频

所以：

- 对外 CLI：按场景命令拆开
- 对内 API：统一收口

这样最稳，也最不容易在后期越做越乱。

## 参数归一化规则

### `generateImage(options)`

建议参数：

```ts
type GenerateImageOptions = {
  model?: "agnes-image-2.1-flash" | "agnes-image-2.0-flash"
  prompt: string
  images?: string[]
  size?: string
  responseFormat?: "url"
  seed?: number
  ttl?: "1h" | "12h" | "24h" | "72h"
}
```

归一化规则：

- 没有 `images` -> 文生图
- `images.length >= 1` 且模型是 2.1 -> `extra_body.image`
- `images.length >= 1` 且模型是 2.0 -> `tags: ["img2img"]` + `extra_body.image`

### `generateVideo(options)`

建议参数：

```ts
type GenerateVideoOptions = {
  prompt: string
  images?: string[]
  mode?: "standard" | "keyframes"
  width?: number
  height?: number
  numFrames?: number
  frameRate?: number
  seed?: number
  negativePrompt?: string
  ttl?: "1h" | "12h" | "24h" | "72h"
}
```

归一化规则：

- 没有 `images` -> 文生视频
- `images.length === 1` -> Agnes 顶层 `image`
- `images.length >= 2` 且 `mode !== "keyframes"` -> `extra_body.image`
- `images.length >= 2` 且 `mode === "keyframes"` -> `extra_body.image + extra_body.mode = "keyframes"`

## 本地文件转公网 URL

这是这次设计里最关键的一段。

Agnes 官方文档当前写的是：

- 图生图：传图片 URL
- 图生视频：传图片 URL
- 多图 / keyframes：也是图片 URL 数组

所以 CLI 应自动做这件事：

- 如果 `--image` 已经是 `http://` 或 `https://`，直接使用
- 如果 `--image` 是本地路径，先上传到临时文件托管服务
- 拿到公网 URL 后，再调用 Agnes

### 第一版上传 provider

第一版建议使用 **Litterbox**：

- 免费
- 接口简单
- 已经验证过可用
- 足够做临时桥接层

### Provider 抽象

后面不要把 CLI 写死在 Litterbox 上，建议一开始就留出抽象：

```ts
interface MediaUrlProvider {
  upload(localPath: string, options?: { ttl?: string }): Promise<string>
}
```

第一版实现：

- `LitterboxMediaUrlProvider`

未来可扩展：

- Cloudinary
- Google Cloud Storage
- 用户自定义 provider

## 输出协议

CLI 应同时支持：

- 默认输出：给人看
- `--json`：给 agent / 自动流看

### 默认输出建议

- `agnes media url`：只打印 URL
- 图片命令：只打印生成结果 URL
- 视频创建命令：打印 `task_id` + 状态
- `agnes video poll`：打印最终视频 URL + 状态摘要

### `--json` 建议

统一输出机器可读结构，例如：

```json
{
  "ok": true,
  "url": "https://litter.catbox.moe/abc123.jpg",
  "source": "litterbox"
}
```

```json
{
  "ok": true,
  "taskId": "task_123",
  "status": "queued"
}
```

## 认证设计

CLI 需要沿用当前 skill 已经建立好的 Agnes key 规则。

### `agnes auth check`

职责：

- 检查 `AGNES_API_KEY` 是否存在
- 输出当前是否可直接调用 Agnes

### `agnes auth save-key`

职责：

- 将 `AGNES_API_KEY` 写入：
  - zsh -> `~/.zshrc`
  - bash -> `~/.bashrc`
  - fallback -> `~/.profile`
- 更新已有 export 或追加新 export
- 不回显完整 key

## 错误处理

CLI 不能只把底层原始异常裸抛给 agent，建议统一成稳定错误类别：

- auth missing
- local file missing
- upload failed
- Agnes request failed
- Agnes task timeout
- invalid arguments

`--json` 下错误也应该保持结构化：

```json
{
  "ok": false,
  "code": "UPLOAD_FAILED",
  "message": "Failed to upload local file to Litterbox"
}
```

## 测试建议

### 单元测试

- 参数归一化
- 本地路径与远程 URL 透传逻辑
- shell rc 文件选择逻辑
- JSON 输出格式

### CLI 测试

- `agnes media url https://example.com/x.png`
- `agnes image text2img --help`
- `agnes video keyframes --help`
- `agnes auth check`

### 集成测试

默认 mock：

- Litterbox 上传
- Agnes API

live test 显式开启：

- 要求 `AGNES_API_KEY`
- 要求显式 opt-in

## 与 skill 的集成方式

`agnes-ai-skill` 后续应更新为：

- 优先使用 CLI
- 只有在 CLI 不可用时才退回 `curl`

推荐执行优先级：

1. `agnes ...`
2. `npx -y agnes-ai-cli ...`
3. 原始 `curl`

这能让：

- skill 仓库保持轻
- CLI 真正承担执行责任
- agent 的调用更稳定

## 发布方式

### `agnes-ai-skill`

继续作为 GitHub skill 仓库分发：

- `npx skills add jomeswang/agnes-ai-skill -g`

### `agnes-ai-cli`

单独发布到 npm：

- 包名优先：`agnes-ai-cli`
- 如果名字已占用，再退到：`@jomeswang/agnes-ai-cli`

CLI 执行文件名：

- `agnes`

## 实施顺序

### Phase 1

- 初始化 `agnes-ai-cli`
- 实现：
  - `auth check`
  - `auth save-key`
  - `media url`

### Phase 2

- 实现图片命令：
  - `text2img`
  - `img2img`
  - `compose`

### Phase 3

- 实现视频命令：
  - `text2video`
  - `img2video`
  - `multivideo`
  - `keyframes`
  - `poll`

### Phase 4

- 更新 `agnes-ai-skill`
- 将 CLI 作为首选执行路径
- 保留 shell helper 作为 fallback

## 成功标准

这套双轨方案算成功，当且仅当：

1. skill 安装不再把完整 CLI 源码一起打包下去
2. agent 能通过 CLI 稳定完成 Agnes 文本、图片、视频流程
3. 本地图片路径在 Agnes 图生图 / 图生视频场景下能自动桥接为公网 URL
4. npm 包可以独立发布和升级
5. skill 仓库仍然保持安装型、轻量、易发现

## 当前推荐

如果现在要拍板，推荐是：

- `agnes-ai-skill` 继续保持当前轻量 root skill 形态
- `agnes-ai-cli` 单独做 npm 包
- CLI 用场景式 commands
- JS API 用统一的 `generateImage` / `generateVideo`
- 本地文件第一版通过 Litterbox 做 URL bridge
- shell helper 保留为 fallback，不作为长期主执行层

## 需要确认的两个点

1. npm 包名优先用：
   - `agnes-ai-cli`
   - 还是 `@jomeswang/agnes-ai-cli`

2. shell helper 的长期定位：
   - 仅 fallback
   - 还是继续作为公开脚本一起维护
