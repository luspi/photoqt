import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Auto-rotation"
    helptext: "Automatically rotate images based on metadata information."
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: meta_rot
            text: "Auto-rotate based on metadata information"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            meta_rot.checked = PQSettings.metaApplyRotation
        }

        onSaveAllSettings: {
            PQSettings.metaApplyRotation = meta_rot.checked
        }

    }

}
