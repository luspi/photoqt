import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Window Mode"
    helptext: ""
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: mode_enable
                y: (parent.height-height)/2
                text: "Run in window mode"
            }
            PQCheckbox {
                id: mode_enable_deco
                y: (parent.height-height)/2
                text: "Show window decoration"
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            mode_enable.checked = PQSettings.windowMode
            mode_enable_deco.checked = PQSettings.windowDecoration
        }

        onSaveAllSettings: {
            PQSettings.windowMode = mode_enable.checked
            PQSettings.windowDecoration = mode_enable_deco.checked
        }

    }

}
