#!/usr/bin/env bash
set -euo pipefail

job_dir="$(cd "$(dirname "$0")" && pwd)"
paths_file="$job_dir/paths.txt"

if [ ! -f "$paths_file" ]; then
    echo "Error: paths.txt not found at $paths_file" >&2
    exit 1
fi

hostname_name="$(hostname)"
remote_base="/mnt/jbod/Configs/$hostname_name"

while IFS= read -r line || [ -n "$line" ]; do
    # Trim leading whitespace and ignore empty/comment lines in paths.txt.
    trimmed="${line#"${line%%[![:space:]]*}"}"

    # Skip empty/whitespace-only lines.
    if [ -z "${trimmed//[[:space:]]/}" ]; then
        continue
    fi

    # Skip comment lines.
    if [[ "$trimmed" == \#* ]]; then
        continue
    fi

    # Use the cleaned line as the path to process.
    path="$trimmed"

    # Enforce absolute paths to avoid ambiguous destinations.
    if [[ "$path" != /* ]]; then
        echo "Error: path must be absolute: $path" >&2
        exit 1
    fi

    # Ensure the source file exists before attempting transfer.
    if [ ! -e "$path" ]; then
        echo "Error: path not found: $path" >&2
        exit 1
    fi

    # Build remote destination from local path parts.
    file_name="$(basename "$path")"
    dir_name="$(dirname "$path")"
    dir_clean="${dir_name#/}"

    # Preserve the local directory tree under the host folder.
    if [ -z "$dir_clean" ]; then
        remote_dir="$remote_base"
    else
        remote_dir="$remote_base/$dir_clean"
    fi

    # Quote for safe SSH command execution.
    remote_dir_escaped="$(printf '%q' "$remote_dir")"
    remote_target_escaped="$(printf '%q' "$remote_dir/$file_name")"

    # Create destination directory and copy the file over SSH.
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null nixos@antarctica "mkdir -p $remote_dir_escaped"
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -- "$path" "nixos@antarctica:$remote_target_escaped" < /dev/null
done < "$paths_file"
