# Agnes CLI And npm Package Design

Date: 2026-06-02
Repository: `jomeswang/agnes-ai-skill`
Status: Draft for review

## Objective

Add a real execution layer for Agnes workflows so agents do not need to handcraft
raw `curl` calls for common tasks. The new layer should:

- preserve the current root-level `SKILL.md` install experience
- provide a publishable npm package and CLI
- normalize Agnes text, image, and video request shapes
- bridge local file paths into temporary public URLs when Agnes expects remote
  image URLs
- keep the repository lightweight enough to remain an install-friendly skill repo

## Current Context

The repository already contains:

- a root `SKILL.md` focused on Agnes platform setup and API usage
- a public GitHub distribution path for `npx skills add jomeswang/agnes-ai-skill -g`
- a lightweight shell helper:
  `scripts/agnes-media-url.sh`

The current pain points are:

- agents still need to assemble raw Agnes `curl` payloads
- local-path handling for image-to-image and image-to-video is easy to forget
- video polling and response normalization are repetitive
- the execution layer is not yet reusable outside the skill itself

## Recommendation

Choose a **dual-track architecture** instead of a root-level monorepo that
mixes installable skill content and CLI source in the same copied directory.

### Track 1: `agnes-ai-skill`

Role:

- install-friendly root skill repository
- optimized for `npx skills add ... -g`
- intentionally lightweight

Responsibilities:

- `SKILL.md`
- `README.md`
- minimal fallback helpers or tiny utility scripts
- Agnes capability guidance, model selection, auth flow, and command strategy

### Track 2: `agnes-ai-cli`

Role:

- executable npm package
- reusable JS API for Node automation
- canonical execution layer for Agnes requests

Responsibilities:

- provide the `agnes` CLI
- provide the JS client API
- normalize Agnes request shapes
- bridge local file paths into temporary public URLs
- own polling, output shaping, and validation

## Why Not A Root-Level Monorepo

Typical skill installers copy the selected skill directory.

If the root of `agnes-ai-skill` stays the installable skill and the CLI source
also lives under that root, installing the skill is likely to copy:

- CLI source
- package metadata
- extra assets or examples tied to the package

That would make the skill distribution heavier and blur the repository's role.

The better boundary is:

- `agnes-ai-skill` teaches agents what to do
- `agnes-ai-cli` performs the work

## Proposed Repository / Package Topology

### Repository A: `agnes-ai-skill`

Keep the current repository name and continue using it as the public skill
distribution entry point.

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

Notes:

- `scripts/agnes-media-url.sh` may remain as a fallback or debugging helper
- do not place full npm CLI source in this repository root

### Repository / Package B: `agnes-ai-cli`

Maintain the CLI as a separate npm package.

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

## Package Scope

The npm package should be both:

- a CLI executable named `agnes`
- a JS API for Node-based automation

The package name should be one of:

1. `agnes-ai-cli` (recommended)
2. `@jomeswang/agnes-ai-cli`

Recommendation:

- Publish as `agnes-ai-cli` if available.
- Fall back to `@jomeswang/agnes-ai-cli` only if the unscoped name is taken.

## Skill / CLI Compatibility Contract

The dual-track setup needs an explicit compatibility rule so the skill can call
the CLI without silent drift.

Rules:

- the skill documents the minimum supported CLI major or minor version
- a locally installed `agnes` binary may be used only if `agnes --version`
  satisfies the declared compatible range
- the preferred execution path is:
  1. `agnes ...` only after version verification
  2. `npx -y agnes-ai-cli@<supported-range> ...`
  3. raw `curl` only as a fallback
- the skill should not assume "latest" without a declared compatible range
- when the CLI introduces breaking request-shape behavior, the skill must be
  updated in the same release window

## CLI Design

### Principles

- avoid raw `generate` as a repeated noun in the command tree
- use explicit task-shaped commands that agents can select reliably
- keep the user-facing commands short
- let aliases map into a smaller internal API surface

### Command Tree

```text
agnes auth check
agnes auth save-key [--key <value>]

agnes media url <file-or-url> [--ttl 1h|12h|24h|72h]

agnes text chat --prompt <text> [--model agnes-2.0-flash] [--json]

agnes image text2img --prompt <text> [options]
agnes image img2img --image <path-or-url> --prompt <text> [options]
agnes image compose --image <path-or-url> --image <path-or-url> --prompt <text> [options]

agnes video text2video --prompt <text> [options]
agnes video img2video --image <path-or-url> --prompt <text> [options]
agnes video multivideo --image <path-or-url> --image <path-or-url> --prompt <text> [options]
agnes video keyframes --image <path-or-url> --image <path-or-url> --prompt <text> [options]
agnes video poll <task-id> [--interval 3] [--timeout 600]
```

