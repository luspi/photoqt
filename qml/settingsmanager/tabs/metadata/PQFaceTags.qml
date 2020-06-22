import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "face tags"
    helptext: "Whether to show face tags (stored in metadata info)."
    content: [

        PQCheckbox {
            id: ft
            text: "enable"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            ft.checked = PQSettings.peopleTagInMetaDisplay
        }

        onSaveAllSettings: {
            PQSettings.peopleTagInMetaDisplay = ft.checked
        }

    }

}
