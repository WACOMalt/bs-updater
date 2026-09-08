import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Update sources"
        icon: "system-software-update"
        source: "configSources.qml"
    }
}