### Why This Tree

- `text chat` preserves a minimal Agnes text entry point so agents can complete
  Agnes text, image, and video flows through the CLI
- `text2img`, `img2img`, `text2video`, and `img2video` are concrete and easy
  for agents to choose
- `keyframes` stays explicit because it has a distinct Agnes request mode
- `multivideo` avoids hiding the difference between one-image and multi-image
  requests
- `poll` stays a first-class video operation because Agnes video is asynchronous

### Command Aliases

The CLI may additionally support these aliases:

- `agnes image generate` -> `agnes image text2img`
- `agnes video generate` -> `agnes video text2video`

However, the skill should prefer the explicit task commands, not the aliases.

## JS API Design

### Public Entry Point

```ts
const agnes = createAgnesClient(config)

agnes.auth.check()

agnes.media.toPublicUrl(input, options?)

agnes.text.complete(options)

agnes.image.generate(options)

agnes.video.generate(options)
agnes.video.poll(taskId, options?)
```

Use a `Client + namespaced services` shape instead of exposing top-level
`generateImage()` / `generateVideo()` functions directly.

This preserves:

- clearer capability grouping
- a single config entry point
- a smaller top-level API surface
- room for future providers, logging, retries, and defaults

Shell startup-file mutation should stay CLI-only. The JS API should not expose a
public method that edits `~/.zshrc`, `~/.bashrc`, or `~/.profile`.

Text should keep a lightweight public entry point:

- `agnes.text.complete()`

This lets Node workflows run the smallest Agnes text request without dropping
down to raw `fetch`.

### Why JS Should Use Unified `image.generate()` / `video.generate()`

If the public JS API exposes many task-specific methods such as:

- `textToImage()`
- `imageToImage()`
- `composeImage()`
- `textToVideo()`
- `imageToVideo()`
- `multiImageVideo()`
- `keyframesVideo()`

it starts out readable, but it fragments quickly as new modes and provider
differences appear.

Agnes capabilities are a better fit for a unified `generate()` surface with
mode-based branching.

Images:

- text-to-image
- image-to-image
- multi-image composition

Video:

- text-to-video
- image-to-video
- multi-image video
- keyframe video

So the design should intentionally split the layers:

- CLI: explicit task-shaped commands
- JS API: unified `generate()` methods keyed by `mode`

That gives the best compatibility story without bloating the public JS API.

### Recommended Client Shape

```ts
const agnes = createAgnesClient({
  apiKey: process.env.AGNES_API_KEY,
})

await agnes.image.generate({
  mode: "text2img",
  prompt: "A luminous floating city above a misty canyon at sunrise",
})

await agnes.image.generate({
  mode: "img2img",
  image: "/path/to/input.png",
  prompt: "Preserve the silhouette and convert the scene into a bright editorial campaign",
})

await agnes.video.generate({
  mode: "img2video",
  image: "/path/to/frame.png",
  prompt: "Keep the hero subject stable while adding subtle wind and a soft push-in",
})

await agnes.video.generate({
  mode: "keyframes",
  images: ["frame-a.png", "frame-b.png"],
  prompt: "Create a smooth premium transition between the two frames",
})

await agnes.video.poll("task_123")
```

### Type Shapes

```ts
type ImageGenerateOptions =
  | {
      mode: "text2img"
      model?: "agnes-image-2.1-flash" | "agnes-image-2.0-flash"
      prompt: string
      size?: string
      responseFormat?: "url"
      seed?: number
    }
  | {
      mode: "img2img"
      model?: "agnes-image-2.1-flash" | "agnes-image-2.0-flash"
      image: string
      prompt: string
      size?: string
      responseFormat?: "url"
      seed?: number
      ttl?: "1h" | "12h" | "24h" | "72h"
    }
  | {
      mode: "compose"
      model?: "agnes-image-2.1-flash" | "agnes-image-2.0-flash"
      images: string[]
      prompt: string
      size?: string
      responseFormat?: "url"
      seed?: number
      ttl?: "1h" | "12h" | "24h" | "72h"
    }

type VideoGenerateOptions =
  | {
      mode: "text2video"
      prompt: string
      width?: number
      height?: number
      numFrames?: number
      frameRate?: number
      seed?: number
      negativePrompt?: string
    }
  | {
      mode: "img2video"
      image: string
      prompt: string
      width?: number
      height?: number
      numFrames?: number
      frameRate?: number
      seed?: number
      negativePrompt?: string
      ttl?: "1h" | "12h" | "24h" | "72h"
    }
  | {
      mode: "multivideo"
      images: string[]
      prompt: string
      width?: number
      height?: number
      numFrames?: number
      frameRate?: number
      seed?: number
      negativePrompt?: string
      ttl?: "1h" | "12h" | "24h" | "72h"
    }
  | {
      mode: "keyframes"
      images: string[]
      prompt: string
      width?: number
      height?: number
      numFrames?: number
      frameRate?: number
      seed?: number
      negativePrompt?: string
      ttl?: "1h" | "12h" | "24h" | "72h"
    }
```

