import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Remember per session"
    helptext: "By default, PhotoQt resets the zoom, rotation, flipping/mirroring and position when switching to a different image. For certain tasks, for example for comparing two images, it can be helpful to keep these properties."
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: remember
            text: "Remember zoom, rotation, flip, position"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            remember.checked = PQSettings.keepZoomRotationMirror
        }

        onSaveAllSettings: {
            PQSettings.keepZoomRotationMirror = remember.checked
        }

    }

}
