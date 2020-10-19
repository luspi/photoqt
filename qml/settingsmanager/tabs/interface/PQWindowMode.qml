import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "window mode")
    helptext: em.pty+qsTranslate("settingsmanager", "Whether to run PhotoQt in window mode or fullscreen.")
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQCheckbox {
                id: mode_enable
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager", "run in window mode")
            }
            PQCheckbox {
                id: mode_enable_deco
                y: (parent.height-height)/2
                text: em.pty+qsTranslate("settingsmanager", "show window decoration")
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