### Internal Mapping Rules

For images:

- `mode: "text2img"` -> text-to-image
- `mode: "img2img"` -> single-image image-to-image
- `mode: "compose"` -> multi-image composition
- Image 2.1 with image input -> `extra_body.image`
- Image 2.0 with image input -> `tags: ["img2img"]` plus
  `extra_body.image`

For video:

- `mode: "text2video"` -> text-to-video
- `mode: "img2video"` -> top-level `image`
- `mode: "multivideo"` -> `extra_body.image`
- `mode: "keyframes"` -> `extra_body.image` plus
  `extra_body.mode = "keyframes"`

### Video Validation And Defaults

The design should bake Agnes-specific validation into the CLI and JS layer
instead of leaving it to ad hoc request assembly.

Recommended defaults:

- `width: 1152`
- `height: 768`
- `numFrames: 121`
- `frameRate: 24`

Required validation:

- `numFrames <= 441`
- `numFrames` must satisfy `8n + 1`
- `frameRate` must be in `1-60`
- `mode: "img2video"` requires exactly one image
- `mode: "multivideo"` requires at least two images
- `mode: "keyframes"` requires at least two images

Invalid settings should fail before any Agnes request is sent.

### Why CLI And JS Should Intentionally Differ

This is a deliberate split:

- CLI: explicit task-shaped commands
- JS API: unified `generate()` surface

The CLI optimizes for discoverability and help text.
The JS API optimizes for compatibility and long-term extension.

## Local File Handling

Agnes docs describe image inputs as remote image URLs. The CLI should therefore
normalize local file paths automatically.

### Rule

Whenever a command accepts `--image`:

- if the value is already `http://` or `https://`, use it unchanged
- if the value is a local file path, upload it to Litterbox first
- then use the resulting temporary public URL in the Agnes request

### First Provider

Use Litterbox first because:

- it is free
- it already works with simple `curl`
- it is enough for temporary bridge behavior

This provider should live behind an abstraction so future providers can be
added without changing the public CLI.

### Provider Abstraction

```ts
interface MediaUrlProvider {
  upload(localPath: string, options?: { ttl?: string }): Promise<string>
}
```

First implementation:

- `LitterboxMediaUrlProvider`

Future candidates:

- Cloudinary
- Google Cloud Storage
- custom provider interface

### URL Bridge Behavior

The bridge behavior should be deterministic:

- repeated `--image` inputs preserve input order exactly
- duplicate local paths may be uploaded once per command invocation and reused
  in-place in the normalized request
- if any upload fails, the whole command fails before sending the Agnes request
- default TTL is `1h`
- commands that start long-running Agnes video jobs should allow explicit TTL
  override and document that longer jobs may require `12h` or `24h`

## Output Contract

The CLI should support:

- human-readable default output
- `--json` for machine/agent consumption

### Default Output

- `media url`: print only the resulting URL
- image commands: print the resulting image URL
- video create commands: print `task_id` and status summary
- `video poll`: print the resulting video URL and completion fields

### JSON Output

Examples:

```json
{
  "ok": true,
  "taskId": "task_123",
  "status": "queued"
}
```

```json
{
  "ok": true,
  "url": "https://litter.catbox.moe/abc123.jpg",
  "source": "litterbox"
}
```

### Video Task Normalization

The CLI and JS API must normalize Agnes async video responses into a stable
shape, regardless of whether the raw API returns `id` or `task_id`.

Recommended normalized task object:

```json
{
  "ok": true,
  "taskId": "task_123",
  "status": "queued",
  "rawStatus": "queued",
  "model": "agnes-video-v2.0"
}
```

Recommended normalized poll result:

```json
{
  "ok": true,
  "taskId": "task_123",
  "status": "completed",
  "videoUrl": "https://...",
  "seconds": 10.0,
  "size": "1152x768"
}
```

Guaranteed status enum:

- `queued`
- `in_progress`
- `completed`
- `failed`
- `timed_out`

Rules:

