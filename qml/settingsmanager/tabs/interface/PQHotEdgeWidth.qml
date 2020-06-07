import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Size of 'Hot Edge'"
    helptext: "Adjusts the sensitivity of the edges for showing elements like the metadata and main menu elements."
    expertmodeonly: true
    content: [
        Row {
            spacing: 10
            y: (parent.height-height)/2
            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "small"
            }

            PQSlider {
                y: (parent.height-height)/2
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "large"
            }
        }

    ]
}
