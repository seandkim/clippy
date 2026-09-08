#!/usr/bin/env bash
# Builds Clippy.app and installs the real bundle into /Applications.
# A symlink here does NOT work: LaunchServices resolves it and registers the
# repo path instead, so the app never shows up in the Applications view.
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/bundle.sh

DEST="/Applications/Clippy.app"
rm -rf "$DEST"
cp -R Clippy.app "$DEST"

LSR=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LSR" -u "$(pwd)/Clippy.app" 2>/dev/null || true
"$LSR" -f "$DEST"

if launchctl print "gui/$(id -u)/com.seandkim.clippy" >/dev/null 2>&1; then
  launchctl kickstart -k "gui/$(id -u)/com.seandkim.clippy"
  echo "Installed $DEST and restarted the login item."
else
  echo "Installed $DEST. Run scripts/install-login-item.sh to launch at login."
fi
