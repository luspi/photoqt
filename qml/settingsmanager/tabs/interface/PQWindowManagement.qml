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
                y: (parent.height-height)/2
                text: "Save and restore window geometry"
            }
            PQCheckbox {
                y: (parent.height-height)/2
                text: "Keep above other windows"
            }
        }

    ]
}
