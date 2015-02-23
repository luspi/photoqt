import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

RadioButton {

    // there can be an icon displayed as part of the label
    property string icon: ""

    style: RadioButtonStyle {
                indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 9
                        color: "#88000000"
                        border.color: "white"
                        border.width: 1
                        Rectangle {
                            anchors.fill: parent
                            visible: control.checked
                            color: "white"
                            radius: 9
                            anchors.margins: 5
                        }
                }
                label: Rectangle {
                        color: "#00000000"
                        implicitWidth: childrenRect.width
                        implicitHeight: childrenRect.height
                        Image {
                            id: img
                            x: 0
                            y: 0
                            width: (icon != "") ? 16 : 0
                            height: (icon != "") ? 16 : 0
                            source: icon
                            visible: (icon != "")
                        }
                        Text {
                            id: txt
                            x: (icon != "") ? 18 : 0
                            y: 0
                            color: "white"
                            height: 16
                            text: control.text
                        }
                }
    }

}
