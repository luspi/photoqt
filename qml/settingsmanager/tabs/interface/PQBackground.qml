import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Background"
    helptext: "What type of background is to be shown."
    content: [
        Row {

            spacing: 10

            y: (parent.height-height)/2

            PQComboBox {
                id: combo
                model: [
                    "(Half-)transparent background",
                    "Faked transparency",
                    "Custom background image",
                    "Non-transparent background"
                ]
            }

            Rectangle {
                y: (parent.height-height)/2
                visible: combo.currentIndex==2
                width: 50
                height: 35
                color: "#333333"
                border.width: 1
                border.color: "#888888"
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: "Click to select an image"
                }
            }

            PQComboBox {
                visible: combo.currentIndex==2
                model: [
                    "Scale to fit",
                    "Scale and Crop to fit",
                    "Stretch to fit",
                    "Center image",
                    "Tile image"
                ]
            }

        }

    ]
}
