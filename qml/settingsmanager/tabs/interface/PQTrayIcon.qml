import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "tray icon"
    helptext: "If a tray icon is to be shown, and, if shown, whether to hide to it or not."
    content: [
        PQComboBox {
            id: tray_combo
            model: [
                "no tray icon",
                "hide to tray icon",
                "show tray icon but don't hide to it"
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
