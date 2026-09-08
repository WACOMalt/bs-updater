# bs-updater

bs-updater updates all software on an Arch Linux system with one command.
Future updates will support more Linux distributions.
A tray widget for KDE Plasma tells you when updates are available.

## Update sources

bs-updater checks and updates these sources. You choose which of them to use
in the widget settings.

| Source | Tool | Enabled by default |
| --- | --- | --- |
| Repository packages | `pacman` | no |
| Repository packages | `paru` | yes |
| AUR packages | `paru` | yes |
| Flatpak applications and runtimes | `flatpak` | yes |
| AppImages integrated with Gear Lever | `Gear Lever` | yes |

paru is listed twice because it updates two kinds of package, and you can use
it for one of them without the other.

Two tools for the same kind of package would install the same updates twice
and count them twice. bs-updater checks the selection for that: the settings
show a warning, and `bs-update` uses only the first of the two and says so.
This is why `pacman` is off by default, since `paru` already covers repository
packages.

## Parts

- `bs-update`: a command. It updates all enabled sources in sequence.
- `bs-update -l`: shows the number of available updates for each enabled source. It does not install them.
- `bs-update --list-tools`: shows every supported tool and whether it is enabled.
- `bs-update --tools LIST`: uses this comma or space separated list of tools for one run, instead of the enabled ones. For example: `bs-update --tools flatpak,gearlever`.
- The tray widget: shows the update status in the KDE Plasma system tray. It uses `bs-update` for all checks and updates.

## How the tray widget operates

- The widget checks for updates one time every 6 hours. You can configure this interval in steps of 1 hour.
- When an update run completes, the widget changes to the up-to-date state at once.
- The icon is a white circle with a check mark when the system is up to date.
- The icon is an orange circle with an arrow when updates are available. A notification also shows.
- Click the notification to install all updates in a terminal window.
- Click the icon to check for updates. If updates are available, a click starts the installation.
- The widget contains a copy of the `bs-update` command. The widget installs the command to `~/.local/bin` if it is not present, and replaces an older copy of it after a widget update.
- The widget writes the selected update sources to `~/.config/bs-updater/tools.conf`. The `bs-update` command reads that file, so a run from the notification or from a terminal uses the same sources.
- The widget supports the tray visibility modes. With "Shown when relevant", the icon hides when the system is up to date. It shows again when updates are available. Set the entry to "Always shown" to always see the icon.

## Requirements

- Arch Linux
- KDE Plasma 6
- A terminal application. bs-updater uses the KDE default terminal. If none is set, it uses Konsole.
- libnotify (supplies `notify-send`)

Each update source needs its own tool. You only need the tools of the sources
you enable:

- paru, for repository packages and AUR packages
- pacman-contrib (supplies `checkupdates`), to count repository updates
- Flatpak, for Flatpak applications and runtimes
- Gear Lever (Flatpak: `it.mijorus.gearlever`), for AppImages

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

5. Make sure `~/.local/bin` is in your PATH. The `bs-update` command is now available.

## Configuration

To open the settings:

1. Click the arrow in the system tray.
2. Right-click the bs-updater icon.
3. Click "Configure bs-updater".

The settings on the "General" page are:

- The check interval, in hours.
- Show a notification when updates are available. Default: on.
- Show a notification when a manual check finds no updates. Default: on.

The "Update sources" page has one checkbox per supported tool. Uncheck a tool
to leave its packages alone: bs-updater then neither counts nor installs them.
The page warns when two checked tools update the same kind of package, and
when no source is checked at all.

The command reads the same choice from `~/.config/bs-updater/tools.conf`. If
you use `bs-update` without the widget, write that file yourself:

```
pacman=off
paru-repo=on
paru-aur=on
flatpak=on
gearlever=on
```

Without the file, every tool except `pacman` is enabled.

## Uninstall

1. Remove the widget from the system tray.
2. Remove the installed files:

   ```
   kpackagetool6 -t Plasma/Applet -r bsums.xyz.bs-updater
   rm ~/.local/bin/bs-update
   ```

## Tests

`tests/run-tests.sh` tests the `bs-update` command. It replaces pacman, paru,
Flatpak, and the other commands with stubs, so it installs nothing and runs on
any machine:

```
./tests/run-tests.sh
```

## Planned features

- Support for Fedora (DNF)
- Support for Debian and Ubuntu (APT)
- Support for yay as an alternative AUR helper
- Automatic detection of the installed package managers, to preselect the update sources
- Installation instructions for more distributions

## License

This software is in the public domain (The Unlicense). You can use it for any purpose. See [LICENSE](LICENSE).
