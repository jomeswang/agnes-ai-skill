# Agnes AI Skill

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-blue)](./SKILL.md)
[![Models](https://img.shields.io/badge/models-text%20%7C%20image%20%7C%20video-black)](https://agnes-ai.com/doc)
[![Agnes AI](https://img.shields.io/badge/platform-Agnes%20AI-ff6b3d)](https://platform.agnes-ai.com/)

> One install target for Agnes AI text, image, and video APIs.

> 文本、图片、视频全模态 API，一套 skill 直接接入 Agnes。
>
> Based on the supplied June 2026 materials, Agnes publicly positioned its core
> multimodal APIs as indefinitely free for developers and creators. Treat that
> as time-sensitive platform messaging and verify current commercial terms in
> the live product when cost matters.

![Agnes AI cyberpunk showcase](./assets/images/cyberpunk-bridge.jpg)

This repository packages a single root `SKILL.md` so coding agents can quickly:

- get and persist an Agnes API key
- use `agnes-2.0-flash` for chat, coding, streaming, and tool calling
- use `agnes-image-2.0-flash` and `agnes-image-2.1-flash` for image generation
  and editing
- use `agnes-video-v2.0` for asynchronous video generation and polling

The skill stays intentionally lightweight. It teaches agents how to make Agnes
API calls successfully without copying the full docs into the repository.

## Showcase

All preview assets below were generated on June 1, 2026 with Agnes APIs and
prompts adapted from the supplied public writeups plus the showcase structure
used by repositories like `awesome-gpt-image-2`,
`awesome-seedance-2-prompts`, and `awesome-gemini-3-prompts`.

### Featured Images

`agnes-image-2.1-flash`

| Cyberpunk bridge scene | Luxury product ad |
| --- | --- |
| ![Cyberpunk bridge](./assets/images/cyberpunk-bridge.jpg) | ![Perfume product ad](./assets/images/perfume-product.jpg) |

| Mobile infographic |
| --- |
| ![Chocolate latte infographic](./assets/images/latte-infographic.jpg) |

Example prompt themes used for the gallery:

- rain-soaked cyberpunk Tokyo bridge with anime lighting and cinematic depth
- premium commercial perfume hero shot with crystal pedestal and water splash
- mobile-friendly tutorial infographic with strong layout hierarchy

### Featured Video

`agnes-video-v2.0`

GitHub does not autoplay repository videos in markdown, so the preview below
links directly to the generated `.mp4`.

[![FPV forest waterfall video preview](./assets/video-previews/forest-waterfall.jpg)](./assets/videos/forest-waterfall.mp4)

Prompt theme used for this clip:

- FPV drone shot gliding through dense sunlit pine forest and revealing a
  hidden waterfall with cinematic motion

### Featured App Demos

`agnes-2.0-flash`

These two single-file HTML demos were generated from Agnes text prompts and are
included in [`examples/apps`](./examples/apps).

| Cinematic AI landing page | Mobile map UI prototype |
| --- | --- |
| [![Cinematic landing page](./assets/apps/cinematic-ai-landing.jpg)](./examples/apps/cinematic-ai-landing.html) | [![Beijing map UI](./assets/apps/beijing-map-ui.jpg)](./examples/apps/beijing-map-ui.html) |

Open the source files directly:

- [Cinematic landing page HTML](./examples/apps/cinematic-ai-landing.html)
- [Beijing map UI HTML](./examples/apps/beijing-map-ui.html)

## Why Agnes

Agnes is most interesting when one workflow needs all three layers together:

- text for planning, coding, prompting, and agent loops
- image for marketing, e-commerce, and creative visual generation
- video for storyboards, product demos, motion tests, and short-form content

The supplied public writeups consistently frame Agnes as useful for:

- rapid AI product prototyping
- high-frequency agent workflows where repeated model calls matter
- frontend or HTML generation
- marketing and e-commerce creatives
- ad, storyboard, and cinematic short-video iteration

This skill turns that platform surface into one reusable installation target for
Codex and other SKILL.md-compatible agents, with guidance that helps the agent
choose the right Agnes model and authenticate cleanly.

## What It Does

- Platform and auth flow from the Agnes quickstart docs
- API key creation via the Agnes platform settings page
- Persistent `AGNES_API_KEY` setup for future sessions
- OpenAI-style request patterns for text and image endpoints
- Asynchronous task workflow for video generation
- Practical use cases reinforced by the supplied public writeups

## Safety Model

- The skill checks for `AGNES_API_KEY` before live requests
- If the key is missing, it points the user to the official Agnes quickstart
  and API key page instead of guessing
- If the user provides a key and wants it remembered, the skill persists
  `AGNES_API_KEY` in the correct shell rc file for future sessions
- Live payloads and response handling stay grounded in Agnes docs and real API
  behavior, not only in marketing copy

## Install

With a repository-aware skills installer:

```bash
npx skills add jomeswang/agnes-ai-skill
```

Because this repository uses a single root `SKILL.md`, installers that support
repository-root skills can discover it directly.

### Verified Install Path

This repository has been validated with:

```bash
npx skills add jomeswang/agnes-ai-skill --list
npx skills add jomeswang/agnes-ai-skill --agent codex --yes
```

The repository is discoverable as a single root-level skill named
`agnes-ai-skill`.

## Manual Install

Copy this repository into any standard skills location supported by your agent,
for example:

- Codex: `~/.codex/skills/agnes-ai-skill`
- Claude Code: `~/.claude/skills/agnes-ai-skill`
- Cursor: `~/.cursor/skills/agnes-ai-skill`

## What Agents Learn

- How to detect missing Agnes auth before making live calls
- How to guide the user to create an API key
- How to persist `AGNES_API_KEY` in shell startup files for future sessions
- How to choose between Agnes text, image, and video models
- How to make the smallest reliable live request first
- How to poll Agnes video tasks until they complete

## Discovery Notes

- GitHub repository: [jomeswang/agnes-ai-skill](https://github.com/jomeswang/agnes-ai-skill)
- Public repository topics:
  `agent-skills`, `ai-agent-skills`, `codex-skills`, `multimodal-ai`, `agnes-ai`
- These topics improve discoverability across GitHub-linked skill directories
  and crawler-based ecosystems.
- The repository is ready for third-party skill hub submission, including
  ClawHub-style marketplaces that read `SKILL.md` metadata.

## Primary Sources

- Agnes quickstart: [https://agnes-ai.com/doc/quickstart](https://agnes-ai.com/doc/quickstart)
- API key settings:
  [https://platform.agnes-ai.com/settings/apiKeys](https://platform.agnes-ai.com/settings/apiKeys)
- Text model:
  [https://agnes-ai.com/doc/agnes-20-flash](https://agnes-ai.com/doc/agnes-20-flash)
- Image 2.0:
  [https://agnes-ai.com/doc/agnes-image-20-flash](https://agnes-ai.com/doc/agnes-image-20-flash)
- Image 2.1:
  [https://agnes-ai.com/doc/agnes-image-21-flash](https://agnes-ai.com/doc/agnes-image-21-flash)
- Video:
  [https://agnes-ai.com/doc/agnes-video-v20](https://agnes-ai.com/doc/agnes-video-v20)

## Notes

- The public materials supplied with this repository describe Agnes as offering
  free access to its core multimodal APIs as of June 1, 2026. Treat pricing and
  promotion details as time-sensitive and verify them in the platform if cost
  matters.
- ClawHub publishing requires a separate ClawHub login or publish token plus a
  GitHub OAuth grant.
- This repository is released under the MIT License.
