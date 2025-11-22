#!/bin/bash

set -Eeuo pipefail
trap 'echo "❌ ERROR: Command \"$BASH_COMMAND\" failed at line $LINENO." >&2' ERR

KERN_DIR="kern"
TODAY=$(date +%Y/%m/%d)

for kern_file in "$KERN_DIR"/*; do
    if [ -f "$kern_file" ]; then
        echo "Processing $kern_file..."

        tmp_file=$(mktemp)
        barnum "$kern_file" > "$tmp_file"

        if ! cmp -s "$tmp_file" "$kern_file"; then
            echo "Changes detected, updating $kern_file..."
            mv "$tmp_file" "$kern_file"
            sed -i '' "s|^!!!EEV:.*|!!!EEV: $TODAY|" "$kern_file"
        else
            echo "No changes in $kern_file, skipping update."
            rm "$tmp_file"
        fi

        # remove last byte if it's a newline
        last_byte=$(tail -c1 "$kern_file" 2>/dev/null | od -An -t u1 | tr -d ' ')
        if [ "$last_byte" = "10" ]; then
            truncate -s -1 "$kern_file"
        fi
    fi
done

echo "Done!"
