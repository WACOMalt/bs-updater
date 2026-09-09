import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property alias cfg_checkIntervalHours: intervalSpin.value
    property int cfg_checkIntervalHoursDefault: 6
    property alias cfg_notifyUpdates: notifyUpdatesBox.checked
    property bool cfg_notifyUpdatesDefault: true
    property alias cfg_notifyUpToDate: notifyUpToDateBox.checked
    property bool cfg_notifyUpToDateDefault: true
    property int cfg_interactionLevel: 0
    property int cfg_interactionLevelDefault: 0

    QQC2.ButtonGroup { id: levelGroup }

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: i18n("Check for updates every:")
            from: 1
            to: 24
            stepSize: 1
            textFromValue: (value) => i18np("%1 hour", "%1 hours", value)
            valueFromText: (text) => parseInt(text)
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: notifyUpdatesBox
            Kirigami.FormData.label: i18n("Show notifications:")
            text: i18n("When updates are available")
        }

        QQC2.CheckBox {
            id: notifyUpToDateBox
            text: i18n("When a manual check finds no updates")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.RadioButton {
            QQC2.ButtonGroup.group: levelGroup
            Kirigami.FormData.label: i18n("When you start an update:")
            text: i18n("Show a terminal, and ask before each source installs")
            checked: root.cfg_interactionLevel === 0
            onClicked: root.cfg_interactionLevel = 0
        }

        QQC2.RadioButton {
            QQC2.ButtonGroup.group: levelGroup
            text: i18n("Show a terminal, and install without a question")
            checked: root.cfg_interactionLevel === 1
            onClicked: root.cfg_interactionLevel = 1
        }

        QQC2.RadioButton {
            QQC2.ButtonGroup.group: levelGroup
            text: i18n("Install in the background, without a question")
            checked: root.cfg_interactionLevel === 2
            onClicked: root.cfg_interactionLevel = 2
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            opacity: 0.7
            text: i18n("A background run reports the result in a notification. A source that needs the root password asks for it in a window, because there is no terminal to ask in. nobara-sync has no option to install without a question, so it asks at each of these settings.")
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: root.cfg_interactionLevel > 0
            type: Kirigami.MessageType.Information
            text: i18n("A source that installs without a question also answers for you when an update replaces or removes a package. Read the result if an update matters to you.")
        }
    }
}
