#!/bin/zsh
set -euo pipefail

BUNDLE_ID="com.thockstudio.app"

tccutil reset ListenEvent "${BUNDLE_ID}" >/dev/null 2>&1 || true
tccutil reset Accessibility "${BUNDLE_ID}" >/dev/null 2>&1 || true

echo "Reset Input Monitoring/Accessibility permissions for ${BUNDLE_ID}."
echo "Relaunch Thock Studio from ~/Applications, then use Diagnostics > Open Input Monitoring."
