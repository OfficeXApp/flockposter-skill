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
