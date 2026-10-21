
#!/bin/sh
# GL.iNet Opal / NoDogSplash captive portal updater
set -eu

REPO_OWNER="carteraccs"
REPO_NAME="router-splash"
BRANCH="main"

URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/splash.html"

TARGET="/etc/nodogsplash/htdocs/splash.html"
BACKUP="/etc/nodogsplash/htdocs/splash.html.previous"
TEMP="/tmp/elm-street-splash.$$"

log() {
  echo "portal-update: $*"
  logger -t portal-update "$*" 2>/dev/null || true
}

cleanup() {
  rm -f "$TEMP"
}

trap cleanup EXIT HUP INT TERM


if ! wget -q -T 20 -O "$TEMP" "$URL"; then
  log "Download failed. Keeping current portal."
  exit 1
fi


BYTES="$(wc -c < "$TEMP" | tr -d ' ')"

if [ "$BYTES" -lt 100 ] || [ "$BYTES" -gt 102400 ]; then
  log "Invalid file size: $BYTES bytes."
  exit 1
fi


if ! grep -Fq '<html' "$TEMP" && \
   ! grep -Fq '<!DOCTYPE html' "$TEMP"; then
  log "Downloaded file is not valid HTML."
  exit 1
fi


if ! grep -Fq '$authtarget' "$TEMP" && \
   ! { grep -Fq '$authaction' "$TEMP" && \
       grep -Fq '$tok' "$TEMP"; }; then
  log "Missing NoDogSplash authentication variables."
  exit 1
fi

if cmp -s "$TEMP" "$TARGET"; then
  log "No changes detected."
  exit 0
fi


cp "$TARGET" "$BACKUP"

STAGED="${TARGET}.new"
cp "$TEMP" "$STAGED"
chmod 644 "$STAGED"
mv -f "$STAGED" "$TARGET"

log "Portal updated successfully."
