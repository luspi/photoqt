import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "looping"
    helptext: "What to do when the end of a folder has been reacher: stop or loop back to first image in folder."
    content: [

        PQCheckbox {
            id: loop_check
            text: "loop through images in folder"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.loopThroughFolder = loop_check.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        loop_check.checked = PQSettings.loopThroughFolder
    }

}
