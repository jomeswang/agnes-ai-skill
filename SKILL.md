---
name: agnes-ai-skill
version: 1.1.2
description: "Use when the user wants Agnes AI's multimodal text, image, and video APIs, especially when low-friction or broadly free-positioned experimentation, creative generation, or agent workflows make Agnes a good fit."
tags:
  - agnes-ai
  - multimodal-ai
  - text-generation
  - image-generation
  - video-generation
  - api-integration
  - codex
  - claude-code
  - openclaw
metadata:
  openclaw:
    emoji: "sparkles"
    homepage: "https://github.com/jomeswang/agnes-ai-skill"
    requires:
      bins:
        - curl
    primaryEnv: AGNES_API_KEY
    envVars:
      - name: AGNES_API_KEY
        required: false
        description: Agnes API key used for live authenticated text, image, and video requests. The skill can still load without it and guide setup.
---

# Agnes AI Skill

Use this skill when the user wants to work with Agnes AI's platform or models.
Agnes exposes a unified API base with OpenAI-style request shapes for text and
image generation plus an asynchronous task workflow for video.

Some supplied public materials dated June 1, 2026 described Agnes as offering
free access to core text, image, and video APIs. That "free multimodal API"
positioning is part of what makes Agnes attractive for first-time trials,
creative experimentation, and repeated agent calls. The live official model
docs now also include pricing sections, so treat cost, promotions, and billing
terms as time-sensitive. Use this skill whenever the user wants fast multimodal
prototyping, agent workflows, creative generation, or high-frequency iteration
on Agnes, but verify current pricing when spend matters.

## When To Use

Use this skill when:

- the user mentions Agnes AI, `agnes-ai.com`, or the Agnes platform
- the user wants one provider for text, image, and video generation
- the user wants to test or integrate `agnes-2.0-flash`
- the user wants Agnes image generation, image editing, or image-to-image
- the user wants Agnes video generation, keyframes, or polling logic
- the user wants a low-cost or free-feeling multimodal API surface for agent
  workflows, prototyping, frontend generation, ads, e-commerce creatives, or
  storyboard experiments
- the user is explicitly interested in Agnes because of its public free-access
  or low-friction experimentation positioning

Do not use this skill when:

- the user is asking for non-Agnes provider setup only
- the task does not need Agnes-specific API behavior, model names, or auth
- you would have to guess live API behavior without checking a current Agnes
  response first

## Source Of Truth

Prefer these Agnes docs and settings pages:

- Quickstart: `https://agnes-ai.com/doc/quickstart`
- API key page: `https://platform.agnes-ai.com/settings/apiKeys`
- Text model docs: `https://agnes-ai.com/doc/agnes-20-flash`
- Image 2.0 docs: `https://agnes-ai.com/doc/agnes-image-20-flash`
- Image 2.1 docs: `https://agnes-ai.com/doc/agnes-image-21-flash`
- Video docs: `https://agnes-ai.com/doc/agnes-video-v20`

Use the public writeups only as supporting context for likely use cases and
product positioning, not as the operational source of truth for payloads or
response schemas.

## Base URL And Auth

- Base URL: `https://apihub.agnes-ai.com/v1`
- Auth header: `Authorization: Bearer YOUR_API_KEY`
- Main environment variable: `AGNES_API_KEY`

Check `AGNES_API_KEY` before making any Agnes API request.

## Pricing Note

The official model docs currently expose pricing sections for Image 2.0, Image
2.1, and Video 2.0. Some public articles and notes may still describe broader
free-access positioning. When the user asks about cost, limits, or whether a
workflow is still free, check the live Agnes docs first and call out any
inconsistency instead of choosing one source silently.

## Missing Key Behavior

If `AGNES_API_KEY` is missing and the task requires live Agnes API access:

1. Tell the user Agnes access is not configured yet.
2. Point them to:
   - `https://agnes-ai.com/doc/quickstart`
   - `https://platform.agnes-ai.com/settings/apiKeys`
3. Explain the path briefly:
   `Settings -> API Keys -> Create new secret key`
4. Ask them to provide the key if they want you to save it for future use.

Keep the message short and practical. Do not invent a key. Do not continue with
live API calls until a valid key exists.

## Persisting The Key Permanently

If the user explicitly gives you an Agnes key and wants it remembered, persist
it for future terminal sessions instead of keeping it only in the current
process.

