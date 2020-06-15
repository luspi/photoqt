import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Disable"
    helptext: "Disable thumbnails in case no thumbnails are desired whatsoever."
    content: [

        PQCheckbox {
            id: thb_disable
            y: (parent.height-height)/2
            text: "Disable all thumbnails"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            thb_disable.checked = PQSettings.thumbnailDisable
        }

        onSaveAllSettings: {
            PQSettings.thumbnailDisable = thb_disable.checked
        }

    }

}
