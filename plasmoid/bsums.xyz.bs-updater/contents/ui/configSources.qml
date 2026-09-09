import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property alias cfg_toolPacman: pacmanBox.checked
    property bool cfg_toolPacmanDefault: false
    property alias cfg_toolParuRepo: paruRepoBox.checked
    property bool cfg_toolParuRepoDefault: true
    property alias cfg_toolParuAur: paruAurBox.checked
    property bool cfg_toolParuAurDefault: true
    property alias cfg_toolDnf: dnfBox.checked
    property bool cfg_toolDnfDefault: false
    property alias cfg_toolNobaraSync: nobaraSyncBox.checked
    property bool cfg_toolNobaraSyncDefault: false
    property alias cfg_toolNobaraSyncFlatpak: nobaraSyncFlatpakBox.checked
    property bool cfg_toolNobaraSyncFlatpakDefault: false
    property alias cfg_toolApt: aptBox.checked
    property bool cfg_toolAptDefault: false
    property alias cfg_toolFlatpak: flatpakBox.checked
    property bool cfg_toolFlatpakDefault: true
    property alias cfg_toolGearLever: gearLeverBox.checked
    property bool cfg_toolGearLeverDefault: true

    // Every tool bs-update can drive, in the order it runs them. paru and
    // nobara-sync each appear twice because they update two kinds of
    // package. bin/bs-update carries the same table, in the same order.
    readonly property var sources: [
        { box: pacmanBox,      covers: "repo",     name: i18n("pacman") },
        { box: paruRepoBox,    covers: "repo",     name: i18n("paru") },
        { box: paruAurBox,     covers: "aur",      name: i18n("paru") },
        { box: dnfBox,         covers: "rpm",      name: i18n("dnf") },
        { box: nobaraSyncBox,  covers: "rpm",      name: i18n("nobara-sync") },
        { box: nobaraSyncFlatpakBox, covers: "flatpak", name: i18n("nobara-sync") },
        { box: aptBox,         covers: "deb",      name: i18n("apt") },
        { box: flatpakBox,     covers: "flatpak",  name: i18n("flatpak") },
        { box: gearLeverBox,   covers: "appimage", name: i18n("Gear Lever") }
    ]

    readonly property var coverNames: ({
        "repo": i18n("repository packages"),
        "aur": i18n("AUR packages"),
        "rpm": i18n("RPM packages"),
        "deb": i18n("Debian packages"),
        "flatpak": i18n("Flatpak applications and runtimes"),
        "appimage": i18n("AppImages")
    })

    // Two checked tools that cover the same kind of package would install
    // the same updates twice and count them twice, so warn about it here.
    // bs-update runs only the first of them if it happens anyway.
    readonly property string warning: {
        let owner = ({})
        let clashes = []
        let checked = 0
        for (const source of sources) {
            if (!source.box.checked) {
                continue
            }
            checked += 1
            if (owner[source.covers] !== undefined) {
                clashes.push(i18n("%1 and %2 both update %3. Turn one of them off.",
                                  owner[source.covers], source.name,
                                  coverNames[source.covers]))
            } else {
                owner[source.covers] = source.name
            }
        }
        // nobara-sync updates Flatpak applications only together with the
        // RPM packages. It has no Flatpak-only mode.
        if (nobaraSyncFlatpakBox.checked && !nobaraSyncBox.checked) {
            clashes.push(i18n("nobara-sync updates Flatpak applications only together with the RPM packages. Check nobara-sync under RPM packages as well, or use flatpak."))
        }
        if (clashes.length > 0) {
            return clashes.join("\n")
        }
        if (checked === 0) {
            return i18n("No update source is selected. bs-updater does not check or update anything.")
        }
        return ""
    }

    ColumnLayout {
        // The page does not bind the width of its content, so wrapping text
        // has to be held to the width of the page itself. Without this the
        // text keeps its one-line width and runs past the right edge.
        width: root.width
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - Kirigami.Units.gridUnit
            type: Kirigami.MessageType.Warning
            text: root.warning
            visible: root.warning.length > 0
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.CheckBox {
                id: pacmanBox
                Kirigami.FormData.label: i18n("Repository packages (Arch):")
                text: i18n("pacman")
            }

            QQC2.CheckBox {
                id: paruRepoBox
                text: i18n("paru")
            }

            Item { Kirigami.FormData.isSection: true }

            QQC2.CheckBox {
                id: paruAurBox
                Kirigami.FormData.label: i18n("AUR packages:")
                text: i18n("paru")
            }

            Item { Kirigami.FormData.isSection: true }

            QQC2.CheckBox {
                id: dnfBox
                Kirigami.FormData.label: i18n("RPM packages (Fedora):")
                text: i18n("dnf")
            }

            QQC2.CheckBox {
                id: nobaraSyncBox
                text: i18n("nobara-sync (Nobara: also applies the Nobara fixups)")
            }

            Item { Kirigami.FormData.isSection: true }

            QQC2.CheckBox {
                id: aptBox
                Kirigami.FormData.label: i18n("Debian packages (Debian, Ubuntu):")
                text: i18n("apt")
            }

            Item { Kirigami.FormData.isSection: true }

            QQC2.CheckBox {
                id: flatpakBox
                Kirigami.FormData.label: i18n("Flatpak applications and runtimes:")
                text: i18n("flatpak")
            }

            QQC2.CheckBox {
                id: nobaraSyncFlatpakBox
                text: i18n("nobara-sync (Nobara: needs its RPM entry)")
            }

            Item { Kirigami.FormData.isSection: true }

            QQC2.CheckBox {
                id: gearLeverBox
                Kirigami.FormData.label: i18n("AppImages:")
                text: i18n("Gear Lever")
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: root.width - Kirigami.Units.gridUnit
            wrapMode: Text.Wrap
            opacity: 0.7
            text: i18n("An unchecked source is neither checked for updates nor updated. The tool of a checked source has to be installed. The defaults suit Arch: on Fedora check dnf, on Nobara check nobara-sync, on Debian or Ubuntu check apt, and uncheck the Arch sources.")
        }
    }
}
