import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Empty Area around image"
    helptext: ""
    content: [
        PQCheckbox {
            y: (parent.height-height)/2
            text: "Close on click"
        }

    ]
}
