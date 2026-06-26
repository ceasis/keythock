#!/bin/zsh
set -euo pipefail

APP_NAME="KeyThock"
BUNDLE_ID="com.keythock.app"
VERSION="1.0.0"
BUILD_NUMBER="1"
BUILD_DIR=".build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
EXECUTABLE="${BUILD_DIR}/release/KeyThock"
SIGNING_PROFILE="${KEYTHOCK_SIGNING_PROFILE:-local}"
ENTITLEMENTS="${KEYTHOCK_ENTITLEMENTS:-}"

if [[ "${SIGNING_PROFILE}" == "appstore" && -z "${ENTITLEMENTS}" ]]; then
  ENTITLEMENTS="Resources/KeyThock.entitlements"
fi

# Stable code-signing identity for repeatable local builds. Override with
# KEYTHOCK_SIGNING_IDENTITY; auto-detects an Apple Development cert and falls
# back to ad-hoc only if no identity is available.
SIGNING_IDENTITY="${KEYTHOCK_SIGNING_IDENTITY:-}"
if [[ -z "${SIGNING_IDENTITY}" ]]; then
  SIGNING_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | awk '/Apple Development/ {print $2; exit}')"
fi
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"

swift build -c release

rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS" "${APP_DIR}/Contents/Resources"
cp "${EXECUTABLE}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
if [[ -f "Resources/AppIcon.icns" ]]; then
  cp "Resources/AppIcon.icns" "${APP_DIR}/Contents/Resources/AppIcon.icns"
fi
if [[ -d "Sources/KeyThock/Resources" ]]; then
  ditto "Sources/KeyThock/Resources" "${APP_DIR}/Contents/Resources"
fi

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${BUILD_NUMBER}</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSInputMonitoringUsageDescription</key>
  <string>KeyThock needs Input Monitoring to detect key presses locally and play keyboard sounds. It never stores typed text.</string>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright KeyThock</string>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  if [[ -f "${ENTITLEMENTS}" ]]; then
    codesign --force --deep --sign "${SIGNING_IDENTITY}" --entitlements "${ENTITLEMENTS}" "${APP_DIR}" >/dev/null
  else
    codesign --force --deep --sign "${SIGNING_IDENTITY}" "${APP_DIR}" >/dev/null
  fi
fi

echo "Built ${APP_DIR}"
echo "Signing profile: ${SIGNING_PROFILE}"
if [[ "${SIGNING_IDENTITY}" == "-" ]]; then
  echo "Signing identity: ad-hoc"
else
  echo "Signing identity: ${SIGNING_IDENTITY}"
fi
if [[ -n "${ENTITLEMENTS}" ]]; then
  echo "Entitlements: ${ENTITLEMENTS}"
else
  echo "Entitlements: none"
fi
