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
