import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Lift up"
    helptext: "How many pixels to lift up thumbnails when either hovered or active."
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "0 px"
            }

            PQSlider {
                id: liftup
                y: (parent.height-height)/2
                from: 0
                to: 100
                toolTipSuffix: " px"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "100 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            liftup.value = PQSettings.thumbnailLiftUp
        }

        onSaveAllSettings: {
            PQSettings.thumbnailLiftUp = liftup.value
        }

    }

}
