---
name: flockposter
description: Use this skill whenever the user wants to install, configure, or use FlockPoster from the command line, automate social media scheduling, upload media before posting, inspect connected integrations, create drafts or scheduled posts, or fetch analytics through the public FlockPoster CLI and API.
homepage: https://docs.flockposter.com
metadata: {"clawdbot":{"requires":{"bins":["flockposter"],"env":["FLOCKPOSTER_API_KEY"]}}}
---

# FlockPoster Customer Skill

Use this skill for customer-facing FlockPoster CLI workflows only. Stay within the public CLI and public API. Do not assume access to product internals, deployment infrastructure, private repositories, or unreleased features.

## Scope

Help with:
- installing `flockposter-cli`
- configuring `FLOCKPOSTER_API_KEY`
- listing integrations
- discovering provider settings and dynamic tools
- uploading media before posting
- creating draft or scheduled posts
- listing or deleting posts
- fetching platform or post analytics
- resolving missing release IDs with public commands

Do not rely on private files, internal architecture, staging environments, deployment commands, or internal business logic.

## Setup

Install the CLI if it is missing:

```bash
npm install -g flockposter-cli
```

Required environment variable:

```bash
export FLOCKPOSTER_API_KEY=your_api_key_here
```

Optional for self-hosted or non-default API hosts:

```bash
export FLOCKPOSTER_API_URL=https://your-host.example.com/api
```

If the user does not know where to get an API key, direct them to their FlockPoster account settings and the public docs rather than guessing.

## Working Pattern

Use this sequence unless the user asks for something narrower:

1. Discover integrations with `flockposter integrations:list`
2. Inspect integration settings with `flockposter integrations:settings <integration-id>`
3. Fetch provider-specific dynamic data when needed with `flockposter integrations:trigger`
4. Upload media before posting with `flockposter upload <file>`
5. Create the post with `flockposter posts:create`
6. Review output with `flockposter posts:list` or analytics commands

Do not skip discovery for provider-specific posts. Integration IDs are customer-specific, and settings can vary by provider, account, and release.

## Agent Decision Rules

- Use CLI flags for one platform with one shared content body.
- Use repeated `-c` and matching repeated `-m` values for comments, replies, or X threads.
- Use `posts:create --json <file>` when each platform needs different content, different media, or different settings.
- For CLI `--settings`, pass provider fields directly; the backend can infer the provider from the integration ID.
- For CLI `--json`, include `settings.__type` when settings are present.
- For public API payloads, always include `settings.__type` for provider-specific settings.
- Never invent provider values. Run `integrations:settings`, then use the field names and allowed values shown by the schema.
- Treat uploaded FlockPoster media URLs as the default for TikTok, Instagram, and YouTube posts.

## Core Commands

Discovery:

```bash
flockposter integrations:list
flockposter integrations:settings <integration-id>
flockposter integrations:trigger <integration-id> <method> -d '{"key":"value"}'
```

Posting:

```bash
flockposter posts:create -c "Content" -s "2026-05-18T15:00:00Z" -i "integration-id"
flockposter posts:create -c "Content" -s "2026-05-18T15:00:00Z" -t draft -i "integration-id"
flockposter posts:create -c "Thread item 1" -c "Thread item 2" -s "2026-05-18T15:00:00Z" -d 5000 -i "integration-id"
flockposter posts:create --json post.json
```

Management:

```bash
flockposter posts:list
flockposter posts:delete <post-id>
```

Uploads:

```bash
flockposter upload image.jpg
```

For posts with local media, upload the file first and pass the returned `.path` to `posts:create`:

```bash
MEDIA_RESULT=$(flockposter upload video.mp4)
MEDIA_URL=$(echo "$MEDIA_RESULT" | jq -r '.path')
flockposter posts:create -c "Content" -s "2026-05-18T15:00:00Z" -m "$MEDIA_URL" -i "integration-id"
```

Analytics:

```bash
flockposter analytics:platform <integration-id> -d 30
flockposter analytics:post <post-id> -d 7
```

Missing release ID recovery:

```bash
flockposter posts:missing <post-id>
flockposter posts:connect <post-id> --release-id "<content-id>"
```

## Payload Shapes

CLI `--settings` example. Use this for a single integration:

```bash
flockposter posts:create \
  -c "Post content" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"who_can_reply_post":"everyone"}' \
  -i "x-integration-id"
```

CLI `--json` example. Use this when platforms need different content/settings:

