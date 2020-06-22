import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "window management"
    helptext: "Some basic window management properties."
    expertmodeonly: true
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: wm_manage
                text: "manage window through quick info labels"
            }

            PQCheckbox {
                id: wm_save
                y: (parent.height-height)/2
                text: "save and restore window geometry"
            }
            PQCheckbox {
                id: wm_keep
                y: (parent.height-height)/2
                text: "keep above other windows"
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
