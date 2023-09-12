import QtQuick

Item {

    id: control_top

    width: 300
    height: model.length*50

    property int currentIndex: 0
    property var model: []

    Column {

        Repeater {

            id: repeater
            model: control_top.model

            Rectangle {
                property bool active: index === control_top.currentIndex
                property bool hovered: false
                width: control_top.width
                height: 48
                color: active ? PQCLook.baseColorActive : (hovered ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)
                Behavior on color { ColorAnimation { duration: 200 } }
                border.width: 1
                border.color: PQCLook.baseColorActive

                PQText {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: control_top.model[index]
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                        control_top.currentIndex = index
                    onEntered:
                        parent.hovered = true
                    onExited:
                        parent.hovered = false
                }

            }

        }

    }

}
