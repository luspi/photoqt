import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "disable"
    helptext: "Disable thumbnails in case no thumbnails are desired whatsoever."
    content: [

        PQCheckbox {
            id: thb_disable
            text: "disable all thumbnails"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailDisable = thb_disable.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        thb_disable.checked = PQSettings.thumbnailDisable
    }

}
