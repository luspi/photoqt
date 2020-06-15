import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Keep in Center"
    helptext: "Keep currently active thumbnail in the center of the screen"
    content: [
        PQCheckbox {
            id: thb_center
            y: (parent.height-height)/2
            text: "Center on active thumbnail"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            thb_center.checked = PQSettings.thumbnailCenterActive
        }

        onSaveAllSettings: {
            PQSettings.thumbnailCenterActive = thb_center.checked
        }

    }

}
