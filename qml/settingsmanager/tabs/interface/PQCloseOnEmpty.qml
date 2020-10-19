import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_interface", "empty area around image")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "How to handle clicks on empty area around images.")
    content: [
        PQCheckbox {
            id: closecheck
            //: Used as in: Close PhotoQt on click on empty area around main image
            text: em.pty+qsTranslate("settingsmanager_interface", "close on click")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            closecheck.checked = PQSettings.closeOnEmptyBackground
        }

        onSaveAllSettings: {
            PQSettings.closeOnEmptyBackground = closecheck.checked
        }

    }

}