### Rules

- Save it as `AGNES_API_KEY`
- Detect the shell and write to the matching rc file:
  - zsh -> `~/.zshrc`
  - bash -> `~/.bashrc`
  - fallback -> `~/.profile`
- Update an existing `export AGNES_API_KEY=...` line if present
- Otherwise append a new export line
- Also export it in the current session immediately
- Do not echo the full key back after saving
- Tell the user which rc file you changed

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

After saving, continue using `AGNES_API_KEY` for the current task.

## Model Selection

Choose the smallest suitable Agnes model path:

- `agnes-2.0-flash`
  - best default for chat, coding, tool calling, structured agent work, and
    fast production tasks
- `agnes-image-2.1-flash`
  - best default for new text-to-image and straightforward image-to-image work
  - especially useful for high-information-density images and better semantic
    alignment
- `agnes-image-2.0-flash`
  - use when the user specifically wants Image 2.0
  - useful for older image editing or multi-image composition flows that rely
    on `tags: ["img2img"]`
- `agnes-video-v2.0`
  - use for text-to-video, image-to-video, multi-image guided video, and
    keyframe animation

## Text API

Use:

- Endpoint: `POST https://apihub.agnes-ai.com/v1/chat/completions`
- Model: `agnes-2.0-flash`

Supported patterns called out in the docs:

- regular chat completions
- multi-turn conversation
- streaming
- tool calling
- agentic workflows
- coding and reasoning tasks

### Minimal Text Request

```bash
curl https://apihub.agnes-ai.com/v1/chat/completions \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-2.0-flash",
    "messages": [
      {
        "role": "user",
        "content": "Explain how an agent uses tools to complete a task."
      }
    ]
  }'
```

### Streaming

Set `"stream": true`.

### Tool Calling

Use OpenAI-style `tools` and optional `tool_choice`.

### When Agnes Text Is A Good Fit

The supplied materials consistently point to these strengths:

- coding and frontend generation
- agent workflows with repeated tool use
- high-frequency prototyping where speed matters
- structured tasks that benefit from low-cost iteration

## Image APIs

Use:

- Endpoint: `POST https://apihub.agnes-ai.com/v1/images/generations`

### Preferred Default: Image 2.1

Use model `agnes-image-2.1-flash` for most new image work.

Capabilities highlighted by the docs:

- text-to-image
- image-to-image
- composition preservation
- high-information-density image generation
- URL responses

Best-fit scenarios called out by the docs:

- creative design, concept art, and poster drafts
- marketing visuals and product creative
- dense scenes with many visual elements or layered composition
- style transfer, relighting, and background conversion
- app assets, thumbnails, banners, and narrative visuals

Important request fields from the docs:

- required:
  - `model`
  - `prompt`
- common optional:
  - `size`
  - `extra_body.image` for image-to-image
  - `extra_body.response_format` such as `"url"`

#### Minimal 2.1 Text-to-Image Request

```bash
curl https://apihub.agnes-ai.com/v1/images/generations \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-image-2.1-flash",
    "prompt": "A luminous floating city above a misty canyon at sunrise, cinematic realism",
    "size": "1024x768"
  }'
```

#### 2.1 Image-to-Image Request

```bash
curl https://apihub.agnes-ai.com/v1/images/generations \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-image-2.1-flash",
    "prompt": "Transform the scene into a rain-soaked cyberpunk night with neon reflections while preserving the composition",
    "size": "1024x768",
    "extra_body": {
      "image": [
        "https://example.com/input-image.png"
      ],
      "response_format": "url"
    }
  }'
```

#### 2.1 Prompt Structure

The docs recommend a prompt structure like:

`[subject] + [scene / environment] + [style] + [lighting] + [composition] + [quality requirements]`

For high-information-density images, be explicit about:

- primary subject
- background environment
- important secondary details
- style and lighting
- composition constraints
- what must be preserved from the input image, if any

### Image 2.0 Compatibility Mode

Use model `agnes-image-2.0-flash` when the user explicitly asks for 2.0 or when
you need its documented edit/composition flow.

Capabilities highlighted by the docs:

- image-to-image
- multi-image composition
- prompt-based editing
- style and layout control
- seed-based reproducibility
- OpenAI Images-compatible request structure

Best-fit scenarios called out by the docs:

