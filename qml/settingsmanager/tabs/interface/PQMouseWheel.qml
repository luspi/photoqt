import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Mouse Wheel Sensitivity"
    helptext: "How sensitive the mouse wheel is for shortcuts/..."
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            y: (parent.height-height)/2
            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "not sensitive"
            }

            PQSlider {
                y: (parent.height-height)/2
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "very sensitive"
            }
        }
    ]
}
