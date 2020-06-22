import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "left mouse button"
    helptext: "The left button of the mouse is by default used to move the image around. However, this prevents the left mouse button from being used for shortcuts."
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: left_check
            text: "use left button to move image"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            left_check.checked = PQSettings.leftButtonMouseClickAndMove
        }

        onSaveAllSettings: {
            PQSettings.leftButtonMouseClickAndMove = left_check.checked
        }

    }

}
