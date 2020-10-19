import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "mouse wheel sensitivity")
    helptext: em.pty+qsTranslate("settingsmanager", "How sensitive the mouse wheel is for shortcuts, etc.")
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            Text {
                y: (parent.height-height)/2
                color: "white"
                //: The sensitivity here refers to the sensitivity of the mouse wheel
                text: em.pty+qsTranslate("settingsmanager", "not sensitive")
            }

            PQSlider {
                id: wheelsensitivity
                y: (parent.height-height)/2
                from: 0
                to: 10
                stepSize: 1
                wheelStepSize: 1
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                //: The sensitivity here refers to the sensitivity of the mouse wheel
                text: em.pty+qsTranslate("settingsmanager", "very sensitive")
            }
        }
    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            wheelsensitivity.value = PQSettings.mouseWheelSensitivity
        }

        onSaveAllSettings: {
            PQSettings.mouseWheelSensitivity = wheelsensitivity.value
        }

    }

}
