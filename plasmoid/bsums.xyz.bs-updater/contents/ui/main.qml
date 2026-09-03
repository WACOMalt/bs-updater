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

    readonly property string iconName: checking ? "view-refresh-symbolic"
                                     : total > 0 ? "update-none"
                                     : Qt.resolvedUrl("../icons/bs-updater-ok.svg")
    readonly property color iconColor: !checking && total > 0 ? Kirigami.Theme.neutralTextColor
                                                              : Kirigami.Theme.textColor

    Plasmoid.icon: iconName
    // Active when updates are available, passive when not. With the tray
    // entry set to "Shown when relevant", the icon then hides while the
    // system is up to date. "Always shown" shows it in both states.
    Plasmoid.status: total > 0 ? PlasmaCore.Types.ActiveStatus
                               : PlasmaCore.Types.PassiveStatus

    toolTipMainText: checking ? i18n("Checking for updates…")
                   : total < 0 ? i18n("Update Checker")
                   : total > 0 ? i18np("%1 update available", "%1 updates available", total)
                   : i18n("System is up to date")
    toolTipSubText: breakdown + "\n" + (total > 0 ? i18n("Click to update system")
                                                  : i18n("Click to check for updates"))

    // Path of the bs-update copy that ships inside this widget package.
    readonly property string bundledScript: Qt.resolvedUrl("../code/bs-update").toString().replace("file://", "")

    // One long-running shell process that exits when bs-update writes a new
    // timestamp to its state file after a completed update run. The widget
    // then changes to the up-to-date state at once, from any update origin:
    // the widget, the notification, or a manual terminal run.
    readonly property string updateWatcher:
        'F="${XDG_CACHE_HOME:-$HOME/.cache}/bs-updater/last-update"; ' +
        'T0=$(stat -c %Y "$F" 2>/dev/null || echo 0); ' +
        'while :; do sleep 3; T=$(stat -c %Y "$F" 2>/dev/null || echo 0); ' +
        '[ "$T" != "$T0" ] && exit 0; done'

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            if (sourceName === root.updateWatcher) {
                // An update run finished. Show the up-to-date state at
                // once, verify in the background, and watch again.
                root.total = 0
                root.runCheck(false)
                exec.connectSource(root.updateWatcher)
            } else if (sourceName.indexOf(" -l ") !== -1) {
                root.checking = false
                root.parseOutput(data.stdout || "")
            }
        }
    }

    // Install the bundled bs-update command if the user does not have it.
    // This makes a widget-only installation from the KDE Store work.
    function ensureCommandInstalled() {
        exec.connectSource(
            "BIN=\"$HOME/.local/bin/bs-update\"; " +
            "if [ ! -x \"$BIN\" ] && [ -r '" + bundledScript + "' ]; then " +
            "mkdir -p \"$HOME/.local/bin\"; " +
            "cp '" + bundledScript + "' \"$BIN\"; chmod 755 \"$BIN\"; " +
            "notify-send -a bs-updater -i update-none 'bs-updater' " +
            "'Installed the bs-update command to ~/.local/bin'; fi")
    }

    Component.onCompleted: {
        ensureCommandInstalled()
        exec.connectSource(updateWatcher)
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
            root.breakdown = i18n("Check failed. Is bs-update in ~/.local/bin?")
        }
    }

    // manual: the user started this check. Scheduled checks only notify
    // about available updates; manual checks can also confirm up-to-date.
    function runCheck(manual) {
        if (checking) return
        checking = true
        const notifyUpdates = Plasmoid.configuration.notifyUpdates
        const notifyClean = manual && Plasmoid.configuration.notifyUpToDate
        let flag = ""
        if (notifyUpdates && notifyClean) flag = "--notify-always"
        else if (notifyUpdates) flag = "--notify"
        else if (notifyClean) flag = "--notify-uptodate"
        exec.connectSource("$HOME/.local/bin/bs-update -l " + flag)
    }

    function runUpdateNow() {
        exec.connectSource("$HOME/.local/bin/bs-update --in-terminal")
    }

    Timer {
        interval: Math.max(1, Plasmoid.configuration.checkIntervalHours) * 60 * 60 * 1000
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
