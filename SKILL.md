---
name: agnes-ai-skill
version: 1.3.1
description: "Use when the user wants Agnes AI text, image, or video generation and should execute it through agnes-ai-cli where the CLI is current, or the documented HTTP API where the CLI is behind the models."
tags:
  - agnes
  - agnes-ai
  - agnes-skill
  - multimodal-ai
  - free-ai-api
  - free-ai-model
  - text-generation
  - image-generation
  - ai-image-generation
  - text-to-image
  - image-editing
  - image-to-image
  - video-generation
  - ai-video-generation
  - text-to-video
  - image-to-video
  - api-integration
  - agent-skill
  - codex
  - claude-code
  - openclaw
metadata:
  openclaw:
    emoji: "sparkles"
    homepage: "https://github.com/jomeswang/agnes-ai-skill"
    requires:
      bins:
        - npm
        - npx
        - node
    primaryEnv: AGNES_API_KEY
    envVars:
      - name: AGNES_API_KEY
        required: false
        description: Agnes API key used for live authenticated text, image, and video requests. The skill can still load without it and guide setup.
---

# Agnes AI Skill

Use this skill when the user wants Agnes AI text, image, or video generation.

**Execution split (verified 2026-11-22):**

- **Text** — `agnes-ai-cli` is fine; `--model` accepts any model id, so
  `agnes-3.0-flash` and `agnes-3.0-pro` work.
- **Image and video** — the published CLI is stale. `agnes-ai-cli@0.1.6`
  hard-rejects `agnes-image-2.5-flash` (enum limited to 2.1/2.0) and hardcodes
  `agnes-video-v2.0` with `width`/`height`/`num_frames`/`frame_rate`, which the
  current video API rejects. Use the documented HTTP API in this skill instead
  of hand-editing the CLI or guessing payloads.

Agnes is attractive because one platform covers:

- text with `agnes-3.0-flash` (default) and `agnes-3.0-pro`
- image generation and editing with `agnes-image-2.5-flash`
- video generation with `agnes-video-2.5-flash` and `agnes-video-2.5`
- structured decisions with `agnes-sys1-1.0`

**Free-first default:** pick the newest model that is currently free in each
modality — `agnes-3.0-flash` for text, `agnes-image-2.5-flash` for image,
`agnes-video-2.5-flash` for video. Use a paid model (`agnes-3.0-pro`, the 2.5
Pro family, `agnes-video-2.5`) only when the user explicitly asks for the extra
capability and accepts the cost. Do not silently trade free for paid.

Free-access claims are time-sensitive. As of 2026-11-22 the flash text model,
all image models, and video 2.5 Flash are at a zero trial price; the Pro models
are billed. Verify current billing in the docs or the account dashboard before
quoting a cost.

## When To Use

Use this skill when:

- the user mentions Agnes AI, `agnes-ai.com`, or the Agnes platform
- the user wants one provider for text, image, and video generation
- the user wants Agnes text, image, or video APIs executed from a terminal
- the user wants image-to-image, multi-image composition, image-to-video, or
  keyframe video generation
- the user wants a low-friction multimodal API for prototyping, agent loops,
  creative iteration, ecommerce content, or storyboard work

Do not use this skill when:

- the user is asking for a different provider only
- the task does not need Agnes-specific models, auth, or request behavior
- you would have to guess current Agnes behavior without running the CLI,
  calling the API, or checking the live docs

## Source Of Truth

The docs moved to a Mintlify wiki. Prefer these:

- Documentation index (machine-readable): `https://wiki.agnes-ai.com/llms.txt`
- Quickstart: `https://wiki.agnes-ai.com/en/docs/quickstart.md`
- Text 3.0 Flash: `https://wiki.agnes-ai.com/en/docs/agnes-30-flash.md`
- Text 3.0 Pro: `https://wiki.agnes-ai.com/en/docs/agnes-30-pro.md`
- Text 2.5 Flash (retiring 2026-11-30):
  `https://wiki.agnes-ai.com/en/docs/agnes-25-flash.md`
