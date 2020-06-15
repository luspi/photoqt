import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {

    id: tile

    color: chk.checked ? "#555555" : (hovered ? "#3a3a3a" : "#222222")
    Behavior on color { ColorAnimation { duration: 150 } }

    radius: 5

    width: secondText=="" ? 250 : 505
    height: chk.height+20
    clip: true

    property bool hovered: false

    property alias text: chk.text
    property alias checked: chk.checked

    property alias secondText: chk_2.text
    property alias secondChecked: chk_2.checked

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            var old = chk.checked
            chk.checked = !old
        }
        onEntered:
            tile.hovered = true
        onExited:
            tile.hovered = false

        tooltip: chk.text
    }

    Row {

        x: 10
        spacing: 10

        PQCheckbox {
            id: chk
            y: 10
            width: 230

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    var old = chk.checked
                    chk.checked = !old
                }

                onEntered:
                    tile.hovered = true
                tooltip: chk.text
            }

        }

        Item {
            width: 5
            height: 1
        }

        PQCheckbox {
            id: chk_2
            visible: secondText!=""
            y: 10
            width: 230
            text: secondText
            enabled: chk.checked


            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    var old = chk_2.checked
                    chk_2.checked = !old
                }
                onEntered:
                    tile.hovered = true

                tooltip: chk_2.text
            }
        }

    }

}