```json
{
  "integrations": ["x-integration-id", "instagram-integration-id"],
  "posts": [
    {
      "provider": "x",
      "post": [{ "content": "Short X version", "image": [] }],
      "settings": { "__type": "x", "who_can_reply_post": "everyone" }
    },
    {
      "provider": "instagram",
      "post": [{ "content": "Instagram caption", "image": ["https://uploads.flockposter.com/reel.mp4"] }],
      "settings": { "__type": "instagram", "post_type": "post" }
    }
  ]
}
```

Public API payloads use a different shape from CLI JSON files:

```json
{
  "type": "schedule",
  "date": "2026-05-18T15:00:00.000Z",
  "shortLink": false,
  "tags": [],
  "posts": [
    {
      "integration": { "id": "instagram-integration-id" },
      "value": [
        {
          "content": "Instagram caption",
          "image": [{ "id": "uploaded-media-id", "path": "https://uploads.flockposter.com/reel.mp4" }]
        }
      ],
      "settings": { "__type": "instagram", "post_type": "post" }
    }
  ]
}
```

## Provider-Specific Cases

Always run `flockposter integrations:settings <integration-id>` before relying on provider-specific fields. The examples below show common public settings, but the live integration schema should be treated as the source of truth.

Common setting keys:

| Provider | Required/common settings | Notes |
|----------|--------------------------|-------|
| X | `who_can_reply_post`, optional `community` | Valid reply values: `everyone`, `following`, `mentionedUsers`, `subscribers`, `verified`. |
| TikTok | `privacy_level`, `comment`, `duet`, `stitch`, `autoAddMusic`, `brand_content_toggle`, `brand_organic_toggle`, `content_posting_method` | Use `content_posting_method: "UPLOAD"` for upload without posting. |
| Instagram | `post_type`, optional `is_trial_reel`, `graduation_strategy`, `collaborators` | Reels use `post_type: "post"` with video media. |
| YouTube | `title`, `type`, optional `selfDeclaredMadeForKids`, `thumbnail`, `tags` | Shorts use normal YouTube upload settings. |

### X

Use `who_can_reply_post` to control replies. Valid values are `everyone`, `following`, `mentionedUsers`, `subscribers`, and `verified`. Use `community` only for an X community URL in the form `https://x.com/i/communities/<id>`.

```bash
flockposter posts:create \
  -c "Post content" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"who_can_reply_post":"everyone","community":""}' \
  -i "x-integration-id"
```

For threads, create comments/replies through the normal post/comment structure or JSON mode.

```bash
flockposter posts:create \
  -c "1/ First thread item" \
  -c "2/ Second thread item" \
  -c "3/ Final thread item" \
  -s "2026-05-18T15:00:00Z" \
  -d 5000 \
  --settings '{"who_can_reply_post":"everyone"}' \
  -i "x-integration-id"
```

### TikTok

Upload media to FlockPoster before creating TikTok posts. TikTok supports two posting methods:
- `DIRECT_POST`: publish directly to TikTok.
- `UPLOAD`: upload media to TikTok without posting, so the creator can review/edit/publish in TikTok later.

```bash
VIDEO_RESULT=$(flockposter upload video.mp4)
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Video caption #fyp" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"content_posting_method":"UPLOAD","privacy_level":"PUBLIC_TO_EVERYONE","comment":true,"duet":false,"stitch":false,"autoAddMusic":"no","brand_content_toggle":false,"brand_organic_toggle":false,"video_made_with_ai":false}' \
  -m "$VIDEO_URL" \
  -i "tiktok-integration-id"
```

When `content_posting_method` is `UPLOAD`, TikTok handles final publishing in the TikTok app. Privacy, comment, duet, stitch, and disclosure controls may be disabled or ignored by TikTok for upload-only flows.

For a direct TikTok publish, use `content_posting_method: "DIRECT_POST"`:

```bash
flockposter posts:create \
  -c "Video caption #fyp" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"content_posting_method":"DIRECT_POST","privacy_level":"PUBLIC_TO_EVERYONE","comment":true,"duet":false,"stitch":false,"autoAddMusic":"no","brand_content_toggle":false,"brand_organic_toggle":false,"video_made_with_ai":false}' \
  -m "$VIDEO_URL" \
  -i "tiktok-integration-id"
```

### Instagram Reels, Posts, Stories, And Trial Reels

Instagram uses `post_type: "post"` for regular feed posts and Reels, and `post_type: "story"` for Stories. FlockPoster determines Reel behavior from video media under `post_type: "post"`.

