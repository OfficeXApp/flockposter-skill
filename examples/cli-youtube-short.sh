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
