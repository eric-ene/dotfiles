#!/usr/bin/bash

while [ true ]; do
TITLE=$(hyprctl activewindow | grep title | cut -d' ' -f2-)
TITLE_TRUNC=$(echo $TITLE | gawk -v len=40 '{print substr($0, 1, len)}')

if [ "${#TITLE}" -eq "${#TITLE_TRUNC}" ]; then
  OUT="${TITLE}"
else
  OUT="${TITLE_TRUNC}..."
fi

echo "$OUT"

sleep 0.2
done


