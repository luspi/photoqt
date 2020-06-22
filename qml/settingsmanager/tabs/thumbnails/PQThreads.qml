import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "threads"
    helptext: "How many threads to use to create thumbnails. Too many threads can slow down your computer!"
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "1"
            }

            PQSlider {
                id: thrds
                y: (parent.height-height)/2
                from: 1
                to: 8
                toolTipSuffix: " threads"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "8"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            thrds.value = PQSettings.thumbnailMaxNumberThreads
        }

        onSaveAllSettings: {
            PQSettings.thumbnailMaxNumberThreads = thrds.value
        }

    }

}
