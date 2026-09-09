# 7. Command reference

## 7.1 Synopsis

```
bs-update [--tools LIST]
bs-update -l | --list [--notify | --notify-always | --notify-uptodate] [--tools LIST]
bs-update --list-tools [--tools LIST]
bs-update --in-terminal [--tools LIST]
bs-update -h | --help
```

## 7.2 Description

`bs-update` counts and installs the updates of the enabled sources. Without
an option, it installs the updates of each enabled tool in sequence.

## 7.3 The options

| Option | Function |
| --- | --- |
| none | Installs the updates of each enabled tool. |
| `-l`, `--list` | Counts the available updates. Installs nothing. |
| `--list-tools` | Shows each supported tool and its state. |
| `--in-terminal` | Opens a terminal window and runs `bs-update` in it. |
| `--tools LIST` | Uses this list of tools for one run. |
| `--tools=LIST` | The same, with an equals sign. |
| `--notify` | Sends a notification if updates are available. |
| `--notify-always` | Also sends a notification if the system is up to date. |
| `--notify-uptodate` | Sends a notification only if the system is up to date. |
| `-h`, `--help` | Shows the help text. |

The three notify options apply only with `-l`. The command uses the last
notify option on the command line.

`LIST` is a list of tool identifiers with commas or with spaces. Section 2.5
gives the identifiers.

## 7.4 The output of the list mode

The list mode writes one line for each enabled tool, and then the total:

```
$ bs-update -l
Pacman: 3
AUR: 2
Flatpak: 4
AppImage: 1
Total: 10
```

The heading of each line is the heading of the package domain of the tool.
Section 3.1 gives the six headings. The widget reads this output with the
pattern `^(\w+):\s*(\d+)$`.

A count that is not a number becomes zero. The total is always a number.

## 7.5 The output of the tool list mode

```
$ bs-update --list-tools
pacman       off pacman: repository packages
paru-repo    on  paru (repository packages): repository packages
paru-aur     on  paru (AUR packages): AUR packages
dnf          off DNF: RPM packages
nobara-sync  off nobara-sync: RPM packages
apt          off APT: Debian packages
flatpak      on  Flatpak: Flatpak applications and runtimes
gearlever    on  Gear Lever: AppImages
```

The columns are the identifier, the state, the name of the tool and the
package domain.

## 7.6 The messages on the error output

| Message | Cause |
| --- | --- |
| `unknown tool '<id>' - ignored` | The list holds a name that this version does not know. |
| `<a> and <b> both update <domain>; using <a>` | Two tools have the same package domain. |
| `no update tools are enabled; nothing to update` | The update mode has an empty selection. |
| `no update tools are enabled; nothing was checked` | The list mode has an empty selection. |
| `--tools needs a list of tools` | The option `--tools` has no argument. |
| The help text | The command line holds an unknown option. |

## 7.7 The exit codes

| Code | Condition |
| --- | --- |
| 0 | The run was successful. |
| 1 | One tool or more than one tool failed in the update mode. |
| 1 | The update mode has no enabled tool. |
| 1 | The command line holds an unknown option. |
| 1 | The option `--tools` has no argument. |

The list mode gives the code 0, also with an empty selection. An empty
selection is a configuration condition, not a failure of the count.

A failed tool does not stop the run. `bs-update` runs each subsequent tool
and then gives the code 1. A run with the code 1 does not write the state
file.

## 7.8 Examples

Count the updates of all enabled sources:

```
bs-update -l
```

Count only the Flatpak updates:

```
bs-update --tools flatpak -l
```

Install the Flatpak updates and the AppImage updates:

```
bs-update --tools flatpak,gearlever
```

Count the updates and send a notification, as the widget does:

```
bs-update -l --notify
```

Open a terminal window and install all updates in it:

```
bs-update --in-terminal
```

## 7.9 The environment variables

| Variable | Function | Default |
| --- | --- | --- |
| `XDG_CONFIG_HOME` | The parent of the configuration directory. | `~/.config` |
| `XDG_CACHE_HOME` | The parent of the state directory. | `~/.cache` |
| `TERMINAL` | The terminal application. | The KDE default, then Konsole. |
| `PATH` | Must hold `~/.local/bin`. | — |
