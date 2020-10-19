import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager", "remember per session")
    helptext: em.pty+qsTranslate("settingsmanager", "By default, PhotoQt resets the zoom, rotation, flipping/mirroring and position when switching to a different image. For certain tasks, for example for comparing two images, it can be helpful to keep these properties.")
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: remember
            text: em.pty+qsTranslate("settingsmanager", "remember zoom, rotation, flip, position")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.keepZoomRotationMirror = remember.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        remember.checked = PQSettings.keepZoomRotationMirror
    }

}
