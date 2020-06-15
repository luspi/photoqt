import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Spacing"
    helptext: "How much space to show between the thumbnails."
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "0 px"
            }

            PQSlider {
                id: spacing_slider
                y: (parent.height-height)/2
                from: 0
                to: 50
                toolTipSuffix: " px"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "50 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            spacing_slider.value = PQSettings.thumbnailSpacingBetween
        }

        onSaveAllSettings: {
            PQSettings.thumbnailSpacingBetween = spacing_slider.value
        }

    }

}
