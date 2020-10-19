import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title, as in 'how many threads to use to generate thumbnails'.
    title: em.pty+qsTranslate("settingsmanager", "threads")
    helptext: em.pty+qsTranslate("settingsmanager", "How many threads to use to create thumbnails. Too many threads can slow down your computer!")
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
                toolTipPrefix: em.pty+qsTranslate("settingsmanager", "Threads:") + " "
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
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailMaxNumberThreads = thrds.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thrds.value = PQSettings.thumbnailMaxNumberThreads
    }

}
