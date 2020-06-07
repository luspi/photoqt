import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Remember last images"
    helptext: "Re-opens last used image at startup."
    content: [
        PQCheckbox {
            y: (parent.height-height)/2
            text: "Re-open last used image at startup"
        }

    ]
}
