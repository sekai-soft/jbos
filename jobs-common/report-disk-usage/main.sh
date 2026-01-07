#!/usr/bin/env bash
set -euo pipefail

hostname_name="$(hostname)"
remote_base="/mnt/jbod/Monitoring"
remote_target="$remote_base/$hostname_name.txt"
tmp_file="$(mktemp)"

df -h --output=source,used,size,pcent \
  | awk '$1 ~ "^/dev/" {printf "%s %s/%s %s\n", $1, $2, $3, $4}' \
  | sort -k3 -hr \
  > "$tmp_file"

remote_target_escaped="$(printf '%q' "$remote_target")"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -- "$tmp_file" "nixos@antarctica:$remote_target_escaped" < /dev/null

rm -f "$tmp_file"