- Image 2.5 Flash: `https://wiki.agnes-ai.com/en/docs/agnes-image-25-flash.md`
- Video 2.5: `https://wiki.agnes-ai.com/en/docs/agnes-video-25.md`
- Video 2.5 Flash: `https://wiki.agnes-ai.com/en/docs/agnes-video-25-flash.md`
- Decision model: `https://wiki.agnes-ai.com/en/docs/agnes-sys1-10.md`
- Pricing: `https://wiki.agnes-ai.com/en/docs/pricing.md`
- API key page: `https://platform.agnes-ai.com/settings/apiKeys`
- Published CLI: `https://www.npmjs.com/package/agnes-ai-cli`
- CLI repo: `https://github.com/jomeswang/agnes-ai-cli`

Old `https://agnes-ai.com/doc/<slug>` links still 302 to the wiki pages, but
do not treat them as the canonical source. Use public articles only as context
for positioning, never as the operational source of truth.

## Base URL And Auth

- Base URL: `https://apihub.agnes-ai.com/v1`
- Main environment variable: `AGNES_API_KEY`
- Header: `Authorization: Bearer <key>`
- Anthropic-compatible endpoints instead use `x-api-key: <key>` plus
  `anthropic-version: 2023-06-01`

Check `AGNES_API_KEY` before making live Agnes requests. `GET /v1/models` with
that key is the cheapest way to confirm auth and the account's current model
list.

## Missing Key Behavior

If `AGNES_API_KEY` is missing and the task requires live Agnes access:

1. Tell the user Agnes access is not configured yet.
2. Point them to:
   - `https://wiki.agnes-ai.com/en/docs/quickstart.md`
   - `https://platform.agnes-ai.com/settings/apiKeys`
3. Explain the path briefly:
   `Settings -> API Keys -> Create new secret key`
4. Ask them to provide the key if they want you to save it for future use.

Do not continue with live Agnes calls until a valid key exists.

## Chinese Quick Start Response

When a Chinese-speaking user asks how to get started, install, or use Agnes
from an agent tool, give them this concise copy-paste path:

```text
Please read and install Agnes AI Skill: https://github.com/jomeswang/agnes-ai-skill
```

Then explain:

- install the skill into the agent's skill directory or use a repository-aware
  installer such as `npx skills add jomeswang/agnes-ai-skill -g`
- create an Agnes API key at `https://platform.agnes-ai.com/settings/apiKeys`
  and configure it as `AGNES_API_KEY`
- say `generate an image`, `generate a video`, or `integrate Agnes API`
- the agent should pick the current model ids from this skill and use
  `agnes-ai-cli` for text, or direct HTTP for image and video

Keep this onboarding short before moving into model-specific details.

## Persisting The Key Permanently

If the user explicitly gives you an Agnes key and wants it remembered, persist
it for future terminal sessions instead of keeping it only in the current
process.

### Rules

- Save it as `AGNES_API_KEY`
- Detect the shell and write to the matching rc file:
  - zsh -> `~/.zshrc`
  - bash -> `~/.bashrc`
  - PowerShell -> user environment variable (see below), not an rc file
  - fallback -> `~/.profile`
- Update an existing `export AGNES_API_KEY=...` line if present
- Otherwise append a new export line
- Also export it in the current session immediately
- Do not echo the full key back after saving
- Tell the user which file or scope you changed

### Reliable Shell Snippet

Use a non-interactive shell flow like this when saving a provided key:

```bash
AGNES_API_KEY_VALUE='USER_PROVIDED_KEY'
shell_name="$(basename "${SHELL:-}")"
case "$shell_name" in
  zsh) rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  *) rc_file="$HOME/.profile" ;;
esac

touch "$rc_file"
tmp_file="$(mktemp)"
grep -v '^export AGNES_API_KEY=' "$rc_file" > "$tmp_file" || true
printf '\nexport AGNES_API_KEY=%q\n' "$AGNES_API_KEY_VALUE" >> "$tmp_file"
mv "$tmp_file" "$rc_file"
export AGNES_API_KEY="$AGNES_API_KEY_VALUE"
unset AGNES_API_KEY_VALUE
```

