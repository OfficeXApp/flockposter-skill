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

## Important Behaviors

- Treat media upload as the default for local files. Many platforms reject external URLs.
- Use ISO 8601 timestamps when scheduling posts.
- Inspect integration settings before inventing provider-specific fields.
- If analytics returns `{"missing": true}`, recover the release ID with `posts:missing` and `posts:connect`.
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
