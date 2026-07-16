#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="$(pwd)/ClipBar.app/Contents/MacOS/ClipBar"
if [[ ! -x "$BIN" ]]; then
  echo "ClipBar.app not found — run scripts/bundle.sh first." >&2
  exit 1
fi

PLIST="$HOME/Library/LaunchAgents/dev.merge.clipbar.plist"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>dev.merge.clipbar</string>
  <key>ProgramArguments</key><array><string>$BIN</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><false/>
</dict>
</plist>
PL

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Installed login item: $PLIST"
echo "To remove: launchctl unload \"$PLIST\" && rm \"$PLIST\""
