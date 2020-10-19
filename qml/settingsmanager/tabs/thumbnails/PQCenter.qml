import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. Used as in: Keep thumbnail for current main image in center.
    title: em.pty+qsTranslate("settingsmanager_thumbnails", "keep in center")
    helptext: em.pty+qsTranslate("settingsmanager_thumbnails", "Keep currently active thumbnail in the center of the screen")
    content: [
        PQCheckbox {
            id: thb_center
            text: em.pty+qsTranslate("settingsmanager_thumbnails", "center on active thumbnail")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailCenterActive = thb_center.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_center.checked = PQSettings.thumbnailCenterActive
    }

}