On Windows, persist to the user scope instead of an rc file:

```powershell
[Environment]::SetEnvironmentVariable('AGNES_API_KEY', 'USER_PROVIDED_KEY', 'User')
$env:AGNES_API_KEY = 'USER_PROVIDED_KEY'
```

After saving, continue using `AGNES_API_KEY` for the current task.

## Execution Contract

### Preferred Order

1. `GET /v1/models` once per session when the model inventory matters — it is
   the authoritative list for the account.
2. **Text** — `npx -y agnes-ai-cli@0.1.6 text chat --model <id> ...`
3. **Image / video / decision** — direct HTTP per this skill. Do not use the CLI
   for these until a newer CLI release supports the 2.5 generation.
4. If a local `agnes` binary exists, it is only safe for text; check
   `agnes --version` and treat anything `0.1.x` as image/video-stale.

### Why Not CLI-Only Anymore

The CLI still handles auth checks, local-file to public-URL bridging, and JSON
output, which is why text stays on it. But it pins old contracts:

- `text chat` default `agnes-2.0-flash` — that model now returns
  `get_channel_failed` (verified)
- image model enum: only `agnes-image-2.1-flash` and `agnes-image-2.0-flash`
- video: `agnes-video-v2.0`, `width`, `height`, `num_frames`, `frame_rate`

The current video API rejects those fields outright. Passing the CLI's payload
to it is not a "parameter tweak"; it is a different contract.

## Mandatory `--help` Guidance

When the user is new to the CLI, or when you are about to use a less common
command, guide through `--help` first.

At minimum, know these help entry points:

```bash
npx -y agnes-ai-cli@0.1.6 --help
npx -y agnes-ai-cli@0.1.6 auth --help
npx -y agnes-ai-cli@0.1.6 media --help
npx -y agnes-ai-cli@0.1.6 text chat --help
```

Image and video subcommands exist in 0.1.6 but are legacy-only; read their
`--help` output as documentation of the old contract, not of the current API.

## Model Catalog

Verified against `GET /v1/models` on 2026-11-22. Price column is the current
trial status, not a promise.

| Model id | Kind | Price | Notes |
| --- | --- | --- | --- |
| `agnes-3.0-flash` | text | free | Default. 512K context, 64K max output; text + image-URL input. |
| `agnes-3.0-pro` | text | paid | Reasoning model. 1M context, 256K max output (~$0.10/M in, $0.30/M out). |
| `agnes-2.5-flash` | text | free | Retires 2026-11-30; still works, do not build on it. |
| `agnes-2.5-pro` | text | paid | Commercial stable Pro. |
| `agnes-2.5-pro-beta` / `agnes-2.5-pro-theta` | text | paid | Preview Pro variants. |
| `agnes-2.5-pro-alpha` | text | paid | Listed in `/v1/models`, no public doc page. Do not pick it by default. |
| `agnes-sys1-1.0` | decision | paid input | `/v1/systemone` only; `messages` is rejected. |
| `agnes-image-2.5-flash` | image | free | Default. Supersedes 2.1. |
| `agnes-image-2.1-flash` | image | free | Legacy, still callable. |
| `agnes-image-2.0-flash` | image | free | Legacy, still callable. |
| `agnes-video-2.5-flash` | video | free | 720P only, 4–12 s. Queue is often saturated. |
| `agnes-video-2.5` | video | paid | 720P/1080P/1K/2K, 4–12 s, billed per second. |

Retired or unavailable:

- `agnes-2.0-flash` — chat returns `get_channel_failed`; do not use.
- `agnes-video-v2.0` — absent from `/v1/models`; only the stale CLI still sends
  it.

