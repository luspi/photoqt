import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Looping"
    helptext: "What to do when the end of a folder has been reacher: stop or loop back to first image in folder."
    content: [

        PQCheckbox {
            id: loop_check
            text: "Loop through images in folder"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            loop_check.checked = PQSettings.loopThroughFolder
        }

        onSaveAllSettings: {
            PQSettings.loopThroughFolder = loop_check.checked
        }

    }

}
