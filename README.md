# bs-updater

bs-updater updates all software on an Arch Linux, Fedora, Nobara, Debian or
Ubuntu system with one command.
A tray widget for KDE Plasma tells you when updates are available.

## Update sources

bs-updater checks and updates these sources. You choose which of them to use
in the widget settings.

| Source | Tool | Distribution | Enabled by default |
| --- | --- | --- | --- |
| Repository packages | `pacman` | Arch | no |
| Repository packages | `paru` | Arch | yes |
| AUR packages | `paru` | Arch | yes |
| RPM packages | `dnf` | Fedora | no |
| RPM packages and Nobara fixups | `nobara-sync` | Nobara | no |
| Debian packages | `apt` | Debian, Ubuntu | no |
| Flatpak applications and runtimes | `flatpak` | any | yes |
| AppImages integrated with Gear Lever | `Gear Lever` | any | yes |

paru is listed twice because it updates two kinds of package, and you can use
it for one of them without the other.

The defaults suit Arch. On Fedora check `dnf`, on Nobara check `nobara-sync`,
on Debian or Ubuntu check `apt`, and uncheck the Arch sources. See
[Fedora and Nobara](#fedora-and-nobara) and
[Debian and Ubuntu](#debian-and-ubuntu).

Two tools for the same kind of package would install the same updates twice
and count them twice. bs-updater checks the selection for that: the settings
show a warning, and `bs-update` uses only the first of the two and says so.
This is why `pacman` is off by default, since `paru` already covers repository
packages, and why only one of `dnf` and `nobara-sync` may be checked.

Arch repository packages, RPM packages and Debian packages are separate kinds
of package, so `pacman`, `dnf` and `apt` do not clash. A system has one of
them.

## Fedora and Nobara

On Fedora, check `dnf` under "Update sources" and uncheck the Arch sources.
`bs-update` counts the available updates with `dnf check-update`, which needs
no root, and installs them with `sudo dnf upgrade`.

On Nobara, check `nobara-sync` instead. `nobara-sync cli` installs the system
updates together with the Nobara fixups, and asks for the root password
itself, so bs-updater does not run it through `sudo`. It counts its updates
with `dnf check-update`, because `nobara-sync check-updates` would ask for the
root password on every scheduled check.

`nobara-sync cli` leaves Flatpaks alone unless it is given `--all`, so keep
the `flatpak` source checked to have them updated and counted.

## Debian and Ubuntu

On Debian or Ubuntu, check `apt` under "Update sources" and uncheck the Arch
sources. This covers every distribution that uses APT, such as Linux Mint and
Pop!_OS.

`bs-update` counts the available updates with `apt-get -s upgrade`, which
simulates the upgrade and needs no root, and installs them with
`sudo apt-get update && sudo apt-get upgrade`.

Two details follow from this:

- The count comes from the package lists on disk, because refreshing them
  needs root and a scheduled check has no password to give. Debian and Ubuntu
  refresh those lists in the background with the `apt-daily` timer, so the
  count is as recent as the last refresh. The update run refreshes them
  itself before it installs anything.
- `apt-get upgrade` never removes a package. A package whose update would
  need a removal is kept back and left to you, and it is not counted either,
  so the number you see is the number that gets installed. Run
  `sudo apt-get dist-upgrade` yourself for the kept back packages.

## Parts

- `bs-update`: a command. It updates all enabled sources in sequence.
- `bs-update -l`: shows the number of available updates for each enabled source. It does not install them.
- `bs-update --list-tools`: shows every supported tool and whether it is enabled.
- `bs-update --tools LIST`: uses this comma or space separated list of tools for one run, instead of the enabled ones. For example: `bs-update --tools flatpak,gearlever`.
- `bs-update --interaction LEVEL`: uses `confirm`, `auto`, or `silent` for one run, instead of the configured level. See [Interaction level](#interaction-level).
- The tray widget: shows the update status in the KDE Plasma system tray. It uses `bs-update` for all checks and updates.

## Interaction level

The interaction level says how an update run asks its questions. Set it in the
widget settings, on the "General" page, under "When you start an update".

| Level | Terminal | Questions |
| --- | --- | --- |
| `confirm` | yes | Each source asks before it installs. This is the default. |
| `auto` | yes | Each source that has an option for it installs without a question. |
| `silent` | no | The same, and the run happens in the background. |

At the `silent` level the widget starts the run with no terminal, and a
notification reports the result. The output goes to
`~/.cache/bs-updater/last-run.log`.

A source that needs the root password then has no terminal to ask in, so
`bs-update` makes `sudo` ask for it in a window instead. It uses the first of
these programs that is installed: `ksshaskpass`, `ssh-askpass`,
`gnome-ssh-askpass`, `lxqt-openssh-askpass`, or `x11-ssh-askpass`. KDE Plasma
supplies `ksshaskpass`. Without one of them, a source that needs the root
password cannot install anything, and `bs-update` says so.

paru is not run through `sudo`, because paru refuses to run as root and calls
`sudo` itself. It gets the same option through `--sudoflags`.

Two points to know before you leave a run unattended:

- `nobara-sync` has no documented option to install without a question, so it
  asks at every level.
- A source that installs without a question also answers for you when an
  update replaces or removes a package. Read
  `~/.cache/bs-updater/last-run.log` if an update matters to you.

These are the options each source gets at the `auto` and `silent` levels:

| Source | Option |
| --- | --- |
| `pacman` | `--noconfirm` |
| `paru` | `--noconfirm --skipreview` |
| `dnf` | `-y` |
| `apt` | `-y`, with `DEBIAN_FRONTEND=noninteractive` for the questions about a changed configuration file |
| `flatpak` | `-y` |
| `Gear Lever` | `--yes`, which it always gets |
| `nobara-sync` | none |

A run you start in a terminal yourself always asks for the root password in
that terminal, at every level.

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

- Arch Linux, Fedora, Nobara, Debian, or Ubuntu
- KDE Plasma 6
- A terminal application. bs-updater uses the KDE default terminal. If none is set, it uses Konsole.
- libnotify (supplies `notify-send`)

Each update source needs its own tool. You only need the tools of the sources
you enable:

- paru, for repository packages and AUR packages (Arch)
- pacman-contrib (supplies `checkupdates`), to count repository updates (Arch)
- dnf, for RPM packages (Fedora). dnf 4 and dnf 5 both work
- nobara-sync, for RPM packages and the Nobara fixups (Nobara; part of the
  distribution)
- apt, for Debian packages (Debian, Ubuntu; part of the distribution)
- Flatpak, for Flatpak applications and runtimes
- Gear Lever (Flatpak: `it.mijorus.gearlever`), for AppImages

## Installation

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
- The interaction level. Default: show a terminal and ask before each source
  installs. See [Interaction level](#interaction-level).

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
dnf=off
nobara-sync=off
apt=off
flatpak=on
gearlever=on
interaction=confirm
```

Without the file, the Arch tools except `pacman` are enabled, along with
`flatpak` and `gearlever`.

## Uninstall

1. Remove the widget from the system tray.
2. Remove the installed files:

   ```
   kpackagetool6 -t Plasma/Applet -r bsums.xyz.bs-updater
   rm ~/.local/bin/bs-update
   ```

## Tests

`tests/run-tests.sh` tests the `bs-update` command. It replaces pacman, paru,
dnf, nobara-sync, apt, Flatpak, and the other commands with stubs, so it
installs nothing and runs on any machine:

```
./tests/run-tests.sh
```

## Planned features

- Support for yay as an alternative AUR helper
- Automatic detection of the installed package managers, to preselect the update sources
- Installation instructions for more distributions

## License

This software is in the public domain (The Unlicense). You can use it for any purpose. See [LICENSE](LICENSE).
