import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title referring to the spacing of thumbnails, i.e., how much empty space to have between each.
    title: em.pty+qsTranslate("settingsmanager", "spacing")
    helptext: em.pty+qsTranslate("settingsmanager", "How much space to show between the thumbnails.")
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
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailSpacingBetween = spacing_slider.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        spacing_slider.value = PQSettings.thumbnailSpacingBetween
    }

}
