# FlockPoster Customer Skill

This repository contains a customer-safe `SKILL.md` for using FlockPoster through the public CLI and public API.

It is intentionally limited to supported customer workflows:
- install `flockposter-cli`
- configure `FLOCKPOSTER_API_KEY`
- discover integrations and provider settings
- upload media
- create draft or scheduled posts
- fetch analytics
- recover missing release IDs

## Install the CLI

```bash
npm install -g flockposter-cli
```

Verify installation:

```bash
flockposter --help
```

## Configure access

```bash
export FLOCKPOSTER_API_KEY=your_api_key_here
```

Optional for self-hosted instances:

```bash
export FLOCKPOSTER_API_URL=https://your-host.example.com/api
```

## Quick start

```bash
flockposter integrations:list

flockposter posts:create \
  -c "Hello from FlockPoster" \
  -s "2026-05-18T15:00:00Z" \
  -i "your-integration-id"

flockposter posts:list
```

## Files

- `SKILL.md` contains the agent-facing workflow and guardrails.
- `README.md` contains the human-facing quick start.

## Public links

- App: `https://app.flockposter.com`
- Docs: `https://docs.flockposter.com`
- npm: `https://www.npmjs.com/package/flockposter-cli`
