import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_checkIntervalHours: intervalSpin.value
    property int cfg_checkIntervalHoursDefault: 6
    property alias cfg_notifyUpdates: notifyUpdatesBox.checked
    property bool cfg_notifyUpdatesDefault: true
    property alias cfg_notifyUpToDate: notifyUpToDateBox.checked
    property bool cfg_notifyUpToDateDefault: true

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
    }
}
