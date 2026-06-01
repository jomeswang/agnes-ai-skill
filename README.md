# Agnes AI Skill

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-blue)](./SKILL.md)
[![Models](https://img.shields.io/badge/models-text%20%7C%20image%20%7C%20video-black)](https://agnes-ai.com/doc)
[![Agnes AI](https://img.shields.io/badge/platform-Agnes%20AI-ff6b3d)](https://platform.agnes-ai.com/)

An installable Agent Skill for Agnes AI's unified multimodal API platform.

> 文本、图片、视频全模态 API，一套 skill 直接接入 Agnes。
>
> Based on the supplied June 2026 materials, Agnes publicly positioned its core
> multimodal APIs as indefinitely free for developers and creators. Treat that
> as time-sensitive platform messaging and verify current commercial terms in
> the live product when cost matters.

This repository packages a single root `SKILL.md` so coding agents can quickly:

- get and persist an Agnes API key
- use `agnes-2.0-flash` for chat, coding, streaming, and tool calling
- use `agnes-image-2.0-flash` and `agnes-image-2.1-flash` for image generation
  and editing
- use `agnes-video-v2.0` for asynchronous video generation and polling

The skill stays intentionally lightweight. It teaches agents how to make Agnes
API calls successfully without copying the full docs into the repository.

## Why This Skill Exists

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
Codex and other SKILL.md-compatible agents.

## What This Skill Covers

- Platform and auth flow from the Agnes quickstart docs
- API key creation via the Agnes platform settings page
- Persistent `AGNES_API_KEY` setup for future sessions
- OpenAI-style request patterns for text and image endpoints
- Asynchronous task workflow for video generation
- Practical use cases reinforced by the supplied public writeups

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
- ClawHub publishing requires a separate ClawHub login and GitHub OAuth grant.
- This repository is released under the MIT License.
