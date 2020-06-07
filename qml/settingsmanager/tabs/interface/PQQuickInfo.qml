import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Quick info"
    helptext: "The quick info refers to the labels along the top edge of the main view."
    content: [

        PQComboBox {
            opacity: variables.settingsManagerExpertMode ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity > 0
            y: (parent.height-height)/2
            model: [
                "Show all information",
                "Show some information",
                "Show nothing"
            ]
        },

        Flow {
            y: (parent.height-height)/2
            spacing: 10
            opacity: variables.settingsManagerExpertMode ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity > 0

            PQCheckbox {
                text: "Counter"
            }

            PQCheckbox {
                text: "Filepath"
            }

            PQCheckbox {
                text: "Filename"
            }

            PQCheckbox {
                text: "Current zoom level"
            }

            PQCheckbox {
                text: "Exit button ('x' in top right corner)"
            }

        }

    ]
}
