import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "hot edge"
    helptext: "Show metadata element when the mouse cursor is close to the window edge"
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: meta_hot
            text: "enable"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            meta_hot.checked = PQSettings.metadataEnableHotEdge
        }

        onSaveAllSettings: {
            PQSettings.metadataEnableHotEdge = meta_hot.checked
        }

    }

}
