import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. The 'hot edge' refers to the area along the edges of PhotoQt where the mouse cursor triggers an action (e.g., showing the thumbnails or the main menu)
    title: em.pty+qsTranslate("settingsmanager", "size of 'hot edge'")
    helptext: em.pty+qsTranslate("settingsmanager", "Adjusts the sensitivity of the edges for showing elements like the metadata and main menu elements.")
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            Text {
                y: (parent.height-height)/2
                color: "white"
                //: used as in 'small area'
                text: em.pty+qsTranslate("settingsmanager", "small")
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
                //: used as in 'large area'
                text: em.pty+qsTranslate("settingsmanager", "large")
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
