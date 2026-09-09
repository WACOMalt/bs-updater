# 11. The release procedure

## 11.1 The version number

The version is in one place:

```
plasmoid/bsums.xyz.bs-updater/metadata.json
```

The key is `KPlugin.Version`. The current value is `1.10.0`. The script
`make-plasmoid.sh` reads that key and puts the version into the name of the
package file.

## 11.2 The widget metadata

| Key | Value |
| --- | --- |
| `KPackageStructure` | `Plasma/Applet` |
| `KPlugin.Id` | `bsums.xyz.bs-updater` |
| `KPlugin.Name` | `bs-updater` |
| `KPlugin.Category` | `System Information` |
| `KPlugin.License` | `Unlicense` |
| `X-Plasma-API-Minimum-Version` | `6.0` |
| `X-Plasma-NotificationArea` | `true` |
| `X-Plasma-NotificationAreaCategory` | `SystemServices` |

The two last keys make the widget available in the system tray.

## 11.3 Procedure: how to build the package

1. Increase `KPlugin.Version` in `metadata.json`.
2. Start the package script.

   ```
   ./make-plasmoid.sh
   ```

3. Find the result in `dist/bs-updater-<version>.plasmoid`.

The script does these steps:

1. It reads the version from `metadata.json`.
2. It removes the directory `contents/code`.
3. It copies `bin/bs-update` into `contents/code` with the mode 755.
4. It makes a ZIP archive with `metadata.json` at the root.

The KDE Store must have `metadata.json` at the root of the archive.

## 11.4 Procedure: how to publish a new version

1. Run the test suite. Each test must pass.
2. Do the manual checks of section 10.6.
3. Increase the version in `metadata.json`.
4. Build the package with `./make-plasmoid.sh`.
5. Open the product page on the KDE Store and go to the section for the
   files.
6. Upload the new package file.
7. Change the description if the behavior changed.
8. Commit the version change and push it to the repository.
9. Update this wiki if the behavior changed.

Users receive the new version through Discover and through the widget
browser of Plasma.

## 11.5 The text of the store page

The file `PUBLISHING.md` in the repository holds the text of the store
page. The two texts must stay identical.

| Item | Value |
| --- | --- |
| Product name | bs-updater |
| Category | Plasma, Plasma 6 Applets |
| License | The Unlicense, public domain |

**CAUTION: The description on the store page is from an earlier version. It
names only the Arch tools. Correct it at the next release, because the
product now also supports Fedora, Nobara, Debian and Ubuntu.**

## 11.6 The logo

| File | Function |
| --- | --- |
| `logo/logo.svg` | The source file. |
| `logo/logo.png` | The image with 512 by 512 pixels for the store. |

Make a new image after a change to the source file:

```
rsvg-convert -w 512 -h 512 logo/logo.svg -o logo/logo.png
```

## 11.7 The screenshots

| File | Content |
| --- | --- |
| `screenshots/screenshot-uptodate.png` | The tray in the up-to-date state. |
| `screenshots/screenshot-updates.png` | The tray in the state "updates available". |

The other icons in the tray have a blur. The blur puts the attention on the
bs-updater icon. It also hides the applications of the person who makes the
screenshot. Make new screenshots after a change to the icons or to the
states, and apply the same blur.

## 11.8 The license

The product is in the public domain under The Unlicense. You can use it for
any purpose. The file `LICENSE` in the repository holds the full text.
