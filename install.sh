#!/bin/sh
# bs-updater installation script for Arch Linux.
# Installs to user directories only. Does not use sudo.
set -e

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"

missing=""
for cmd in paru checkupdates flatpak notify-send konsole; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
flatpak info it.mijorus.gearlever >/dev/null 2>&1 || missing="$missing gearlever(flatpak)"
if [ -n "$missing" ]; then
    echo "Missing requirements:$missing"
    echo "Install them, then run this script again."
    exit 1
fi

echo "Installing the update-all command..."
install -Dm755 "$REPO_DIR/bin/update-all" "$BIN_DIR/update-all"

# Remove files from bs-updater versions before 1.1.0.
rm -f "$BIN_DIR/update-all-check"
rm -rf "$HOME/.local/share/bs-updater"

if command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Installing the Plasma widget..."
    kpackagetool6 -t Plasma/Applet -i "$REPO_DIR/plasmoid/bsums.xyz.bs-updater" 2>/dev/null \
        || kpackagetool6 -t Plasma/Applet -u "$REPO_DIR/plasmoid/bsums.xyz.bs-updater"
else
    echo "kpackagetool6 not found. The Plasma widget was not installed."
fi

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "NOTE: $BIN_DIR is not in your PATH. Add it to use the update-all command." ;;
esac

echo
echo "Installation complete. Next steps:"
echo "1. Restart Plasma: systemctl --user restart plasma-plasmashell.service"
echo "2. Add the widget \"bs-updater\" to the system tray."
