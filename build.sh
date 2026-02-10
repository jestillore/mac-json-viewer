#!/bin/bash
set -euo pipefail

APP_NAME="JSONViewer"
PROJECT="${APP_NAME}.xcodeproj"
SCHEME="${APP_NAME}"
BUILD_DIR="$(pwd)/build"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"

echo "==> Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Building ${APP_NAME} (Release)..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES \
    build 2>&1 | tail -3

echo "==> Verifying app bundle..."
if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: ${APP_PATH} not found. Build may have failed."
    exit 1
fi

codesign -dvv "$APP_PATH" 2>&1 | head -5

echo "==> Creating DMG..."
DMG_STAGING="${BUILD_DIR}/dmg-staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH" 2>&1
rm -rf "$DMG_STAGING"

echo ""
echo "==> Build complete!"
echo "    App: ${APP_PATH}"
echo "    DMG: ${DMG_PATH}"
