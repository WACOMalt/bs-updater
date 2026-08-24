import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_checkIntervalMinutes: intervalSpin.value
    property int cfg_checkIntervalMinutesDefault: 60

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: i18n("Check for updates every:")
            from: 5
            to: 1440
            stepSize: 5
            textFromValue: (value) => i18np("%1 minute", "%1 minutes", value)
            valueFromText: (text) => parseInt(text)
        }
    }
}
