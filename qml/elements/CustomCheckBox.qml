import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

CheckBox {

    id: check
    property int fsize: 8

    style: CheckBoxStyle {
        indicator: Rectangle {
                implicitWidth: fsize*2
                implicitHeight: fsize*2
                radius: 3
                color: "#22FFFFFF"
                Rectangle {
                    visible: control.checked
                    color: "#ffffff"
                    radius: 1
                    anchors.margins: 4
                    anchors.fill: parent
                }
        }
        label: Text {
            color: "white"
            text: check.text
            font.pointSize: fsize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: check.checked = !check.checked
    }

}