- map raw `id` or `task_id` into `taskId`
- preserve the raw provider status as `rawStatus` when useful
- `video.generate()` returns a normalized task object and does not auto-poll
- `video.poll()` returns a normalized terminal result object
- `video poll --json` must define structured output for:
  - `failed`
  - `404`
  - `503`
  - timeout

Recommended failure shape:

```json
{
  "ok": false,
  "taskId": "task_123",
  "status": "failed",
  "code": "TASK_FAILED",
  "message": "Agnes video task failed"
}
```

## Auth Behavior

The CLI should use the same Agnes key behavior already documented in the skill.
The JS API should limit itself to inspection and runtime config, not shell file
mutation.

### `agnes auth check`

Returns whether `AGNES_API_KEY` is available and which source was used.

### `agnes auth save-key`

Rules:

- write `AGNES_API_KEY`
- detect shell rc file:
  - zsh -> `~/.zshrc`
  - bash -> `~/.bashrc`
  - fallback -> `~/.profile`
- update existing export if present
- export into the current process for child calls when possible
- never echo the full key back

### JS Auth Surface

Recommended public JS auth surface:

- `agnes.auth.check()`

Optional internal or advanced surface:

- `resolveAuthConfig()`

Do not expose shell-rc mutation as a routine public JS API.

## Error Handling

The CLI should convert raw failures into stable categories:

- auth missing
- local file missing
- upload failed
- Agnes request failed
- Agnes task timeout
- invalid command arguments

For `--json`, errors should still print machine-readable output:

```json
{
  "ok": false,
  "code": "UPLOAD_FAILED",
  "message": "Failed to upload local file to Litterbox"
}
```

Video-specific error codes should include at least:

- `TASK_FAILED`
- `TASK_NOT_FOUND`
- `SERVICE_BUSY`
- `POLL_TIMEOUT`
- `INVALID_VIDEO_SETTINGS`

## Skill Integration

The root `SKILL.md` should eventually prefer CLI commands over raw `curl`
whenever the CLI is available.

Preferred hierarchy:

1. use local `agnes` only if `agnes --version` satisfies the supported range
2. otherwise use `npx -y agnes-ai-cli@<supported-range> ...`
3. otherwise fall back to the shell helper or raw `curl`

The skill should keep the minimal `curl` examples for portability, but treat the
CLI as the preferred execution path.

## Release And Distribution

### npm

- package published from the dedicated `agnes-ai-cli` package repository
- executable name: `agnes`
- versioning should start at `0.1.0`

### Skill Repository

`agnes-ai-skill` remains the canonical source for:

- the skill install experience
- skill-facing README and showcase
- skill documentation and compatibility guidance

### CLI Repository

`agnes-ai-cli` remains the canonical source for:

- CLI source
- JS API source
- package README
- release and npm publish workflow

## Testing Strategy

### Unit Tests

- request normalization for image and video modes
- local-path vs URL passthrough behavior
- rc file selection logic
- JSON output formatting
- `task_id` vs `id` normalization
- video status mapping
- validation of `numFrames <= 441`
- validation of `numFrames = 8n + 1`
- validation of `frameRate` in `1-60`
- default TTL behavior and explicit TTL override

### CLI Tests

- `agnes media url https://example.com/x.png`
- `agnes text chat --help`
- `agnes image text2img --help`
- `agnes video keyframes --help`
- `agnes auth check`
- `agnes video poll task_123 --json`

### Integration Tests

Mock by default:

- Litterbox upload
- Agnes API requests

Optional live tests behind environment flags:

- `AGNES_API_KEY`
- explicit opt-in for live upload and live Agnes requests

## Rollout Plan

### Phase 1

- scaffold the standalone `agnes-ai-cli` package repository
- implement `auth check`, `auth save-key`, `media url`, and `text chat`

### Phase 2

- implement image commands
- implement video create + poll commands

### Phase 3

- update `SKILL.md` to prefer CLI
- keep shell fallback
- document install and publish flow

## Success Criteria

This design is successful when:

1. an agent can complete Agnes text, image, and video workflows without
   hand-authoring raw `curl` payloads in normal cases
2. local file inputs for Agnes image/video flows are bridged automatically
3. the public skill repository remains installable as a root-level skill
4. the CLI can be published independently to npm
5. video task normalization and validation are stable enough that agents do not
   need to guess raw Agnes response differences

## Open Questions

These should be decided before implementation:

1. package name:
   - `agnes-ai-cli`
   - or `@jomeswang/agnes-ai-cli`
2. whether to keep the shell helper permanently as a fallback
3. whether live integration tests should run in CI or only manually
