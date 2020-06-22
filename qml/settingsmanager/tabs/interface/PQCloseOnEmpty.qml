import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "empty area around image"
    helptext: "How to handle clicks on empty area around images."
    content: [
        PQCheckbox {
            id: closecheck
            text: "close on click"
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