### Choosing A Model

Free-first, in this order:

- Text — `agnes-3.0-flash`. Move to `agnes-3.0-pro` only for hard reasoning,
  long-document analysis, or multi-step agentic work, and say that it is paid.
- Image — `agnes-image-2.5-flash`. Use 2.1/2.0 only to reproduce an existing
  result.
- Video — `agnes-video-2.5-flash`. Only use `agnes-video-2.5` when the user
  explicitly needs 1080P/2K or reference-video input and accepts per-second
  billing.
- Routing/classification/business rules — `agnes-sys1-1.0` (input billed, output
  free), not a chat model.

## CLI Command Map (Text And Support)

### Auth

```bash
npx -y agnes-ai-cli@0.1.6 auth check
npx -y agnes-ai-cli@0.1.6 auth save-key --key 'YOUR_KEY'
```

### Media URL Bridge

```bash
npx -y agnes-ai-cli@0.1.6 media url ./local-image.png
npx -y agnes-ai-cli@0.1.6 media url https://example.com/already-remote.png
```

Useful for the video `keyframe`/`reference` modes, which need public URLs.

### Text

```bash
npx -y agnes-ai-cli@0.1.6 text chat \
  --model agnes-3.0-flash \
  --prompt "Reply with exactly pong." --json
```

`--model` is passed through, so newer text ids work even on the old CLI.

## Text API

All text models accept three shapes on `https://apihub.agnes-ai.com/v1`:

- `POST /chat/completions` — OpenAI-compatible, `messages`
- `POST /responses` — `input`, `max_output_tokens`
- `POST /messages` — Anthropic-compatible, `messages`, `max_tokens`,
  `x-api-key` header

### Reasoning Budget

`agnes-3.0-pro` (and the 2.5 Pro family) emit reasoning tokens before visible
text. A tiny `max_tokens` yields an empty `content` with a non-zero
`completion_tokens` — verified: `max_tokens: 20` returned empty, `max_tokens:
300` returned `pong` with 25 reasoning tokens. Give reasoning models at least
a few hundred output tokens.

### Thinking Mode

```json
{
  "model": "agnes-3.0-flash",
  "messages": [{ "role": "user", "content": "Plan the implementation steps." }],
  "chat_template_kwargs": { "enable_thinking": true }
}
```

Anthropic-shaped requests use `"thinking": { "type": "enabled",
"budget_tokens": 2048 }` instead.

### Responses API Output

There is no top-level `output_text`. Read message items where
`output[].type == "message"` and `output[].content[].type == "output_text"`.
If `status == "incomplete"`, inspect `incomplete_details` and raise
`max_output_tokens`.

## Image API (`agnes-image-2.5-flash`)

Endpoint: `POST https://apihub.agnes-ai.com/v1/images/generations`

### Request Rules

| Field | Required | Notes |
| --- | --- | --- |
| `model` | yes | `agnes-image-2.5-flash` |
| `prompt` | yes | Generation or edit instruction |
| `size` | yes | Tier `1K`/`2K`/`3K`/`4K`; legacy exact sizes accepted but may be normalized |
| `ratio` | no | `1:1`, `3:4`, `4:3`, `16:9`, `9:16`, `2:3`, `3:2`, `21:9`; default `1:1` |
| `return_base64` | no | Top-level flag for text-to-image Base64 output |
| `extra_body.response_format` | no | `url` or `b64_json` |
| `extra_body.image` | for edit/compose | Array of public URLs or Data-URI Base64 |

Hard rules learned from the docs and validated live:

- Never put `response_format` at the top level; it belongs in `extra_body`.
- Do not send `tags: ["img2img"]`; edits only need `extra_body.image`.
- 16:9 at tier `1K` is `1312x736`, not `1920x1080`. Request the tier and
  crop/resize downstream if an exact canvas is required.

Example (verified working, ~12 s):

