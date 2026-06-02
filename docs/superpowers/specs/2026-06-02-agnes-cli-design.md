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

## Approaches Considered

### Approach A: Shell Scripts Only

Keep expanding `scripts/*.sh` and let the skill call shell wrappers.

Pros:

- very small implementation surface
- no package publishing setup
- easy to inspect

Cons:

- weaker cross-platform behavior
- argument parsing becomes brittle as commands grow
- difficult to expose a reusable JS API
- harder to maintain stable JSON output for agents

Assessment:

Useful as a transitional layer, but not the best long-term interface.

### Approach B: Monorepo Skill + npm CLI Package

Keep the repository as the public skill repo and add a package under
`packages/agnes-ai-cli`.

Pros:

- the skill and execution layer stay versioned together
- one public repo remains the canonical Agnes skill entry point
- npm package and root skill can share docs and fixtures
- agent installation and CLI evolution stay in sync

Cons:

- repository becomes slightly heavier
- publish flow becomes more complex than a pure skill repo

Assessment:

Best balance for this project.

### Approach C: Separate Repositories

Keep `agnes-ai-skill` as skill-only and create a separate `agnes-ai-cli` repo.

Pros:

- clean separation of concerns
- package repository can evolve independently

Cons:

- version drift between skill docs and CLI behavior
- higher release coordination cost
- more friction for contributors and users

Assessment:

Reasonable later, but not ideal for the next iteration.

## Recommendation

Choose **Approach B: Monorepo Skill + npm CLI Package**.

This keeps the current repository discoverable for `SKILL.md` installers while
adding a real execution layer that agents and human users can share.

## Proposed Repository Structure

```text
agnes-ai-skill/
  LICENSE
  README.md
  SKILL.md
  agents/
    openai.yaml
  assets/
  docs/
    superpowers/
      specs/
        2026-06-02-agnes-cli-design.md
  packages/
    agnes-ai-cli/
      package.json
      README.md
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
  scripts/
    agnes-media-url.sh
    extract_first_frames.swift
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

### Public Exports

```ts
export async function mediaUrl(input: string, options?: MediaUrlOptions): Promise<string>
export async function checkAuth(): Promise<AuthCheckResult>
export async function saveKey(key: string, options?: SaveKeyOptions): Promise<SaveKeyResult>
export async function generateImage(options: GenerateImageOptions): Promise<GenerateImageResult>
export async function generateVideo(options: GenerateVideoOptions): Promise<GenerateVideoResult>
export async function pollVideo(taskId: string, options?: PollVideoOptions): Promise<PollVideoResult>
```

### Why Unified `generateImage` / `generateVideo`

The internal API should not expose only `imageToVideo()` because Agnes video
supports at least these documented modes:

- text-to-video
- image-to-video
- multi-image video
- keyframe video

The same logic applies to image generation:

- text-to-image
- image-to-image
- multi-image composition

So the CLI should expose task-shaped commands, while the implementation should
funnel into unified internal functions.

### Type Shapes

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

### Internal Mapping Rules

For images:

- no `images` -> text-to-image
- `images.length >= 1` with Image 2.1 -> `extra_body.image`
- `images.length >= 1` with Image 2.0 -> `tags: ["img2img"]` plus
  `extra_body.image`

For video:

- no `images` -> text-to-video
- `images.length === 1` -> top-level `image`
- `images.length >= 2` and mode `standard` -> `extra_body.image`
- `images.length >= 2` and mode `keyframes` -> `extra_body.image` plus
  `extra_body.mode = "keyframes"`

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

## Auth Behavior

The CLI should use the same Agnes key behavior already documented in the skill.

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

## Skill Integration

The root `SKILL.md` should eventually prefer CLI commands over raw `curl`
whenever the CLI is available.

Preferred hierarchy:

1. use `agnes` CLI if installed
2. otherwise fall back to the shell helper or raw `curl`

The skill should keep the minimal `curl` examples for portability, but treat the
CLI as the preferred execution path.

## Release And Distribution

### npm

- package published from `packages/agnes-ai-cli`
- executable name: `agnes`
- versioning should start at `0.1.0`

### Repository

The root repository remains the canonical source for:

- the skill install experience
- README and showcase
- CLI package source
- package documentation

## Testing Strategy

### Unit Tests

- request normalization for image and video modes
- local-path vs URL passthrough behavior
- rc file selection logic
- JSON output formatting

### CLI Tests

- `agnes media url https://example.com/x.png`
- `agnes image text2img --help`
- `agnes video keyframes --help`
- `agnes auth check`

### Integration Tests

Mock by default:

- Litterbox upload
- Agnes API requests

Optional live tests behind environment flags:

- `AGNES_API_KEY`
- explicit opt-in for live upload and live Agnes requests

## Rollout Plan

### Phase 1

- scaffold `packages/agnes-ai-cli`
- implement `auth check`, `auth save-key`, and `media url`

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
5. the implementation remains small enough to maintain in the existing repo

## Open Questions

These should be decided before implementation:

1. package name:
   - `agnes-ai-cli`
   - or `@jomeswang/agnes-ai-cli`
2. whether to keep the shell helper permanently as a fallback
3. whether live integration tests should run in CI or only manually
