# 1. Introduction and scope

## 1.1 Purpose of the product

A Linux system holds software from more than one source. A package manager
holds the system packages. Flatpak holds the applications that come from a
Flatpak remote. Gear Lever holds the AppImages. Each source has its own
command, and each command has its own options.

bs-updater removes this work from the user. One command updates all of the
selected sources in sequence. One tray widget shows how many updates are
available.

## 1.2 Purpose of this paper

This paper describes bs-updater in full. It gives:

- the function of each part of the product;
- the interface between the parts;
- the procedures that install, configure and operate the product;
- the design decisions and the reasons for them;
- the method that tests the product.

## 1.3 Product data

| Item | Value |
| --- | --- |
| Product name | bs-updater |
| Product version | 1.10.0 |
| Widget identifier | `bsums.xyz.bs-updater` |
| Command name | `bs-update` |
| Widget language | QML |
| Command language | POSIX shell |
| License | The Unlicense, public domain |

## 1.4 Scope

This paper applies to bs-updater version 1.10.0. It includes:

- the `bs-update` command;
- the KDE Plasma tray widget;
- the installation script;
- the package script for the KDE Store;
- the test suite.

## 1.5 Exclusions

This paper does not include:

- the internal operation of pacman, paru, DNF, nobara-sync, APT, Flatpak or
  Gear Lever;
- the installation of these tools;
- the administration of a Linux system;
- desktop environments other than KDE Plasma.

## 1.6 Functions of the product

bs-updater does these tasks:

1. It counts the available updates for each selected source.
2. It adds the counts and shows the total.
3. It installs the updates of each selected source in sequence.
4. It shows the update state in the KDE Plasma system tray.
5. It sends a notification when updates are available.
6. It rejects a selection that counts the same packages two times.

## 1.7 Limits of the product

bs-updater does not do these tasks:

- It does not build packages.
- It does not add or remove a repository.
- It does not remove a package.
- It does not hold updates back for a later time.
- It does not download updates before the user starts an update run.
- It does not run as a system service, and it does not run as root.

## 1.8 Users of the product

This paper is for two groups:

- **Users.** A user installs bs-updater on one workstation, selects the
  update sources and operates the widget.
- **Maintainers.** A maintainer changes the source code, runs the tests and
  publishes a new version.

## 1.9 Prerequisites

The product must have these items:

- Arch Linux, Fedora, Nobara, Debian or Ubuntu;
- KDE Plasma 6;
- libnotify, which supplies the `notify-send` command;
- a terminal application;
- the tool of each update source that the user selects.

Chapter 4 gives the full list of the tools. Chapter 9 gives the tools for
each distribution.
