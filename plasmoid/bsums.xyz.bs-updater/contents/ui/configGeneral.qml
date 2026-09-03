import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_checkIntervalHours: intervalSpin.value
    property int cfg_checkIntervalHoursDefault: 6

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
    }
}
