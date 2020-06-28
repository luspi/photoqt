import QtQuick 2.9

import "../../../elements"

Item {

    id: availtop

    width: shcont.width/2-15
    height: col.height+20

    property bool thisIsAnExternalCategory: false

    Column {

        id: col

        x: 10
        y: 10

        spacing: 5

        Repeater {
            model: thisIsAnExternalCategory ? 1 : shcont.available.length

            Rectangle {
                radius: 5
                width: availtop.width-20
                height: cmdtxt.height+10
                color: hovered ? "#2a2a2a" : "#222222"
                Behavior on color { ColorAnimation { duration: 100 } }

                property bool hovered: false

                Text {
                    id: cmdtxt
                    x: 10
                    y: 5
                    color: "#dddddd"
                    text: thisIsAnExternalCategory ? "External shortcut" : shcont.available[index][1]
                }

                Text {
                    id: clicktoadd
                    x: parent.width-width-10
                    y: 5
                    color: "#666666"
                    text: "Click to add shortcut"
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: "Click to add shortcut"
                    onEntered:
                        parent.hovered = true
                    onExited:
                        parent.hovered = false
                    onClicked: {
                        shcont.addShortcut((thisIsAnExternalCategory ? "" : shcont.available[index][0]))
                    }
                }

            }

        }

    }

}
