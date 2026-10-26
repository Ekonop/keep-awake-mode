#!/usr/bin/env bash
# User-local uninstall: script, plasmoid, launcher (but NOT the tray swap).
set -euo pipefail

PLASMOID_ID="vansh.keepawake.battery"

rm -f "$HOME/.local/bin/keep-awake-mode"
rm -f "$HOME/.local/share/applications/keep-awake-mode.desktop"
if [ -d "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID" ]; then
    kpackagetool6 -t Plasma/Applet -r "$PLASMOID_ID" 2>/dev/null \
        || rm -rf "$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
fi
kbuildsycoca6 >/dev/null 2>&1 || true

echo "Uninstalled. If you had swapped the tray battery, run:"
echo "  keep-awake-mode tray-disable   (if still on PATH)"
echo "and remove the widget from the panel."