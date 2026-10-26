#!/usr/bin/env bash
# User-local install (no root): script, plasmoid, launcher.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_ID="vansh.keepawake.battery"

install -Dm755 "$HERE/keep-awake-mode" "$HOME/.local/bin/keep-awake-mode"
install -Dm644 "$HERE/applications/keep-awake-mode.desktop" \
    "$HOME/.local/share/applications/keep-awake-mode.desktop"
kpackagetool6 -t Plasma/Applet -i "$HERE/plasmoid/$PLASMOID_ID" 2>/dev/null \
    || kpackagetool6 -t Plasma/Applet -u "$HERE/plasmoid/$PLASMOID_ID"

kbuildsycoca6 >/dev/null 2>&1 || true

echo "Installed:"
echo "  ~/.local/bin/keep-awake-mode"
echo "  ~/.local/share/applications/keep-awake-mode.desktop"
echo "  ~/.local/share/plasma/plasmoids/$PLASMOID_ID"
echo
echo "Next: add the 'Power & Battery (Keep-Awake)' widget to your panel"
echo "(or run 'keep-awake-mode tray-enable' to swap it into the system tray)."