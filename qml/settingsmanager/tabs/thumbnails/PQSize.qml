import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "size"
    helptext: "How large the thumbnails should be."
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "20 px"
            }

            PQSlider {
                id: size_slider
                y: (parent.height-height)/2
                from: 20
                to: 256
                toolTipSuffix: " px"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "256 px"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailSize = size_slider.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        size_slider.value = PQSettings.thumbnailSize
    }

}