```bash
curl -sS https://apihub.agnes-ai.com/v1/images/generations \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-image-2.5-flash",
    "prompt": "A single red apple on a white table, studio light",
    "size": "1K",
    "ratio": "1:1",
    "extra_body": { "response_format": "url" }
  }'
```

Read `data[0].url` or `data[0].b64_json`. Image-to-image is the same endpoint
with `extra_body.image: ["<url>"]`; verified working (~11.6 s).

## Video API (`agnes-video-2.5` / `agnes-video-2.5-flash`)

Create: `POST https://apihub.agnes-ai.com/v1/videos`

Poll: `GET https://apihub.agnes-ai.com/agnesapi?video_id=<VIDEO_ID>&model_name=<MODEL>`

### Create Parameters

| Field | Required | Notes |
| --- | --- | --- |
| `model` | yes | `agnes-video-2.5` or `agnes-video-2.5-flash` |
| `prompt` | yes | Reference media as `<Picture N>`, `<Audio N>`, `<Video N>` |
| `mode` | yes | `text`, `keyframe`, or `reference` |
| `seconds` | no | **String** `"4"`–`"12"`, default `"5"` |
| `size` | no | `720P`, `1080P`, `1K`, `2K`; Flash accepts only `720P` |
| `aspect_ratio` | no | `21:9`, `16:9`, `4:3`, `1:1`, `3:4`, `9:16`; default `16:9` |
| `seed` | no | Integer, for reproducibility |
| `n` | no | Only `1` |

Mode-specific:

- `keyframe`: `first_frame` and/or `last_frame` URL; no `images`/`audios`/`videos`
- `reference`: `images[]` (≤8, ≤5 on Flash), `audios[]` (≤3),
  `videos[{url, start_seconds, require_audio}]` (2.5 only, max 1)

Rejected with `400`: `width`, `height`, `fps`, `num_frames`, `quality`,
`num_inference_steps`, pixel sizes in `size`, `aspect_ratio: "auto"`, `n != 1`,
`video_url`/`input_reference`/`reference_url`, or media fields that conflict
with `mode`.

Example:

```bash
curl -sS -X POST https://apihub.agnes-ai.com/v1/videos \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-video-2.5-flash",
    "prompt": "A slow push-in on a red apple on a white table, soft studio light",
    "seconds": "4",
    "mode": "text",
    "size": "720P",
    "aspect_ratio": "16:9"
  }'
```

Read `video_id` from the create response (`id` and `task_id` are the same task).
Poll every 1–2 s; stop on `status` `completed` or `failed`; read the top-level
`url` only when `completed`. Always pass `model_name` in the poll query —
without it, polling is valid only for `mode: "text"`.

### Video Queue Is Persistently Saturated

```
{"code":"video_queue_full","message":"video queue is full, please retry later"}
```

This is the normal response on this account: the shared generation queue has
been full across sessions, not just at peak times. Treat video generation as
unavailable until the user says otherwise.

- Report it once, plainly, in the user's language — e.g.「Agnes 视频队列已满，现在生成不了」.
- Do not retry in a loop, do not switch to the paid `agnes-video-2.5` hoping for
  a different queue, and do not rewrite the payload — it is not a client error.
- Do not block a deliverable on video; offer an image/keyframe alternative if
  the task allows.

The request shape above is still the current documented contract, so keep it
correct for when the queue clears; just do not burn turns testing it.

## Decision API (`agnes-sys1-1.0`)

Endpoint: `POST https://apihub.agnes-ai.com/v1/systemone` — not Chat Completions.

```json
{
  "model": "agnes-sys1-1.0",
  "state": "User says the invoice is wrong after upgrading and wants it fixed ASAP.",
  "questions": {
    "route": {
      "type": "choice",
      "instructions": "Which team should handle this?",
      "criteria": {
        "billing": "Billing support",
        "technical": "Technical support",
        "sales": "Sales"
      }
    },
    "urgent": {
      "type": "noul",
      "instructions": "Is the user asking for urgent handling?"
    }
  }
}
```

