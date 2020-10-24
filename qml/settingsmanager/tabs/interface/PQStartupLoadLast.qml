import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "remember last image")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "At startup the image loaded at the end of the last session can be automatically reloaded.")
    content: [
        PQCheckbox {
            id: start_load_last
            text: em.pty+qsTranslate("settingsmanager_interface", "re-open last loaded image at startup")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            start_load_last.checked = PQSettings.startupLoadLastLoadedImage
        }

        onSaveAllSettings: {
            PQSettings.startupLoadLastLoadedImage = start_load_last.checked
        }

    }

}
