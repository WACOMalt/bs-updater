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
    property alias cfg_toolFlatpak: flatpakBox.checked
    property bool cfg_toolFlatpakDefault: true
    property alias cfg_toolGearLever: gearLeverBox.checked
    property bool cfg_toolGearLeverDefault: true

    // Every tool bs-update can drive, in the order it runs them. paru
    // appears twice because it updates two kinds of package. bin/bs-update
    // carries the same table.
    readonly property var sources: [
        { box: pacmanBox,    covers: "repo",     name: i18n("pacman") },
        { box: paruRepoBox,  covers: "repo",     name: i18n("paru") },
        { box: paruAurBox,   covers: "aur",      name: i18n("paru") },
        { box: flatpakBox,   covers: "flatpak",  name: i18n("flatpak") },
        { box: gearLeverBox, covers: "appimage", name: i18n("Gear Lever") }
    ]

    readonly property var coverNames: ({
        "repo": i18n("repository packages"),
        "aur": i18n("AUR packages"),
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
        if (clashes.length > 0) {
            return clashes.join("\n")
        }
        if (checked === 0) {
            return i18n("No update source is selected. bs-updater does not check or update anything.")
        }
        return ""
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            text: root.warning
            visible: root.warning.length > 0
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.CheckBox {
                id: pacmanBox
                Kirigami.FormData.label: i18n("Repository packages:")
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
                id: flatpakBox
                Kirigami.FormData.label: i18n("Flatpak applications and runtimes:")
                text: i18n("flatpak")
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
            wrapMode: Text.Wrap
            opacity: 0.7
            text: i18n("An unchecked source is neither checked for updates nor updated. The tool of a checked source has to be installed.")
        }
    }
}
