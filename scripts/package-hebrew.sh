#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
APP="build/DerivedData/Build/Products/Release/Snapzy.app"
OUT="build/hebrew"
mkdir -p "$OUT/stage"
test -d "$APP"
test -d "$APP/Contents/Resources/he.lproj"
test -x "$APP/Contents/Helpers/snapzy"
ditto "$APP" "$OUT/stage/Snapzy.app"
APP="$OUT/stage/Snapzy.app"
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
for component in \
  "$SPARKLE/Versions/B/XPCServices/Installer.xpc" \
  "$SPARKLE/Versions/B/XPCServices/Downloader.xpc" \
  "$SPARKLE/Versions/B/Autoupdate" \
  "$SPARKLE/Versions/B/Updater.app" \
  "$SPARKLE" \
  "$APP/Contents/Helpers/snapzy"; do
  if [[ -e "$component" ]]; then
    codesign --force --sign - --options runtime --timestamp=none --preserve-metadata=entitlements "$component"
  fi
done
sed 's/$(PRODUCT_BUNDLE_IDENTIFIER)/com.trongduong.snapzy/g' Snapzy/Snapzy.entitlements > "$OUT/entitlements.plist"
codesign --force --sign - --options runtime --timestamp=none --entitlements "$OUT/entitlements.plist" "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"
file "$APP/Contents/MacOS/Snapzy"
cp docs/INSTALL.he.md "$OUT/stage/הוראות התקנה.txt"
cp LICENSE "$OUT/stage/LICENSE.txt"
ln -s /Applications "$OUT/stage/Applications"
hdiutil create -volname "Snapzy Hebrew" -srcfolder "$OUT/stage" -ov -format UDZO "$OUT/Snapzy-Hebrew.dmg"
shasum -a 256 "$OUT/Snapzy-Hebrew.dmg" > "$OUT/SHA256SUMS.txt"
