# bs-updater

bs-updater updates all software on an Arch Linux system with one command.
Future updates will support more Linux distributions.
A tray widget for KDE Plasma tells you when updates are available.

## Update sources

bs-updater checks and updates these sources:

- Arch Linux repositories (pacman)
- AUR packages (paru)
- Flatpak applications and runtimes
- AppImages integrated with Gear Lever

## Parts

- `update-all`: a shell command. It updates all sources in sequence.
- `update-all -l`: shows the number of available updates for each source. It does not install them.
- `update-all-check`: the check engine. The shell command and the tray widget use it.
- The tray widget: shows the update status in the KDE Plasma system tray.

## How the tray widget operates

- The widget checks for updates one time each hour. You can configure this interval.
- The icon is white when the system is up to date.
- The icon becomes orange when updates are available. A notification also shows.
- Click the notification to install all updates in a Konsole window.
- Click the icon to check for updates. If updates are available, a click starts the installation.

## Requirements

- Arch Linux
- KDE Plasma 6 and Konsole
- zsh
- paru
- pacman-contrib (supplies `checkupdates`)
- Flatpak
- Gear Lever (Flatpak: `it.mijorus.gearlever`)
- libnotify (supplies `notify-send`)

## Installation (Arch Linux)

1. Clone the repository:

   ```
   git clone https://github.com/WACOMalt/bs-updater.git
   ```

2. Run the installation script:

   ```
   cd bs-updater
   ./install.sh
   ```

   The script installs to your user directories. It does not use sudo.

3. Restart Plasma:

   ```
   systemctl --user restart plasma-plasmashell.service
   ```

4. Add the widget "bs-updater" to the system tray:
   1. Click the arrow in the system tray.
   2. Click the configure button.
   3. Set the "bs-updater" entry to "Shown".

5. Open a new terminal. The `update-all` command is now available.

## Configuration

To change the check interval:

1. Click the arrow in the system tray.
2. Right-click the bs-updater icon.
3. Click "Configure bs-updater".
4. Set the interval in minutes.

## Uninstall

1. Remove the widget from the system tray.
2. Remove the installed files:

   ```
   kpackagetool6 -t Plasma/Applet -r bsums.xyz.bs-updater
   rm ~/.local/bin/update-all-check
   rm -r ~/.local/share/bs-updater
   ```

3. Remove the bs-updater lines from `~/.zshrc`.

## Planned features

- Support for Fedora (DNF)
- Support for Debian and Ubuntu (APT)
- Support for yay as an alternative AUR helper
- Automatic detection of the installed package managers
- Installation instructions for more distributions

## License

This software is in the public domain (The Unlicense). You can use it for any purpose. See [LICENSE](LICENSE).
