#!/usr/bin/env sh
# Downloads the official BrightKB Linux binary into ./app and prepares config.md
set -eu
cd "$(dirname "$0")"

URL="https://brightkb.com/files/BrightKB-linux.bin"

mkdir -p app
echo "Downloading $URL ..."
curl -fL -o app/brightkb "$URL"
chmod 755 app/brightkb

if [ ! -f app/config.md ]; then
  cp config.md.example app/config.md
fi

echo
echo "Done. If your user is not UID 1000, run: sudo chown -R 1000:1000 app"
echo "Then: docker compose up -d --build"
