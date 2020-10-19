import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager", "pixmap cache")
    helptext: em.pty+qsTranslate("settingsmanager", "Size of runtime cache for fully loaded images. This cache is cleared when the application quits.")
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                //: 'off' as in 'pixmap cache turned off'
                text: em.pty+qsTranslate("settingsmanager", "off")
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
            load()
        }

        onSaveAllSettings: {
            PQSettings.pixmapCache = pixcache.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        pixcache.value = PQSettings.pixmapCache
    }

}
