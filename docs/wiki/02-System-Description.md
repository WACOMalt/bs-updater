# 2. System description

## 2.1 The two parts

bs-updater has two parts. The parts are independent, but they agree on one
configuration file.

| Part | Type | Location after the installation |
| --- | --- | --- |
| `bs-update` | POSIX shell script | `~/.local/bin/bs-update` |
| The tray widget | KDE Plasma applet | The applet directory of the user |

## 2.2 The `bs-update` command

`bs-update` is a POSIX shell script. It does all of the work with the package
tools. It has four modes:

| Mode | Option | Function |
| --- | --- | --- |
| Update | none | Installs the updates of each enabled tool. |
| List | `-l` | Counts the available updates of each enabled tool. |
| Tool list | `--list-tools` | Shows each supported tool and its state. |
| Terminal | `--in-terminal` | Starts a new terminal window and updates in it. |

The command reads its selection of tools from a configuration file. The
`--tools` option replaces that selection for one run.

The command is the only part that starts a package tool. The widget never
starts a package tool. A run from the widget, a run from the notification
and a run from a terminal have one behavior.

## 2.3 The tray widget

The widget is a KDE Plasma applet in QML. It does these tasks:

1. It starts `bs-update -l` on a timer and reads the counts.
2. It shows an icon and a tooltip for the update state.
3. It writes the selection of the user to the configuration file.
4. It starts `bs-update --in-terminal` when the user asks for an update.
5. It installs the `bs-update` command if the command is absent.

The widget contains its own copy of `bs-update`. Because of this, an
installation of the widget alone from the KDE Store gives a complete
product.

## 2.4 The interface between the parts

The two parts speak through the file system. There is no socket and no
D-Bus service.

| Direction | Mechanism | Content |
| --- | --- | --- |
| Widget to command | `~/.config/bs-updater/tools.conf` | The selected tools. |
| Command to widget | Standard output of `bs-update -l` | The counts. |
| Command to widget | `~/.cache/bs-updater/last-update` | The time of the last update run. |

Chapter 8 describes each mechanism in detail.

## 2.5 The supported tools

`bs-update` drives eight tool entries. Each entry has an identifier, a
package domain and a name for the user.

| Identifier | Package domain | Name for the user |
| --- | --- | --- |
| `pacman` | repo | pacman |
| `paru-repo` | repo | paru, repository packages |
| `paru-aur` | aur | paru, AUR packages |
| `dnf` | rpm | DNF |
| `nobara-sync` | rpm | nobara-sync |
| `apt` | deb | APT |
| `flatpak` | flatpak | Flatpak |
| `gearlever` | appimage | Gear Lever |

The command runs the enabled tools in this sequence. Chapter 3 describes the
package domains and the conflict rule.

## 2.6 Privileges

bs-updater runs as the user. It does not install a system service, and it
does not add a file outside the home directory of the user.

Three tools must have root privileges to install updates:

- `pacman` and `dnf` run through `sudo`;
- `apt` runs through `sudo`;
- `nobara-sync` raises its own privileges, so `bs-update` does not add
  `sudo` to it.

No count operation uses root privileges. This is a design constraint,
because a scheduled check has no password. Chapter 8 gives the reason for
each count command.