- object replacement, background replacement, and style conversion
- multi-character or multi-reference composition
- e-commerce product enhancement and scene generation
- website, app, game, and video asset production
- social media thumbnails, avatars, memes, and lifestyle visuals

Important request fields from the docs:

- required:
  - `model`
  - `prompt`
- common optional:
  - `size`
  - `seed`
  - `tags`
  - `extra_body.image`
  - `extra_body.response_format`

#### 2.0 Image-to-Image Request

For 2.0 image-to-image and multi-image composition, include
`"tags": ["img2img"]`.

```bash
curl https://apihub.agnes-ai.com/v1/images/generations \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-image-2.0-flash",
    "tags": ["img2img"],
    "prompt": "Transform this image into a cinematic cyberpunk style while preserving the main subject and composition",
    "size": "1024x768",
    "extra_body": {
      "image": [
        "https://example.com/input-image.png"
      ],
      "response_format": "url"
    }
  }'
```

#### 2.0 Multi-Image Composition Request

```bash
curl https://apihub.agnes-ai.com/v1/images/generations \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-image-2.0-flash",
    "tags": ["img2img"],
    "prompt": "Combine the two characters into one cinematic fantasy battle scene with dynamic lighting and a detailed environment",
    "size": "1024x768",
    "extra_body": {
      "image": [
        "https://example.com/character-1.png",
        "https://example.com/character-2.png"
      ],
      "response_format": "url"
    }
  }'
```

#### 2.0 Response Shape

The docs show a response like:

```json
{
  "created": 1774432125,
  "data": [
    {
      "url": "https://..."
    }
  ],
  "usage": {
    "generated_images": 1
  }
}
```

Useful fields to inspect:

- `data[].url`
- `usage.generated_images`

### Practical Image Use Cases

The supplied docs and articles emphasize:

- marketing visuals
- e-commerce product imagery and edits
- social and infographic-style creatives
- concept art and posters
- controlled scene or style edits

When writing prompts, describe both:

- what should change
- what must stay fixed

For high-detail results, specify:

- main subject
- scene or background
- style
- lighting
- composition
- quality requirements

For 2.0 multi-image work, also describe:

- which image provides the subject
- which image provides the environment or supporting objects
- how the inputs should relate spatially

For editing tasks, explicitly separate:

- what must change
- what must remain fixed

## Video API

Use:

- Create task: `POST https://apihub.agnes-ai.com/v1/videos`
- Poll task: `GET https://apihub.agnes-ai.com/v1/videos/{task_id}`
- Model: `agnes-video-v2.0`

This API is asynchronous. Create the task first, then poll until the task
completes or fails.

### Minimal Text-to-Video Task

```bash
curl -X POST https://apihub.agnes-ai.com/v1/videos \
  -H "Authorization: Bearer $AGNES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "agnes-video-v2.0",
    "prompt": "A cinematic shot of a cat walking on the beach at sunset, soft ocean waves, warm golden lighting, realistic motion",
    "height": 768,
    "width": 1152,
    "num_frames": 121,
    "frame_rate": 24
  }'
```

### Image-to-Video

Pass a single image URL in `image`.

### Multi-Image Or Keyframe Video

Pass image URLs in `extra_body.image`.

For keyframes, also set:

```json
"extra_body": {
  "image": ["https://example.com/keyframe1.png", "https://example.com/keyframe2.png"],
  "mode": "keyframes"
}
```

### Supported Video Workflows

The docs explicitly show these request patterns:

- text-to-video
- image-to-video
- multi-image guided video
- keyframe interpolation

Good fit scenarios from the docs and public materials:

- cinematic short-form video
- ads, storyboards, and shot exploration
- motion tests and camera-move experiments
- character animation from a still
- smooth transformation between two or more reference frames

### Video Prompt Guidance

For text-to-video, the docs recommend describing:

- subject
- action
- environment
- camera movement
- lighting
- style

Recommended structure:

`[subject] + [action] + [scene] + [camera move] + [lighting] + [style]`

For image-to-video, describe:

- what should move
- what should stay stable
- how subtle or dramatic the motion should be

For multi-image and keyframe work, describe:

- how the input images relate
- what the transition should feel like
- what identity, angle, or composition must remain consistent

### Polling Workflow

1. Submit the task
2. Read the returned `task_id` or `id`
3. Poll `GET /v1/videos/{task_id}`
4. Stop when:
   - `status` is `completed`
   - or `status` is `failed`
