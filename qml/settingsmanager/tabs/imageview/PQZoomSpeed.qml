import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title, the 'zoom' here is the zoom of the main image
    title: em.pty+qsTranslate("settingsmanager", "zoom speed")
    helptext: em.pty+qsTranslate("settingsmanager", "Images are zoomed at a relative speed as specified by this percentage. A higher value means faster zoom.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                //: This refers to the zoom speed, the zoom here is the zoom of the main image
                text: em.pty+qsTranslate("settingsmanager", "super slow")
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
                //: This refers to the zoom speed, the zoom here is the zoom of the main image
                text: em.pty+qsTranslate("settingsmanager", "very fast")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.zoomSpeed = zoomspeed.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        zoomspeed.value = PQSettings.zoomSpeed
    }

}
