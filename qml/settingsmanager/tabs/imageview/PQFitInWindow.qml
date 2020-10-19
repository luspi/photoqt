import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title referring to whether to fit images in window
    title: em.pty+qsTranslate("settingsmanager", "fit in window")
    helptext: em.pty+qsTranslate("settingsmanager", "Zoom smaller images to fill the full window width and/or height.")
    content: [

        PQCheckbox {
            id: fitinwin
            text: em.pty+qsTranslate("settingsmanager", "fit smaller images in window")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.fitInWindow = fitinwin.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        fitinwin.checked = PQSettings.fitInWindow
    }

}