5. On completion, return the result URL and task metadata

### Result Shapes To Expect

The docs show:

- create-task response fields:
  - `id`
  - `object`
  - `model`
  - `status`
  - `progress`
  - `created_at`
- completed-task response fields:
  - `id`
  - `object`
  - `model`
  - `status`
  - `progress`
  - `created_at`
  - `completed_at`
  - `video_url`
  - `size`
  - `seconds`
  - `usage.duration_seconds`

Useful task states:

- `queued`
- `in_progress`
- `completed`
- `failed`

Useful documented error codes:

- `400` invalid request
- `401` unauthorized
- `404` task not found
- `500` server error
- `503` service busy

### Important Video Constraints

- `num_frames` must be `<= 441`
- `num_frames` must satisfy `8n + 1`
- `frame_rate` supports `1-60`
- the public docs' common example is `121` frames at `24` fps, about `5.0s`

### Recommended Video Settings

The docs recommend:

- standard generation:
  - `width: 1152`
  - `height: 768`
  - `num_frames: 121`
  - `frame_rate: 24`
- social short video:
  - `num_frames: 81` or `121`
  - `frame_rate: 24`
- smoother motion:
  - raise `frame_rate` to `24` or `30`
- repeatable results:
  - set a fixed `seed`
- keyframe transitions:
  - set `extra_body.mode: "keyframes"`

### Interpreting Results

The public docs show a `video_url` field on completion. Real responses may vary,
so inspect the returned payload carefully and use the actual completed-result URL
field the API gives you.

### Practical Video Use Cases

The supplied materials emphasize:

- cinematic short-form video
- ad or storyboard exploration
- motion tests with fast iteration
- image-to-video creative experiments
- scenes where composition, camera motion, atmosphere, and continuity matter

## Operational Guidance

- Supported companion CLI range for this skill release:
  - `>=0.1.0 <0.2.0`
- Prefer live API tests over guessing when the user asks whether a model path or
  parameter actually works.
- For image results, expect a URL in the response.
- For video results, be prepared to poll instead of waiting for a synchronous
  response.
- Prefer the separate Agnes CLI execution layer when it is already installed
  and known to be compatible.
- If a local `agnes` command is available, use it only when
  `agnes --version` falls inside `>=0.1.0 <0.2.0`.
- If that version check does not pass, prefer
  `npx -y agnes-ai-cli@^0.1.0 ...` before writing raw request code by hand.
- If the CLI is not available, keep `curl` as the portability fallback for
  validating payloads.
- If the user wants code examples, default to `curl` examples when you need the
  most transparent request baseline.
- If the user wants SDK code, translate the confirmed `curl` payload into the
  target language after validating the request shape.
- If the user asks about pricing, limits, or free access, verify the live docs:
  the supplied docs can contain time-sensitive copy and even intra-page
  inconsistencies.

## Compact Reference

- Base URL: `https://apihub.agnes-ai.com/v1`
- Text endpoint: `/chat/completions`
- Image endpoint: `/images/generations`
- Video create endpoint: `/videos`
- Video poll endpoint: `/videos/{task_id}`

- Text model: `agnes-2.0-flash`
- Image model: `agnes-image-2.1-flash`
- Image compatibility model: `agnes-image-2.0-flash`
- Video model: `agnes-video-v2.0`

## Do Not

- Do not proceed with live Agnes calls when the key is missing
- Do not store the key only in a temporary process if the user asked you to
  remember it
- Do not trust stale marketing claims over the current API docs when payloads
  differ
- Do not overcomplicate the first request; validate the smallest working call
  first, then expand

## Safety

- Never echo a full Agnes API key back to the user after it has been supplied
- Never continue with live Agnes requests when auth is missing or clearly
  invalid
- Never treat article copy or marketing claims as more authoritative than the
  official Agnes API docs
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

- `1.1.2` - Added dual-track CLI guidance so agents prefer the separate Agnes
  execution layer when available and keep raw `curl` as the fallback.
- `1.1.0` - Expanded official doc coverage for Image 2.0, Image 2.1, and Video
  2.0 parameters, scenarios, prompt structures, response fields, and task
  states.
- `1.0.0` - Initial public release with Agnes platform setup, persistent auth,
  text, image, and video workflow guidance.
