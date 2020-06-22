import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "zoom speed"
    helptext: "Images are zoomed at a relative speed as specified by this percentage. A higher value means faster zoom."
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "super slow"
            }

            PQSlider {
                id: zoomspeed
                y: (parent.height-height)/2
                from: 1
                to: 100
                toolTipSuffix: " %"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "very fast"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            zoomspeed.value = PQSettings.zoomSpeed
        }

        onSaveAllSettings: {
            PQSettings.zoomSpeed = zoomspeed.value
        }

    }

}
