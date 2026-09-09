#!/bin/sh
# bs-updater installation script for Arch Linux, Fedora, Nobara, Debian
# and Ubuntu.
# Installs to user directories only. Does not use sudo.
set -e

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"

# Needed whichever update sources you use.
missing=""
for cmd in notify-send; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
    echo "Missing requirements:$missing"
    echo "Install them, then run this script again."
    exit 1
fi

# Needed per update source. A source you do not use can stay unchecked in
# the widget settings, so a missing tool is only a warning. Only the tools
# that suit this system are reported: an Arch machine has no use for dnf,
# and a Fedora machine has none for paru.
absent=""
if command -v pacman >/dev/null 2>&1; then
    command -v paru >/dev/null 2>&1 || absent="$absent paru(repository and AUR packages)"
    command -v checkupdates >/dev/null 2>&1 || absent="$absent pacman-contrib(counts repository updates)"
fi
if command -v rpm >/dev/null 2>&1; then
    command -v dnf >/dev/null 2>&1 || absent="$absent dnf(RPM packages)"
fi
if command -v dpkg >/dev/null 2>&1; then
    command -v apt-get >/dev/null 2>&1 || absent="$absent apt(Debian packages)"
fi
command -v flatpak >/dev/null 2>&1 || absent="$absent flatpak(Flatpak applications)"
flatpak info it.mijorus.gearlever >/dev/null 2>&1 || absent="$absent gearlever(AppImages)"
if [ -n "$absent" ]; then
    echo "These update sources have no tool installed:$absent"
    echo "Install the ones you want, and uncheck the rest in the widget settings."
    echo
fi

# The update sources are off unless they suit an Arch system, so say which
# ones to turn on here.
if command -v nobara-sync >/dev/null 2>&1; then
    echo "This looks like Nobara. Check \"nobara-sync\" in the widget settings,"
    echo "under \"Update sources\", and uncheck the Arch sources."
    echo
elif command -v dnf >/dev/null 2>&1 && ! command -v pacman >/dev/null 2>&1; then
    echo "This looks like Fedora. Check \"dnf\" in the widget settings, under"
    echo "\"Update sources\", and uncheck the Arch sources."
    echo
elif command -v apt-get >/dev/null 2>&1 && ! command -v pacman >/dev/null 2>&1; then
    echo "This looks like Debian or Ubuntu. Check \"apt\" in the widget settings,"
    echo "under \"Update sources\", and uncheck the Arch sources."
    echo
fi

echo "Installing the bs-update command..."
install -Dm755 "$REPO_DIR/bin/bs-update" "$BIN_DIR/bs-update"

# Remove files from bs-updater versions before 1.4.0.
rm -f "$BIN_DIR/update-all-check" "$BIN_DIR/update-all"
rm -rf "$HOME/.local/share/bs-updater"

if command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Installing the Plasma widget..."
    rm -rf "$REPO_DIR/plasmoid/bsums.xyz.bs-updater/contents/code"
    install -Dm755 "$REPO_DIR/bin/bs-update" \
        "$REPO_DIR/plasmoid/bsums.xyz.bs-updater/contents/code/bs-update"
    kpackagetool6 -t Plasma/Applet -i "$REPO_DIR/plasmoid/bsums.xyz.bs-updater" 2>/dev/null \
        || kpackagetool6 -t Plasma/Applet -u "$REPO_DIR/plasmoid/bsums.xyz.bs-updater"
else
    echo "kpackagetool6 not found. The Plasma widget was not installed."
fi

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "NOTE: $BIN_DIR is not in your PATH. Add it to use the bs-update command." ;;
esac

echo
echo "Installation complete. Next steps:"
echo "1. Restart Plasma: systemctl --user restart plasma-plasmashell.service"
echo "2. Add the widget \"bs-updater\" to the system tray."
