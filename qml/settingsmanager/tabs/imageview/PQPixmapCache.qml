import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "pixmap cache"
    helptext: "Size of runtime cache for fully loaded images. This cache is cleared when the application quits."
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "off"
            }

            PQSlider {
                id: pixcache
                y: (parent.height-height)/2
                from: 0
                to: 1024
                toolTipSuffix: " MB"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "1 GB"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            pixcache.value = PQSettings.pixmapCache
        }

        onSaveAllSettings: {
            PQSettings.pixmapCache = pixcache.value
        }

    }

}
