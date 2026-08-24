pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int total: -1
    property string breakdown: i18n("No check has run yet")
    property bool checking: false

    readonly property string iconName: checking ? "view-refresh-symbolic" : "update-none"
    readonly property color iconColor: !checking && total > 0 ? Kirigami.Theme.neutralTextColor
                                                              : Kirigami.Theme.textColor

    Plasmoid.icon: iconName
    Plasmoid.status: PlasmaCore.Types.ActiveStatus

    toolTipMainText: checking ? i18n("Checking for updates…")
                   : total < 0 ? i18n("Update Checker")
                   : total > 0 ? i18np("%1 update available", "%1 updates available", total)
                   : i18n("System is up to date")
    toolTipSubText: breakdown + "\n" + (total > 0 ? i18n("Click to update system")
                                                  : i18n("Click to check for updates"))

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            root.checking = false
            root.parseOutput(data.stdout || "")
        }
    }

    function parseOutput(out) {
        const lines = out.trim().split("\n")
        let sums = []
        let newTotal = -1
        for (const line of lines) {
            const m = line.match(/^(\w+):\s*(\d+)$/)
            if (!m) continue
            if (m[1] === "Total") {
                newTotal = parseInt(m[2])
            } else {
                sums.push(m[1] + " " + m[2])
            }
        }
        if (newTotal >= 0) {
            root.total = newTotal
            root.breakdown = sums.join(" · ")
        } else {
            root.breakdown = i18n("Check failed. Is update-all in ~/.local/bin?")
        }
    }

    function runCheck(alwaysNotify) {
        if (checking) return
        checking = true
        exec.connectSource("$HOME/.local/bin/update-all -l "
                           + (alwaysNotify ? "--notify-always" : "--notify"))
    }

    function runUpdateNow() {
        exec.connectSource("konsole -e sh -c \"$HOME/.local/bin/update-all; printf '\\nFinished. Press Enter to close.'; read line\"")
    }

    Timer {
        interval: Math.max(5, Plasmoid.configuration.checkIntervalMinutes) * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.runCheck(false)
    }

    // First check shortly after login/startup rather than waiting a full interval
    Timer {
        interval: 15 * 1000
        running: true
        repeat: false
        onTriggered: root.runCheck(false)
    }

    compactRepresentation: MouseArea {
        id: compact

        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onClicked: {
            if (root.total > 0) {
                root.runUpdateNow()
            } else {
                root.runCheck(true)
            }
        }

        Kirigami.Icon {
            anchors.fill: parent
            source: root.iconName
            color: root.iconColor
            isMask: true
            active: compact.containsMouse
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: Kirigami.Units.gridUnit * 8

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Kirigami.Units.iconSizes.large
                source: root.iconName
                color: root.iconColor
                isMask: true
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.toolTipMainText
                font.bold: true
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.breakdown
                opacity: 0.7
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Button {
                    text: i18n("Check now")
                    icon.name: "view-refresh"
                    enabled: !root.checking
                    onClicked: root.runCheck(true)
                }

                PlasmaComponents.Button {
                    text: i18n("Update system")
                    icon.name: "update-high"
                    onClicked: root.runUpdateNow()
                }
            }
        }
    }
}
