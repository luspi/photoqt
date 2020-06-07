import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Tray Icon"
    helptext: ""
    content: [
        PQComboBox {
            y: (parent.height-height)/2
            model: [
                "No tray icon",
                "Hide to tray icon",
                "Show tray icon but don't hide to it"
            ]
        }

    ]
}