```bash
VIDEO_RESULT=$(flockposter upload reel.mp4)
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Reel caption" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"post_type":"post"}' \
  -m "$VIDEO_URL" \
  -i "instagram-integration-id"
```

For Trial Reels, use one video with `is_trial_reel: true`. Optional `graduation_strategy` values are `MANUAL` and `SS_PERFORMANCE`.

```bash
flockposter posts:create \
  -c "Trial Reel caption" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"post_type":"post","is_trial_reel":true,"graduation_strategy":"MANUAL"}' \
  -m "$VIDEO_URL" \
  -i "instagram-integration-id"
```

Stories use `post_type: "story"` and should use Story-compatible media.

```bash
STORY_RESULT=$(flockposter upload story.jpg)
STORY_URL=$(echo "$STORY_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"post_type":"story"}' \
  -m "$STORY_URL" \
  -i "instagram-integration-id"
```

### YouTube Shorts

YouTube uses the normal YouTube upload flow for both standard videos and Shorts. Upload a Shorts-compatible video and create a YouTube post with the usual title, privacy, made-for-kids, thumbnail, and tags settings.

```bash
VIDEO_RESULT=$(flockposter upload short.mp4)
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Short description" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"title":"Short title","type":"public","selfDeclaredMadeForKids":"no","tags":[{"value":"shorts","label":"shorts"}]}' \
  -m "$VIDEO_URL" \
  -i "youtube-integration-id"
```

For a normal YouTube video, use the same settings and provide the uploaded video URL as media. If using a thumbnail, upload the thumbnail first and pass it in `settings.thumbnail` as an object with `id` and `path`.

## Inline Examples

Use these examples directly from the copied `SKILL.md`. Replace integration IDs, dates, captions, and media file paths with the customer's values.

### CLI X Thread

```bash
#!/usr/bin/env bash
set -euo pipefail

# Required:
#   export FLOCKPOSTER_API_KEY=...
#   export X_INTEGRATION_ID=...

flockposter integrations:settings "$X_INTEGRATION_ID"

flockposter posts:create \
  -c "1/ First thread item" \
  -c "2/ Second thread item" \
  -c "3/ Final thread item" \
  -s "2026-05-18T15:00:00Z" \
  -d 5000 \
  --settings '{"who_can_reply_post":"everyone","community":""}' \
  -i "$X_INTEGRATION_ID"
```

### CLI TikTok Upload Without Posting

```bash
#!/usr/bin/env bash
set -euo pipefail

# Required:
#   export FLOCKPOSTER_API_KEY=...
#   export TIKTOK_INTEGRATION_ID=...
#   export VIDEO_FILE=video.mp4
#
# TikTok upload-only means FlockPoster uploads media to TikTok without publishing it.
# The creator finishes review/edit/publish inside TikTok.

flockposter integrations:settings "$TIKTOK_INTEGRATION_ID"

VIDEO_RESULT=$(flockposter upload "${VIDEO_FILE:-video.mp4}")
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Video caption #fyp" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"content_posting_method":"UPLOAD","privacy_level":"PUBLIC_TO_EVERYONE","comment":true,"duet":false,"stitch":false,"autoAddMusic":"no","brand_content_toggle":false,"brand_organic_toggle":false,"video_made_with_ai":false}' \
  -m "$VIDEO_URL" \
  -i "$TIKTOK_INTEGRATION_ID"
```

### CLI Instagram Reel

```bash
#!/usr/bin/env bash
set -euo pipefail

# Required:
#   export FLOCKPOSTER_API_KEY=...
#   export INSTAGRAM_INTEGRATION_ID=...
#   export VIDEO_FILE=reel.mp4
#
# Instagram Reels use post_type "post" with video media.

flockposter integrations:settings "$INSTAGRAM_INTEGRATION_ID"

VIDEO_RESULT=$(flockposter upload "${VIDEO_FILE:-reel.mp4}")
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Reel caption" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"post_type":"post"}' \
  -m "$VIDEO_URL" \
  -i "$INSTAGRAM_INTEGRATION_ID"
```

### CLI YouTube Short

