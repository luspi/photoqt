import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "tray icon")
    helptext: em.pty+qsTranslate("settingsmanager", "If a tray icon is to be shown and, if shown, whether to hide it or not.")
    content: [
        PQComboBox {
            id: tray_combo
            model: [
                em.pty+qsTranslate("settingsmanager", "no tray icon"),
                em.pty+qsTranslate("settingsmanager", "hide to tray icon"),
                em.pty+qsTranslate("settingsmanager", "show tray icon but don't hide to it")
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
