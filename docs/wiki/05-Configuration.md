# 5. Configuration

## 5.1 Procedure: how to open the settings

1. Click the arrow in the system tray.
2. Click the bs-updater icon with the right button of the mouse.
3. Click "Configure bs-updater".

The settings have two pages: "General" and "Update sources".

## 5.2 The page "General"

| Setting | Type | Default | Function |
| --- | --- | --- | --- |
| Check for updates every | 1 to 24 hours | 6 hours | The interval between two scheduled checks. |
| When updates are available | on or off | on | Sends a notification when the total is more than zero. |
| When a manual check finds no updates | on or off | on | Sends a notification when a manual check gives a total of zero. |

A scheduled check never sends the second notification. Only a check that the
user starts can show the up-to-date state.

## 5.3 The page "Update sources"

The page has one checkbox for each tool entry. Clear a checkbox to leave the
packages of that source alone. bs-updater then does not count them and does
not install them.

| Group | Checkbox | Default |
| --- | --- | --- |
| Repository packages, Arch | pacman | cleared |
| Repository packages, Arch | paru | selected |
| AUR packages | paru | selected |
| RPM packages, Fedora | dnf | cleared |
| RPM packages, Fedora | nobara-sync | cleared |
| Debian packages, Debian and Ubuntu | apt | cleared |
| Flatpak applications and runtimes | flatpak | selected |
| AppImages | Gear Lever | selected |

The page shows a warning in two conditions:

- Two selected tools update the same kind of package. The warning names the
  two tools and the kind of package.
- The user selects no tool. bs-updater then does not check and does not
  update.

The warning does not stop the user. `bs-update` applies the conflict rule of
chapter 3 if the condition stays.

## 5.4 The configuration file

The widget writes the selection to this file:

```
~/.config/bs-updater/tools.conf
```

The widget writes the file at its start and after each change of a
checkbox. `bs-update` reads the file at each run. A run from the
widget, a run from the notification and a run from a terminal use the same
tools.

The file has one line for each tool entry:

```
# Written by the bs-updater widget. Change it in the widget settings.
pacman=off
paru-repo=on
paru-aur=on
dnf=off
nobara-sync=off
apt=off
flatpak=on
gearlever=on
```

## 5.5 The syntax of the configuration file

| Rule | Effect |
| --- | --- |
| An empty line | The command ignores it. |
| A line that starts with `#` | The command ignores it. |
| `name=on`, `name=true`, `name=1`, `name=yes` | The command enables the tool. |
| Any other value | The command disables the tool. |
| An unknown name | The command shows a warning and ignores the name. |

A file that enables no tool is a correct file. bs-updater then does nothing
and reports it. This is different from an absent file: without the file,
`bs-update` uses the default selection of chapter 3.

## 5.6 Manual configuration

You can use `bs-update` without the widget. Write the file yourself in that
condition. Make the directory first:

```
mkdir -p ~/.config/bs-updater
```

Then write the file with the lines of section 5.4.

**CAUTION: The widget writes this file again at each change of a setting.
Your manual changes are then lost. Use the settings page if you have the
widget.**

## 5.7 How to examine the current selection

```
bs-update --list-tools
```

The output shows each tool, its state, its name and its package domain:

```
pacman       off pacman: repository packages
paru-repo    on  paru (repository packages): repository packages
paru-aur     on  paru (AUR packages): AUR packages
dnf          off DNF: RPM packages
nobara-sync  off nobara-sync: RPM packages
apt          off APT: Debian packages
flatpak      on  Flatpak: Flatpak applications and runtimes
gearlever    on  Gear Lever: AppImages
```

## 5.8 A temporary selection

The `--tools` option replaces the selection for one run. The option accepts
a list with commas or with spaces.

```
bs-update --tools flatpak,gearlever
bs-update --tools "apt flatpak" -l
```

The option does not change the configuration file.
