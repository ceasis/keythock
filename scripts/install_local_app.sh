#!/bin/zsh
set -euo pipefail

APP_NAME="KeyThock"
BUNDLE_ID="com.keythock.app"
SOURCE_APP=".build/${APP_NAME}.app"
INSTALL_DIR="${HOME}/Applications"
DEST_APP="${INSTALL_DIR}/${APP_NAME}.app"
OPEN_AFTER_INSTALL="${OPEN_AFTER_INSTALL:-1}"

"$(dirname "$0")/build_app.sh"

mkdir -p "${INSTALL_DIR}"
osascript -e "tell application \"${APP_NAME}\" to quit" >/dev/null 2>&1 || true
rm -rf "${DEST_APP}"
ditto "${SOURCE_APP}" "${DEST_APP}"

echo "Installed ${DEST_APP}"

if [[ "${OPEN_AFTER_INSTALL}" == "1" ]]; then
  if open -n "${DEST_APP}"; then
    echo "Launched ${DEST_APP}"
  else
    echo "Installed, but macOS did not launch it automatically. Open ${DEST_APP} manually."
  fi
fi

echo "Input Monitoring app path: ${DEST_APP}"
echo "Bundle ID: ${BUNDLE_ID}"
