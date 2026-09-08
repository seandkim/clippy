#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release

APP="Clippy.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/release/Clippy" "$APP/Contents/MacOS/Clippy"
cp "Resources/Clippy.icns" "$APP/Contents/Resources/Clippy.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Clippy</string>
  <key>CFBundleDisplayName</key><string>Clippy</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleIdentifier</key><string>com.seandkim.clippy</string>
  <key>CFBundleExecutable</key><string>Clippy</string>
  <key>CFBundleIconFile</key><string>Clippy</string>
  <key>CFBundleIconName</key><string>Clippy</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
</dict>
</plist>
PLIST

# LaunchServices treats a bundle with no PkgInfo as suspect; cheap to include.
printf 'APPL????' > "$APP/Contents/PkgInfo"

echo "Built $APP"
