# 3. Update sources

## 3.1 The package domain

A package domain is one kind of package. Two tools in the same domain
install the same updates. Two tools in different domains never install the
same update.

bs-updater has six package domains.

| Domain | Heading in the list output | Name for the user |
| --- | --- | --- |
| `repo` | `Pacman` | repository packages |
| `aur` | `AUR` | AUR packages |
| `rpm` | `RPM` | RPM packages |
| `deb` | `APT` | Debian packages |
| `flatpak` | `Flatpak` | Flatpak applications and runtimes |
| `appimage` | `AppImage` | AppImages |

## 3.2 The tools and their domains

| Source | Tool | Domain | Distribution | Default state |
| --- | --- | --- | --- | --- |
| Repository packages | `pacman` | repo | Arch Linux | off |
| Repository packages | `paru` | repo | Arch Linux | on |
| AUR packages | `paru` | aur | Arch Linux | on |
| RPM packages | `dnf` | rpm | Fedora | off |
| RPM packages and the Nobara fixups | `nobara-sync` | rpm | Nobara | off |
| Debian packages | `apt` | deb | Debian, Ubuntu | off |
| Flatpak applications and runtimes | `flatpak` | flatpak | all | on |
| AppImages | Gear Lever | appimage | all | on |

paru is in the table two times. paru updates two kinds of package, and the
user can select one kind without the other.

## 3.3 The conflict rule

Two enabled tools in one domain would install the same updates two times and
count them two times. bs-updater prevents this at two places:

1. **In the settings page.** The page shows a warning when two selected
   tools have the same domain. The page also shows a warning when no tool is
   selected.
2. **In the command.** `resolve_tools` holds the first tool of a domain and
   removes each subsequent tool of that domain. It sends a message to the
   error output for each removal.

The message has this form:

```
bs-update: pacman and paru (repository packages) both update repository packages; using pacman
```

The sequence in the tool table gives the priority. `pacman` is before
`paru-repo`, so a selection of both tools uses `pacman`.

## 3.4 The two pairs that can conflict

| Domain | Tools | Reason |
| --- | --- | --- |
| repo | `pacman` and `paru-repo` | paru updates repository packages already. |
| rpm | `dnf` and `nobara-sync` | nobara-sync installs its RPM updates with DNF. |

`pacman`, `dnf` and `apt` are in three different domains, so they do not
conflict. A system has one of these three tools.

## 3.5 The default selection

The defaults suit Arch Linux. Without a configuration file, `bs-update`
enables these four tools:

```
paru-repo paru-aur flatpak gearlever
```

`pacman` is off by default, because `paru-repo` covers the same domain. On
another distribution, the user selects the correct tool in the settings
page. Chapter 9 gives the selection for each distribution.

## 3.6 The count command of each tool

Each count command runs without root privileges.

| Tool | Count command | Method |
| --- | --- | --- |
| `pacman`, `paru-repo` | `checkupdates` | Counts the output lines. |
| `paru-aur` | `paru -Qua` | Counts the output lines. |
| `dnf`, `nobara-sync` | `dnf -q check-update` | Counts the package lines. |
| `apt` | `apt-get -q -s upgrade` | Counts the `Inst` lines. |
| `flatpak` | `flatpak remote-ls --updates` | Counts the output lines. |
| `gearlever` | `gearlever --list-updates` | Counts the output lines. |

The command ignores the exit code of each count command. `dnf check-update`
gives the exit code 100 when updates are available, and `checkupdates` gives
a non-zero exit code when no updates are available. A count of zero is the
correct result in each of these conditions.

## 3.7 The update command of each tool

| Tool | Update command |
| --- | --- |
| `pacman` | `sudo pacman -Syu` |
| `paru-repo` | `paru -Syu --repo` |
| `paru-aur` | `paru -Sua` |
| `paru-repo` and `paru-aur` together | `paru -Syu` |
| `dnf` | `sudo dnf upgrade` |
| `nobara-sync` | `nobara-sync cli` |
| `apt` | `sudo apt-get update && sudo apt-get upgrade` |
| `flatpak` | `flatpak update` |
| `gearlever` | `gearlever --update --all --yes` |

When the user enables both paru entries, `bs-update` runs `paru -Syu` one
time. paru updates the repository packages and the AUR packages in one
transaction, so two runs are not necessary.
