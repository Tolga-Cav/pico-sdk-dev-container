#!/usr/bin/env bash
# Run this on your DEBIAN HOST (not inside the dev container).
#
# Usage: scripts/flash-linux.sh build/src/pico2_blink.uf2
#
# Put the Pico in BOOTSEL mode first:
#   hold the BOOTSEL button, plug in USB, then release BOOTSEL.
# It will appear as a mass-storage device named RP2350 (or similar).

set -euo pipefail

UF2_FILE="${1:?Usage: $0 <path-to-uf2>}"

if [ ! -f "$UF2_FILE" ]; then
  echo "Error: file not found: $UF2_FILE"
  exit 1
fi

# Look for common Pico 2 mount point names under /media/$USER or /run/media/$USER
CANDIDATES=(
  "/media/$USER/RP2350"
  "/media/$USER/RPI-RP2"
  "/run/media/$USER/RP2350"
  "/run/media/$USER/RPI-RP2"
)

MOUNT=""
for c in "${CANDIDATES[@]}"; do
  if [ -d "$c" ]; then
    MOUNT="$c"
    break
  fi
done

if [ -z "$MOUNT" ]; then
  echo "Could not auto-detect the Pico's mass-storage mount point."
  echo "Make sure the Pico is in BOOTSEL mode (hold BOOTSEL while plugging in USB)."
  echo "Then check 'ls /media/\$USER/' to find its mount name and re-run:"
  echo "  cp \"$UF2_FILE\" /media/\$USER/<DRIVE_NAME>/"
  exit 1
fi

echo "Copying $UF2_FILE to $MOUNT ..."
cp "$UF2_FILE" "$MOUNT/"
echo "Done. The Pico should reboot and start running the new program."
