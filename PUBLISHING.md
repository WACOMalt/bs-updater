# KDE Store publishing information

Use this file to keep the KDE Store listing consistent between releases.

## Product

- **Store page**: store.kde.org (log in with the OpenDesktop account)
- **Product name**: bs-updater
- **Category**: Plasma → Plasma 6 Applets
- **License**: The Unlicense (public domain)
- **Homepage / Source**: https://github.com/WACOMalt/bs-updater

## Description

Copy this text into the store description field:

> bs-updater shows the update status for an Arch Linux system in the system tray.
>
> The widget checks pacman, the AUR, Flatpak, and Gear Lever AppImages one time
> each hour. The icon is a white circle with a check mark when the system is up
> to date. The icon is an orange circle when updates are available. Click the
> notification to install all updates in a terminal window.
>
> The widget installs the `update-all` terminal command to `~/.local/bin` on
> first start. Requirements: Arch Linux, paru, pacman-contrib, Flatpak,
> Gear Lever, and a terminal application. Support for more distributions is
> planned.
>
> Source: https://github.com/WACOMalt/bs-updater

## Screenshots

- `dist/screenshot-uptodate.png`: the tray with the white circle-check icon
- `dist/screenshot-updates.png`: the tray with the orange update icon

Make new screenshots when the icons or states change.

## How to publish an update

1. Increase `Version` in `plasmoid/bsums.xyz.bs-updater/metadata.json`.
2. Build the package:

   ```
   ./make-plasmoid.sh
   ```

3. Open the product page on store.kde.org and go to the Files section.
4. Upload `dist/bs-updater-<version>.plasmoid`.
5. Update the description text if the behavior changed. Keep this file and the
   store text identical.
6. Commit and push the version change to GitHub.

Users receive the update through Discover and the Plasma widget browser.
