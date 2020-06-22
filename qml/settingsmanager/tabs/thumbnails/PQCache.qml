import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "thumbnail cache"
    helptext: "Thumbnails can be cached (permanently), following the freedesktop.org standard."
    expertmodeonly: true
    content: [
        PQCheckbox {
            id: thb_cache
            text: "enable"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            thb_cache.checked = PQSettings.thumbnailCache
        }

        onSaveAllSettings: {
            PQSettings.thumbnailCache = thb_cache.checked
        }

    }

}