Read `answers.<name>.choice` (plus `probabilities`, `confidence`) or
`answers.<name>.noul`. Keep the type string `noul` exactly. Input tokens are
billed; output is free.

## Practical Workflows

### Text Verification

1. `npx -y agnes-ai-cli@0.1.6 text chat --model agnes-3.0-flash --prompt "Reply with exactly pong." --json`
2. If empty and the model is a Pro variant, raise the output budget before
   assuming a failure.

### Text-To-Image

1. Choose tier and ratio, not raw pixels.
2. POST `/v1/images/generations` with `extra_body.response_format: "url"`.
3. Read `data[0].url`; download immediately if the URL is temporary.

### Image Edit / Compose

1. Get public URLs (CLI `media url` is fine for local files).
2. POST the same endpoint with `extra_body.image: [...]`.
3. State what changes and what must be preserved in the prompt.

### Text-To-Video

1. Check expectations first: the queue is currently saturated, so a create call
   will usually return `video_queue_full`.
2. If the user still wants it, pick `agnes-video-2.5-flash` (free) and POST
   `/v1/videos` with `mode: "text"`.
3. Save `video_id`, poll with `model_name`, read `url` on `completed`.
4. On `video_queue_full`, stop and report; do not retry in a loop.

### Image-To-Video / Keyframes

1. `keyframe` for first/last frame control; `reference` for style, character, or
   audio rhythm.
2. Public URLs only; local files go through `media url`.
3. `agnes-video-2.5-flash` accepts no `videos` references and at most 5 images.

## Image Guidance

- Image 2.5 Flash is the default for new work; 2.1/2.0 are for reproducing old
  results.
- For edits, separate explicitly:
  - what should change
  - what must stay fixed
- For dense images, be explicit about:
  - primary subject
  - background environment
  - important secondary details
  - style and lighting
  - composition constraints
- 2.5 is tuned for high-information-density scenes; describe the visual
  hierarchy instead of piling on adjectives.

## Video Guidance

- The API is asynchronous; never treat create as delivery.
- Duration is a string in 4–12 s. There is no `num_frames` control anymore.
- Resolution is a tier plus an aspect ratio; exact pixel sizes are not
  accepted.
- Prompts work best in this order:
  1. subject and setting
  2. action and change
  3. camera language
  4. visual style and lighting
  5. sound and rhythm
  6. consistency requirements
- In `reference` mode, name each placeholder and its role:
  "Use `<Picture 1>` as the character reference and follow the rhythm of
  `<Audio 1>`."

## JSON Output

For CLI calls prefer `--json`; the payload is what the agent consumes.

```bash
npx -y agnes-ai-cli@0.1.6 text chat --prompt "..." --model agnes-3.0-flash --json
```

For HTTP calls the response is already JSON. Extract:

- text: `choices[0].message.content`, or `output[].content[].text` for
  `/responses`
- image: `data[0].url` or `data[0].b64_json`
- video: create -> `video_id`; poll -> `status`, `progress`, `url`

## Verified Behaviour (2026-11-22)

| Check | Result |
| --- | --- |
| `GET /v1/models` | 13 ids; includes 3.0 Flash/Pro, image 2.5, video 2.5/2.5 Flash, sys1 |
| `agnes-2.0-flash` chat | `get_channel_failed` — unavailable |
| `agnes-3.0-flash` chat | OK |
| `agnes-3.0-pro`, `max_tokens: 20` | empty content, reasoning tokens consumed budget |
| `agnes-3.0-pro`, `max_tokens: 300` | OK, 25 reasoning tokens |
| `agnes-image-2.5-flash` text2img | OK, ~12.1 s |
| `agnes-image-2.5-flash` img2img | OK, ~11.6 s |
| `agnes-video-2.5-flash` create | `video_queue_full` on 2/2 attempts; queue saturated |
| CLI 0.1.6 `image --model agnes-image-2.5-flash` | `INVALID_ARGUMENTS` (model enum) |
| CLI 0.1.6 video source | hardcodes `agnes-video-v2.0` + old fields |
| npm latest CLI / repo `main` | `0.1.6` in both — no newer build exists |

