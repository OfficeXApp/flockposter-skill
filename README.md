# FlockPoster Skill

Agent-facing skill docs for FlockPoster, plus the CLI install and setup needed to use it.

This repository is the public skill/docs repo. The CLI itself is installed from npm.

FlockPoster helps AI agents and developers schedule, manage, and analyze social media posts across 28+ platforms using the `flockposter` CLI and public API.

## What this repo contains

- `SKILL.md` - the main skill file to load into your AI agent workflow
- `README.md` - quick install and usage guide

## Install the CLI

```bash
npm install -g flockposter-cli
# or
pnpm install -g flockposter-cli
```

Verify the install:

```bash
flockposter --help
```

## Configure API access

```bash
export FLOCKPOSTER_API_KEY=your_api_key_here
# optional for self-hosted instances
export FLOCKPOSTER_API_URL=https://your-flockposter-server.com/api
```

Get your API key from `https://app.flockposter.com/settings`.

## Use the skill

Load [`SKILL.md`](./SKILL.md) into your AI agent context when working with:

- FlockPoster CLI automation
- social media scheduling workflows
- media uploads before posting
- integration discovery and provider-specific settings
- post analytics and missing release ID recovery

## Quick start

```bash
flockposter integrations:list

flockposter posts:create \
  -c "Hello from FlockPoster" \
  -s "2026-05-01T10:00:00Z" \
  -i "your-integration-id"

flockposter posts:list
```

## Links

- App: `https://app.flockposter.com`
- npm: `https://www.npmjs.com/package/flockposter-cli`
- Docs: `https://docs.flockposter.com`
- Skill repo: `https://github.com/OfficeXApp/flockposter-skill`
