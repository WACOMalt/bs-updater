# bs-updater shell functions
# This file is installed by install.sh and sourced from ~/.zshrc.

alias gearlever='flatpak run it.mijorus.gearlever'

# Update all integrated AppImages through Gear Lever.
appimage-update-all() {
  gearlever --list-installed | awk '{print $NF}' | grep '^/' | while read -r f; do
    # gearlever always asks y/N before updating (--force is ignored), and inside
    # this pipeline its stdin is the exhausted file-list pipe -> EOFError.
    # Feed it "y" answers on a fresh stdin instead.
    echo "-> $f"; yes | gearlever --update "$f"
  done
}

# Update everything: Arch repositories, AUR, Flatpak, AppImages.
# -l / --list: only check and report the number of available updates per source.
update-all() {
  if [[ "$1" == "-l" || "$1" == "--list" ]]; then
    update-all-check
    return 0
  fi
  paru -Syu && flatpak update && appimage-update-all
}
