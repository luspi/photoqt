import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Window Management"
    helptext: "Some basic window management properties."
    expertmodeonly: true
    content: [
        Row {
            y: (parent.height-height)/2
            spacing: 10
            PQCheckbox {
                id: wm_manage
                text: "Manage window through quick info labels"
            }

            PQCheckbox {
                id: wm_save
                y: (parent.height-height)/2
                text: "Save and restore window geometry"
            }
            PQCheckbox {
                id: wm_keep
                y: (parent.height-height)/2
                text: "Keep above other windows"
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            wm_manage.checked = PQSettings.quickInfoManageWindow
            wm_save.checked = PQSettings.saveWindowGeometry
            wm_keep.checked = PQSettings.keepOnTop
        }

        onSaveAllSettings: {
            PQSettings.quickInfoManageWindow = wm_manage.checked
            PQSettings.saveWindowGeometry = wm_save.checked
            PQSettings.keepOnTop = wm_keep.checked
        }

    }

}
