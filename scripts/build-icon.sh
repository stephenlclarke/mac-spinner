#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"
mkdir -p Icon.iconset
rsvg-convert -w 1024 -h 1024 assets/mac-spinner-icon.svg -o /tmp/mac-spinner-icon-1024.png
sips -z 16 16 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_16x16.png >/dev/null
sips -z 32 32 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_16x16@2x.png >/dev/null
sips -z 32 32 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_32x32.png >/dev/null
sips -z 64 64 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_32x32@2x.png >/dev/null
sips -z 128 128 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_128x128.png >/dev/null
sips -z 256 256 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_128x128@2x.png >/dev/null
sips -z 256 256 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_256x256.png >/dev/null
sips -z 512 512 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_256x256@2x.png >/dev/null
sips -z 512 512 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_512x512.png >/dev/null
sips -z 1024 1024 /tmp/mac-spinner-icon-1024.png --out Icon.iconset/icon_512x512@2x.png >/dev/null
iconutil -c icns Icon.iconset -o assets/mac-spinner.icns
cp /tmp/mac-spinner-icon-1024.png assets/mac-spinner-icon.png
rm /tmp/mac-spinner-icon-1024.png
