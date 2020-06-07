import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../../../elements"

PQSetting {
    title: "Overlay color"
    helptext: "This is the color that is shown on top of any background image/..."
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            y: (parent.height-height)/2

            Rectangle {
                color: Qt.rgba(PQSettings.backgroundColorRed/255, PQSettings.backgroundColorGreen/255, PQSettings.backgroundColorBlue/255, PQSettings.backgroundColorAlpha/255)
                width: rgba_txt.width+20
                height: rgba_txt.height+20
                border.width: 1
                border.color: "#333333"
                Text {
                    id: rgba_txt
                    x: 10
                    y: 10
                    color: "white"
                    text: "RGBA = 0, 0, 0, 200"
                }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: "Click to change color"
                    onClicked: {
                        colorDialog.color = Qt.rgba(PQSettings.backgroundColorRed/255, PQSettings.backgroundColorGreen/255, PQSettings.backgroundColorBlue/255, PQSettings.backgroundColorAlpha/255)
                        colorDialog.visible = true
                    }
                }
            }

        }

    ]

    ColorDialog {
          id: colorDialog
          title: "Please choose a color"
          showAlphaChannel: true
          onAccepted: {
              console.log("You chose: " + colorDialog.color)
          }
          onRejected: {
              console.log("Canceled")
          }
      }

}
