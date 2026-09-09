# 9. Distribution notes

## 9.1 Summary

| Distribution | Tools to select | Tools to clear |
| --- | --- | --- |
| Arch Linux | paru, paru AUR, flatpak, Gear Lever | pacman, dnf, nobara-sync, apt |
| Fedora | dnf, flatpak, Gear Lever | the Arch tools, nobara-sync, apt |
| Nobara | nobara-sync, flatpak, Gear Lever | the Arch tools, dnf, apt |
| Debian, Ubuntu | apt, flatpak, Gear Lever | the Arch tools, dnf, nobara-sync |

The defaults suit Arch Linux. A user of another distribution changes the
selection one time after the installation.

## 9.2 Arch Linux

The default selection is correct.

| Function | Command |
| --- | --- |
| The count of the repository updates | `checkupdates` |
| The count of the AUR updates | `paru -Qua` |
| The installation of both kinds | `paru -Syu` |

`checkupdates` comes from the package pacman-contrib. It downloads the
package lists into a temporary directory, so it does not use root
privileges and it does not change the state of the system.

You can select `pacman` in place of `paru`. Clear the paru checkbox for the
repository packages first, because the two tools have the same package
domain. `pacman` then runs as `sudo pacman -Syu`.

## 9.3 Fedora

Select `dnf` and clear the Arch tools.

| Function | Command |
| --- | --- |
| The count | `dnf -q check-update` |
| The installation | `sudo dnf upgrade` |

The count command does not use root privileges. DNF 4 and DNF 5 both give the
correct count. Section 8.5 describes the parser.

## 9.4 Nobara

Select `nobara-sync` and clear the Arch tools. Also clear `dnf`, because
`dnf` and `nobara-sync` have the same package domain.

| Function | Command |
| --- | --- |
| The count | `dnf -q check-update` |
| The installation | `nobara-sync cli` |

Three properties are specific to Nobara:

- `nobara-sync cli` installs the system updates and also applies the Nobara
  fixups.
- `nobara-sync` raises its own privileges with `sudo` or with `pkexec`.
  `bs-update` does not add `sudo` to it.
- The count uses DNF and not `nobara-sync check-updates`. The command
  `nobara-sync check-updates` asks for the root password. A scheduled check
  cannot answer that question.

`nobara-sync cli` leaves the Flatpaks alone without the option `--all`. Do
not clear the checkbox `flatpak`. bs-updater then counts the Flatpak updates
and installs them.

## 9.5 Debian and Ubuntu

Select `apt` and clear the Arch tools. This selection also suits each
distribution that uses APT, for example Linux Mint and Pop!_OS.

| Function | Command |
| --- | --- |
| The count | `apt-get -q -s upgrade` |
| The installation | `sudo apt-get update && sudo apt-get upgrade` |

Section 8.6 describes the two effects of this design: the age of the count,
and the packages that stay back.

## 9.6 All distributions

Flatpak and Gear Lever are independent of the distribution. Do not clear the two
checkboxes if you use these two systems.

| Function | Command |
| --- | --- |
| The count of the Flatpak updates | `flatpak remote-ls --updates` |
| The installation of the Flatpak updates | `flatpak update` |
| The count of the AppImage updates | `gearlever --list-updates` |
| The installation of the AppImage updates | `gearlever --update --all --yes` |

Section 8.7 gives the full Gear Lever command.

## 9.7 A system with more than one package manager

`pacman`, `dnf` and `apt` are in three different package domains. bs-updater
does not report a conflict between them, and it counts each of them
separately. A normal system has one of these three tools.