## Compact Reference

- Base URL: `https://apihub.agnes-ai.com/v1`
- Text: `/chat/completions`, `/responses`, `/messages`
- Image: `/images/generations`
- Video create: `/videos`; poll: `/agnesapi?video_id=&model_name=`
- Decision: `/v1/systemone`

- Text default: `agnes-3.0-flash`; reasoning: `agnes-3.0-pro`
- Image: `agnes-image-2.5-flash`
- Video: `agnes-video-2.5-flash` (720P, free) / `agnes-video-2.5` (up to 2K)
- Decision: `agnes-sys1-1.0`

## Do Not

- Do not proceed with live Agnes calls when the key is missing
- Do not use a paid model when the free one covers the task
- Do not use `agnes-2.0-flash` or `agnes-video-v2.0`; both are gone
- Do not pass `width`/`height`/`num_frames`/`frame_rate` to the video API
- Do not put `response_format` at the image request top level
- Do not assume the CLI supports 2.5 image/video models
- Do not skip video polling and assume generation is synchronous
- Do not treat `video_queue_full` as a client-side bug or retry-loop it
- Do not trust stale marketing or old doc URLs over the current wiki pages

## Safety

- Never echo a full Agnes API key back to the user after it has been supplied
- Never continue with live Agnes requests when auth is missing or clearly
  invalid
- Never treat article copy or marketing claims as more authoritative than the
  official Agnes docs
- Never promise pricing, limits, or "forever free" terms without noting they
  can change over time
- Never write the key to a project file unless the user explicitly asks for
  that behavior

## Installation

With repository-aware skill installers:

```bash
npx skills add jomeswang/agnes-ai-skill -g
```

After installation, invoke this skill whenever Agnes setup or Agnes model usage
comes up.

## Version History

- `1.3.1` - Free-first defaults (3.0 Flash / Image 2.5 Flash / Video 2.5 Flash);
  paid Pro and video 2.5 only on explicit request; video queue documented as
  persistently saturated, with an explicit no-retry-loop rule; upstream issue
  filed for the stale catalog (jomeswang/agnes-ai-skill#24).
- `1.3.0` - Model catalog refreshed against `GET /v1/models` (2026-11-22):
  3.0 Flash/Pro, 2.5 Pro family, image 2.5, video 2.5/2.5 Flash, sys1 decision
  model; removed 2.0 Flash and video v2.0; documented the CLI 0.1.6 gap and
  direct-HTTP execution for image/video; replaced old `num_frames` video rules
  with the `mode`/`seconds`/`size`/`aspect_ratio` contract; added image 2.5
  request rules, reasoning-budget and Responses-API notes, `video_queue_full`
  handling, and a verified-behaviour table.
- `1.2.2` - Added a linked Chinese README and Chinese quick-start onboarding
  guidance for agent responses.
- `1.2.1` - Made `npx -y agnes-ai-cli@^0.1.0` the default copy-paste execution
  path in fresh environments and kept global `agnes` as an optional fast path.
- `1.2.0` - Switched the skill to CLI-first Agnes execution, removed raw curl
  execution guidance, and made `--help` discovery part of the expected flow.
- `1.1.2` - Added dual-track CLI guidance so agents prefer the separate Agnes
  execution layer when available and keep raw `curl` as the fallback.
- `1.1.0` - Expanded official doc coverage for Image 2.0, Image 2.1, and Video
  2.0 parameters, scenarios, prompt structures, response fields, and task
  states.
- `1.0.0` - Initial public release with Agnes platform setup, persistent auth,
  text, image, and video workflow guidance.
