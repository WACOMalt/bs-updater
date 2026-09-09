# 4. Installation

## 4.1 Before you start

Make sure that the system obeys these conditions:

- The distribution is Arch Linux, Fedora, Nobara, Debian or Ubuntu.
- The system has KDE Plasma 6.
- The system has libnotify, which supplies the `notify-send` command.
- The system has a terminal application.
- The system has `git`.

The installation script stops if `notify-send` is absent.

## 4.2 The tool of each update source

Install the tool of each source that you use. The other tools are not
necessary.

| Source | Tool to install | Distribution |
| --- | --- | --- |
| Repository packages and AUR packages | paru | Arch Linux |
| The count of repository updates | pacman-contrib | Arch Linux |
| RPM packages | DNF 4 or DNF 5 | Fedora |
| RPM packages and the Nobara fixups | nobara-sync | Nobara |
| Debian packages | APT | Debian, Ubuntu |
| Flatpak applications and runtimes | Flatpak | all |
| AppImages | Gear Lever, `it.mijorus.gearlever` | all |

pacman-contrib supplies the `checkupdates` command. `bs-update` counts the
repository updates with that command. DNF, APT and nobara-sync are parts of
their distributions.

## 4.3 Procedure: the installation from the repository

1. Clone the repository.

   ```
   git clone https://github.com/WACOMalt/bs-updater.git
   ```

2. Go to the new directory.

   ```
   cd bs-updater
   ```

3. Start the installation script.

   ```
   ./install.sh
   ```

   The script installs into the directories of the user. It does not use
   `sudo`.

4. Restart Plasma.

   ```
   systemctl --user restart plasma-plasmashell.service
   ```

5. Click the arrow in the system tray.
6. Click the configuration button of the system tray.
7. Set the entry "bs-updater" to "Shown".
8. Make sure that `~/.local/bin` is in the `PATH` variable.

The `bs-update` command is now available in a terminal.

## 4.4 Procedure: the installation from the KDE Store

The KDE Store supplies the widget alone. The widget contains a copy of
`bs-update` and installs that copy.

1. Open the widget browser of Plasma.
2. Click "Get New Widgets".
3. Find "bs-updater" and install it.
4. Add the widget to the system tray.

The widget writes `~/.local/bin/bs-update` at its first start. It then sends
a notification. Make sure that `~/.local/bin` is in the `PATH` variable.

## 4.5 What the installation script does

The script `install.sh` does these steps in sequence:

1. It examines the system for `notify-send`. It stops if the command is
   absent.
2. It examines the system for the tool of each update source. It shows a
   message for each absent tool. An absent tool is not an error.
3. It identifies the distribution and shows the tools to select.
4. It installs `bin/bs-update` to `~/.local/bin/bs-update` with the mode
   755.
5. It removes the files of the versions before 1.4.0.
6. It copies `bin/bs-update` into the widget package.
7. It installs or updates the widget with `kpackagetool6`.
8. It shows a message if `~/.local/bin` is not in the `PATH` variable.

Step 2 examines only the tools that suit the system. An Arch Linux system
shows no message about DNF, and a Fedora system shows no message about paru.

Step 5 removes these three items:

- `~/.local/bin/update-all-check`
- `~/.local/bin/update-all`
- `~/.local/share/bs-updater`

## 4.6 The installed files

| File | Function |
| --- | --- |
| `~/.local/bin/bs-update` | The command. |
| The applet directory | The widget package. |
| `~/.config/bs-updater/tools.conf` | The selected tools. The widget writes it. |
| `~/.cache/bs-updater/last-update` | The time of the last update run. |

The two last files come into existence at the first start of the widget and
at the first successful update run.

## 4.7 Procedure: the removal of the product

1. Remove the widget from the system tray.
2. Remove the widget package.

   ```
   kpackagetool6 -t Plasma/Applet -r bsums.xyz.bs-updater
   ```

3. Remove the command.

   ```
   rm ~/.local/bin/bs-update
   ```

4. Remove the configuration file and the state file.

   ```
   rm -r ~/.config/bs-updater ~/.cache/bs-updater
   ```
