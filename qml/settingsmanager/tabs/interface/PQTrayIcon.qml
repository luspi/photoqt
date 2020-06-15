import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Tray Icon"
    helptext: ""
    content: [
        PQComboBox {
            id: tray_combo
            model: [
                "No tray icon",
                "Hide to tray icon",
                "Show tray icon but don't hide to it"
            ]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            tray_combo.currentIndex = PQSettings.trayIcon
        }

        onSaveAllSettings: {
            PQSettings.trayIcon = tray_combo.currentIndex
        }

    }

}
