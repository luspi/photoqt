import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "thumbnail cache")
    helptext: em.pty+qsTranslate("settingsmanager", "Thumbnails can be cached (permanently), following the freedesktop.org standard.")
    expertmodeonly: true
    content: [
        PQCheckbox {
            id: thb_cache
            text: em.pty+qsTranslate("settingsmanager", "enable")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailCache = thb_cache.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_cache.checked = PQSettings.thumbnailCache
    }

}
