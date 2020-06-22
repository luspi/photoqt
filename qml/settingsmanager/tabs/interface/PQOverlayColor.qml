import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../../../elements"

PQSetting {
    id: set
    title: "overlay color"
    helptext: "This is the color that is shown on top of any background image/..."
    expertmodeonly: true
    property var rgba: [PQSettings.backgroundColorRed, PQSettings.backgroundColorGreen, PQSettings.backgroundColorBlue, PQSettings.backgroundColorAlpha]
    content: [

        Rectangle {
            id: rgba_rect
            width: rgba_txt.width+20
            height: rgba_txt.height+20
            border.width: 1
            border.color: "#333333"
            color: Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
            Text {
                id: rgba_txt
                x: 10
                y: 10
                color: "white"
                style: Text.Outline
                styleColor: "black"
                text: "RGBA = %1, %2, %3, %4".arg(rgba[0]).arg(rgba[1]).arg(rgba[2]).arg(rgba[3])
            }
            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: "click to change color"
                onClicked: {
                    colorDialog.color = Qt.rgba(rgba[0]/255, rgba[1]/255, rgba[2]/255, rgba[3]/255)
                    colorDialog.visible = true
                    settingsmanager_top.modalWindowOpen = true
                }
            }
        }

    ]

    ColorDialog {
        id: colorDialog
        title: "please choose a color"
        showAlphaChannel: true
        modality: Qt.ApplicationModal
        onAccepted:
            rgba = handlingGeneral.convertHexToRgba(colorDialog.color)
        onRejected: {
            console.log("Canceled")
        }
    }

    Connections {

        target: settingsmanager_top

        onCloseModalWindow: {
            colorDialog.close()
            settingsmanager_top.modalWindowOpen = false
        }

        onLoadAllSettings:
            rgba = [PQSettings.backgroundColorRed, PQSettings.backgroundColorGreen, PQSettings.backgroundColorBlue, PQSettings.backgroundColorAlpha]

        onSaveAllSettings: {
            PQSettings.backgroundColorRed = rgba[0]
            PQSettings.backgroundColorGreen = rgba[1]
            PQSettings.backgroundColorBlue = rgba[2]
            PQSettings.backgroundColorAlpha = rgba[3]
        }

    }


}
