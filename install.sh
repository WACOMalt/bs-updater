#!/bin/sh
# bs-updater installation script for Arch Linux.
# Installs to user directories only. Does not use sudo.
set -e

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/bs-updater"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='[ -r "$HOME/.local/share/bs-updater/update-all.zsh" ] && source "$HOME/.local/share/bs-updater/update-all.zsh"'

missing=""
for cmd in paru checkupdates flatpak notify-send konsole zsh; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
flatpak info it.mijorus.gearlever >/dev/null 2>&1 || missing="$missing gearlever(flatpak)"
if [ -n "$missing" ]; then
    echo "Missing requirements:$missing"
    echo "Install them, then run this script again."
    exit 1
fi

echo "Installing the update-all-check command..."
install -Dm755 "$REPO_DIR/bin/update-all-check" "$BIN_DIR/update-all-check"

echo "Installing the shell functions..."
install -Dm644 "$REPO_DIR/shell/update-all.zsh" "$SHARE_DIR/update-all.zsh"
if ! grep -qF ".local/share/bs-updater/update-all.zsh" "$ZSHRC" 2>/dev/null; then
    printf '\n# bs-updater\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
    echo "Added a source line to $ZSHRC."
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Installing the Plasma widget..."
    kpackagetool6 -t Plasma/Applet -i "$REPO_DIR/plasmoid/bsums.xyz.bs-updater" 2>/dev/null \
        || kpackagetool6 -t Plasma/Applet -u "$REPO_DIR/plasmoid/bsums.xyz.bs-updater"
else
    echo "kpackagetool6 not found. The Plasma widget was not installed."
fi

echo
echo "Installation complete. Next steps:"
echo "1. Restart Plasma: systemctl --user restart plasma-plasmashell.service"
echo "2. Add the widget \"bs-updater\" to the system tray."
echo "3. Open a new terminal, or run: source ~/.zshrc"