```bash
#!/usr/bin/env bash
set -euo pipefail

# Required:
#   export FLOCKPOSTER_API_KEY=...
#   export YOUTUBE_INTEGRATION_ID=...
#   export VIDEO_FILE=short.mp4
#
# YouTube Shorts use the normal YouTube upload flow.

flockposter integrations:settings "$YOUTUBE_INTEGRATION_ID"

VIDEO_RESULT=$(flockposter upload "${VIDEO_FILE:-short.mp4}")
VIDEO_URL=$(echo "$VIDEO_RESULT" | jq -r '.path')

flockposter posts:create \
  -c "Short description" \
  -s "2026-05-18T15:00:00Z" \
  --settings '{"title":"Short title","type":"public","selfDeclaredMadeForKids":"no","tags":[{"value":"shorts","label":"shorts"}]}' \
  -m "$VIDEO_URL" \
  -i "$YOUTUBE_INTEGRATION_ID"
```

### CLI Multi-Platform JSON

Save as `post.json`, replace IDs and media URLs, then run `flockposter posts:create --json post.json`.

```json
{
  "integrations": ["x-integration-id", "instagram-integration-id", "youtube-integration-id", "tiktok-integration-id"],
  "posts": [
    {
      "provider": "x",
      "post": [
        {
          "content": "Short X version",
          "image": []
        }
      ],
      "settings": {
        "__type": "x",
        "who_can_reply_post": "everyone",
        "community": ""
      }
    },
    {
      "provider": "instagram",
      "post": [
        {
          "content": "Instagram Reel caption",
          "image": ["https://uploads.flockposter.com/reel.mp4"]
        }
      ],
      "settings": {
        "__type": "instagram",
        "post_type": "post"
      }
    },
    {
      "provider": "youtube",
      "post": [
        {
          "content": "YouTube Short description",
          "image": ["https://uploads.flockposter.com/short.mp4"]
        }
      ],
      "settings": {
        "__type": "youtube",
        "title": "Short title",
        "type": "public",
        "selfDeclaredMadeForKids": "no",
        "tags": [{ "value": "shorts", "label": "shorts" }]
      }
    },
    {
      "provider": "tiktok",
      "post": [
        {
          "content": "TikTok caption #fyp",
          "image": ["https://uploads.flockposter.com/tiktok.mp4"]
        }
      ],
      "settings": {
        "__type": "tiktok",
        "content_posting_method": "UPLOAD",
        "privacy_level": "PUBLIC_TO_EVERYONE",
        "comment": true,
        "duet": false,
        "stitch": false,
        "autoAddMusic": "no",
        "brand_content_toggle": false,
        "brand_organic_toggle": false,
        "video_made_with_ai": false
      }
    }
  ]
}
```

### Public API Instagram Reel JSON

Use this shape for `POST /public/v1/posts` payloads. Replace the integration ID and uploaded media object.

```json
{
  "type": "schedule",
  "date": "2026-05-18T15:00:00.000Z",
  "shortLink": false,
  "tags": [],
  "posts": [
    {
      "integration": {
        "id": "instagram-integration-id"
      },
      "value": [
        {
          "content": "Instagram Reel caption",
          "image": [
            {
              "id": "uploaded-media-id",
              "path": "https://uploads.flockposter.com/reel.mp4"
            }
          ]
        }
      ],
      "settings": {
        "__type": "instagram",
        "post_type": "post"
      }
    }
  ]
}
```

## Important Behaviors

- Treat media upload as the default for local files. Many platforms reject external URLs.
- Use ISO 8601 timestamps when scheduling posts.
- Inspect integration settings before inventing provider-specific fields.
- If analytics returns `{"missing": true}`, recover the release ID with `posts:missing` and `posts:connect`.
- TikTok visibility is controlled with `privacy_level`.
- Instagram Reels use `post_type: "post"` with video media.
- X reply controls use the allowed values from `who_can_reply_post`.
- YouTube Shorts use the normal YouTube upload settings.
- Prefer the public docs and the CLI help output over assumptions.

## Troubleshooting

If the CLI fails with auth errors:
- check that `FLOCKPOSTER_API_KEY` is set
- confirm the account has access to the requested feature
- verify `FLOCKPOSTER_API_URL` only if the user is self-hosting or using a custom host

If posting fails:
- confirm the integration exists and is connected
- inspect the integration settings schema
- upload media first if the post includes files
- simplify to a minimal post, then add provider-specific settings back

If the user needs exact argument names or a command list, run:

```bash
flockposter --help
flockposter <command> --help
```

## Public References

- Docs: `https://docs.flockposter.com`
- App: `https://app.flockposter.com`
- CLI package: `https://www.npmjs.com/package/flockposter-cli`
