import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "transparency marker"
    helptext: "Show checkerboard pattern behind transparent areas of (half-)transparent images."
    content: [

        PQCheckbox {
            id: trans_chk
            text: "show checkerboard pattern"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            trans_chk.checked = PQSettings.showTransparencyMarkerBackground
        }

        onSaveAllSettings: {
            PQSettings.showTransparencyMarkerBackground = trans_chk.checked
        }

    }

}
