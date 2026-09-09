# 8. Architecture

## 8.1 The repository layout

| Path | Content |
| --- | --- |
| `bin/bs-update` | The command. |
| `plasmoid/bsums.xyz.bs-updater/` | The widget package. |
| `plasmoid/.../metadata.json` | The identifier, the version and the category of the widget. |
| `plasmoid/.../contents/ui/main.qml` | The applet. |
| `plasmoid/.../contents/ui/configGeneral.qml` | The page "General". |
| `plasmoid/.../contents/ui/configSources.qml` | The page "Update sources". |
| `plasmoid/.../contents/config/main.xml` | The settings and their defaults. |
| `plasmoid/.../contents/config/config.qml` | The two settings pages. |
| `plasmoid/.../contents/icons/` | The icon for the up-to-date state. |
| `install.sh` | The installation script. |
| `make-plasmoid.sh` | The package script for the KDE Store. |
| `tests/run-tests.sh` | The test suite. |
| `logo/`, `screenshots/` | The material for the KDE Store. |

The directory `contents/code/` is not in the repository. `install.sh` and
`make-plasmoid.sh` make it and copy `bin/bs-update` into it. The repository holds
one copy of the command, and the widget package always holds the current
copy.

## 8.2 The data flow

```
    +-----------------------------+
    |  Settings pages of the      |
    |  widget                     |
    +--------------+--------------+
                   | the user selects the tools
                   v
    +-----------------------------+
    |  main.qml                   |
    |  - a timer for the checks   |
    |  - the icon and the tooltip |
    +---+------------+--------+---+
        |            |        ^
        | writes     | starts | reads the counts
        v            v        |
 tools.conf     bs-update ----+
        |            |
        | reads      | starts
        +----------->+
                     v
    +-----------------------------+
    | pacman, paru, DNF,          |
    | nobara-sync, APT, Flatpak,  |
    | Gear Lever                  |
    +--------------+--------------+
                   | a successful update run
                   v
             last-update  ---> main.qml watches this file
```

## 8.3 The tables in the command

`bs-update` holds two tables as text. Each line has three fields with a
vertical bar between them.

The table `TOOLS` has the identifier, the package domain and the name for
the user. The sequence of the lines is the sequence of the update run, and
it is also the priority for the conflict rule.

The table `DOMAINS` has the identifier, the heading for the list output and
the name for the user.

The function `field` reads one column of one row. Four small functions use
it: `tool_domain`, `tool_name`, `domain_heading` and `domain_name`.

A new tool must have one new line in `TOOLS`, one branch in `count_tool`
and one branch in `update_tool`. The file `configSources.qml` holds the same table
for the settings page.

## 8.4 The selection of the tools

`bs-update` finds the selection in this sequence:

1. The option `--tools`, if it is present.
2. The file `tools.conf`, if the command can read it.
3. The default list `paru-repo paru-aur flatpak gearlever`.

The function `resolve_tools` then examines the list. It removes an unknown
identifier, and it removes each tool with a package domain that an earlier
tool covers. It reports each removal on the error output.

## 8.5 The count of the RPM updates

```
dnf -q check-update
```

DNF writes one package for each line, in the form
`name.arch version repository`. The parser must obey three conditions:

- A long package name wraps onto a second line with an indent. Only a line
  that starts in the first column is a package.
- The first field of a package line always holds a period, because it ends
  with the architecture.
- The section `Obsoleting Packages` at the end repeats packages from the
  list above. The parser stops at that heading.

The parser is one `awk` program with these three conditions. It gives the
correct count with DNF 4 and with DNF 5, and it does not use root
privileges.

## 8.6 The count of the Debian updates

```
apt-get -q -s upgrade
```

The option `-s` simulates the upgrade. The simulation writes one line
`Inst <name> ...` for each package that the real upgrade installs. The
parser counts these lines.

Three properties follow from this design:

- The count does not use root privileges, but `apt-get update` must have
  them. The count comes from the package lists on the disk. Debian and Ubuntu
  refresh these lists in the background with the timer `apt-daily`. The
  count is as recent as the last refresh. The update run refreshes the
  lists itself before it installs a package.
- `apt-get upgrade` never removes a package. A package whose update must
  have a removal stays back. The simulation does not write an `Inst` line for it,
  so the count does not hold it. The number on the screen is the number
  that the update run installs.
- The command uses `apt-get` and not `apt`. `apt-get` has a stable command
  line interface. `apt` writes a warning that its interface is not for
  scripts.

For a package that stays back, run this command yourself:

```
sudo apt-get dist-upgrade
```

## 8.7 Gear Lever without a display

```
env -u DISPLAY -u WAYLAND_DISPLAY flatpak run it.mijorus.gearlever
```

The command line interface of Gear Lever also starts the graphical
application. The application then shows a window and a second tray icon.
The two variables `DISPLAY` and `WAYLAND_DISPLAY` are absent in the
command above, so only the command line interface runs.

The option `--list-updates` writes the line `No updates available` when
there is nothing to do. The parser removes that line before it counts.

The update command is `--update --all --yes`. The option `--all` examines
each integrated AppImage and downloads only an AppImage with a newer
version. The option `--yes` answers the interactive question.

## 8.8 The state file

```
~/.cache/bs-updater/last-update
```

`bs-update` writes the time in seconds into this file at the end of a
successful update run. The function `mark_updated` does this.

The widget starts one shell process that watches the file. The process
reads the time of the last change every 3 seconds. It exits when the time
changes. The widget then shows the up-to-date state and starts the process
again.

A poll of one file every 3 seconds is inexpensive. A file monitor is an extra dependency for the widget, so the design uses
the poll.

## 8.9 The widget and the shell

The widget has one `DataSource` with the engine `executable`. Each command
is one source name. The handler `onNewData` disconnects the source and then
identifies it:

| Source name | Reaction |
| --- | --- |
| The watcher command | Sets the total to zero, checks again, watches again. |
| A command that holds ` -l ` | Reads the counts from the output. |
| The command that writes `tools.conf` | Starts a new check if a check ran before. |

The widget builds the command that writes `tools.conf` from the eight
settings. QML binds that string to the settings, so a change of a checkbox
makes a new string. The handler `onWriteToolsConfigCommandChanged` then
writes the file. The file always agrees with the settings.

## 8.10 The installation of the command by the widget

The widget contains a copy of `bs-update` in `contents/code/`. At each
start, the widget compares that copy with `~/.local/bin/bs-update`:

| Condition | Action |
| --- | --- |
| The two files are equal. | The widget does nothing. |
| The file in `~/.local/bin` is absent. | The widget copies the file and sends a notification. |
| The file starts with `# bs-updater:` | The widget replaces the file. |
| The file starts with other text. | The widget does nothing. |

The third row holds the command and the widget at the same version after a
widget update. The fourth row protects a file of a different program with
the same name.

## 8.11 Design decisions

| Decision | Reason |
| --- | --- |
| The widget never starts a package tool. | One behavior for each origin of a run. |
| No count command uses `sudo`. | A scheduled check has no password. |
| The command is POSIX shell. | It runs with a small dependency list on each distribution. |
| The two parts speak through files. | No service and no socket are necessary. |
| `nobara-sync` counts with DNF. | `nobara-sync check-updates` asks for the root password. |
| The conflict rule uses the first tool. | The result is predictable and the sequence of the table defines it. |
| A failed tool does not stop the run. | The other sources still receive their updates. |
| A failed run writes no state file. | The widget then shows the state "updates available". |
