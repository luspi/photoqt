import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Language"
    helptext: "Change the language of the application."
    content: [
        PQComboBox {
            y: (parent.height-height)/2
            model: ["English", "German", "French", "Spanish"]
        }
    ]
}
