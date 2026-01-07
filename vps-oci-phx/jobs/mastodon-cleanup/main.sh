#!/usr/bin/env bash
set -e

# Load environment variables
if [ -f "$(dirname "$0")/env" ]; then
    source "$(dirname "$0")/env"
else
    echo "Error: Environment file not found. Please create env with required credentials." >&2
    exit 1
fi

if [ -z "$HEALTHCHECKS_UUID" ]; then
    error_exit "Error: HEALTHCHECKS_UUID is not set in environment file"
fi

# Ping healthchecks.io at start
wget -q -O /dev/null "https://hc-ping.com/${HEALTHCHECKS_UUID}/start" || true

docker exec -it mastodon tootctl accounts cull
docker exec -it mastodon tootctl accounts prune
docker exec -it mastodon tootctl media remove-orphans

# Ping healthchecks.io on success
wget -q -O /dev/null "https://hc-ping.com/${HEALTHCHECKS_UUID}" || true
