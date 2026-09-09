# 10. Verification

## 10.1 The test suite

```
./tests/run-tests.sh
```

The suite tests the command `bs-update`. Version 1.10.0 has 60 tests. The
suite writes one line for each test and a summary at the end:

```
60 passed, 0 failed
```

The exit code is 0 if each test passes. The exit code is 1 if one test or
more than one test fails.

## 10.2 The method

The suite replaces each package tool with a stub. A stub is a small shell
script. It writes its own command line into a log file, and it writes the
output for the test.

The suite has stubs for these commands:

- `checkupdates`, `paru` and `pacman`;
- `dnf` and `nobara-sync`;
- `apt-get`;
- `flatpak`, which also answers for Gear Lever;
- `sudo` and `notify-send`.

Three properties follow from this method:

- The suite installs no package and changes no system.
- The suite runs on each machine, also on a machine without these tools.
- A test can examine the exact command line that `bs-update` uses.

The suite also replaces `HOME`, `XDG_CONFIG_HOME` and `XDG_CACHE_HOME` with
directories in a temporary directory. It removes that directory at the end.

## 10.3 The control of the stubs

The tests set environment variables to control the stubs.

| Variable | Function |
| --- | --- |
| `STUB_REPO_COUNT` | The number of repository updates. |
| `STUB_AUR_COUNT` | The number of AUR updates. |
| `STUB_RPM_COUNT` | The number of RPM updates. |
| `STUB_DEB_COUNT` | The number of Debian updates. |
| `STUB_FLATPAK_COUNT` | The number of Flatpak updates. |
| `STUB_APPIMAGE_COUNT` | The number of AppImage updates. |
| `STUB_PARU_RC` | The exit code of paru. |
| `STUB_DNF_RC` | The exit code of DNF. |
| `STUB_APT_RC` | The exit code of APT. |
| `STUB_DNF_TRICKY` | Makes DNF write a difficult report. |
| `STUB_APT_TRICKY` | Makes APT write a difficult simulation. |

The two last variables are important. `STUB_DNF_TRICKY` makes the stub write
a metadata line, an empty line, a package name that wraps onto a second
line, and the section `Obsoleting Packages`. `STUB_APT_TRICKY` makes the
stub write the note about the simulation, the progress lines, a list of
package names, a section for the packages that stay back, a summary line,
and one `Conf` line after each `Inst` line.

These two tests prove that the parsers of section 8.5 and section 8.6 count
the correct number.

## 10.4 The groups of tests

| Group | What the group proves |
| --- | --- |
| Defaults | Without a configuration file, the command uses the four default tools. |
| `--tools` | The option replaces the selection, with commas and with spaces. |
| Sanity checks | The command removes a second tool of one domain and reports it. |
| Configuration file | The command reads the file, and `--tools` replaces the file. |
| Fedora and Nobara | The RPM tools count with DNF and install with the correct command. |
| Debian and Ubuntu | APT counts with a simulation and installs after a refresh. |
| Notifications | The notification holds the count of each enabled source. |
| A failed tool | The run continues, gives the code 1 and writes no state file. |
| Help | The help text is available, and an unknown option fails. |

## 10.5 Examples of the assertions

The suite compares the log of the stubs with an expected text. Two examples:

The default update run must start paru one time:

```
paru -Syu
flatpak update
flatpak run it.mijorus.gearlever --update --all --yes
```

The APT update run must refresh the package lists first:

```
sudo apt-get update
apt-get update
sudo apt-get upgrade
apt-get upgrade
```

Each `sudo` line and the line after it are the same command. The stub for
`sudo` writes its own line and then starts the real command, which is also
a stub.

## 10.6 Manual verification

The test suite does not test the widget. QML has no test harness in this
project. Do these manual checks after a change to the widget:

1. Restart Plasma and add the widget to the system tray.
2. Wait 15 seconds. The widget must show a count.
3. Open the settings and clear one checkbox. The counts must change.
4. Examine `~/.config/bs-updater/tools.conf`. It must agree with the
   checkboxes.
5. Select two tools of one package domain. The page must show a warning.
6. Clear each checkbox. The page must show the second warning.
7. Start an update run from a terminal. The icon must change to the
   up-to-date state in less than 5 seconds.

## 10.7 When to run the tests

Run the test suite:

- after each change to `bin/bs-update`;
- after each change to the tables in `configSources.qml`;
- before each release.
