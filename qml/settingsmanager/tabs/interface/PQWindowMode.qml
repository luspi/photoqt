import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Window Mode"
    helptext: ""
    content: [
        Row {
            spacing: 10
            PQCheckbox {
                y: (parent.height-height)/2
                text: "Run in window mode"
            }
            PQCheckbox {
                y: (parent.height-height)/2
                text: "Show window decoration"
            }
        }

    ]
}
