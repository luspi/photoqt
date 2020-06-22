import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "size of 'hot edge'"
    helptext: "Adjusts the sensitivity of the edges for showing elements like the metadata and main menu elements."
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "small"
            }

            PQSlider {
                id: hotedge_slider
                y: (parent.height-height)/2
                from: 1
                to: 20
                stepSize: 1
                wheelStepSize: 1

            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "large"
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            hotedge_slider.value = PQSettings.hotEdgeWidth
        }

        onSaveAllSettings: {
            PQSettings.hotEdgeWidth = hotedge_slider.value
        }

    }

}
