import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Empty Area around image"
    helptext: ""
    content: [
        PQCheckbox {
            id: closecheck
            y: (parent.height-height)/2
            text: "Close on click"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            closecheck.checked = PQSettings.closeOnEmptyBackground
        }

        onSaveAllSettings: {
            PQSettings.closeOnEmptyBackground = closecheck.checked
        }

    }

}
