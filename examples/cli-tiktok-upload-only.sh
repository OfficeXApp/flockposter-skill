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
