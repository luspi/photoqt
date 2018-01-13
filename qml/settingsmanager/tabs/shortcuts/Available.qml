import QtQuick 2.5
import "../../../elements"

Rectangle {

    id: top

    // The height depends on how many elements there are
    height: Math.max(childrenRect.height,5)
    Behavior on height { NumberAnimation { duration: 150; } }

    // The available shortcuts
    property var shortcuts: []

    color: "transparent"
    clip: true

    // A new shortcut is to be added
    signal addShortcut(var shortcut)

    ListView {

        id: listview

        x: 3
        y: 3
        width: parent.width-6
        height: count*(elementHeight+spacing)

        spacing: 6

        interactive: false

        property int elementHeight: 24

        model: shortcuts.length

        delegate: Rectangle {

            id: deleg_top

            x: 3
            y: 3
            width: listview.width
            height: listview.elementHeight

            radius: 8

            // Color changes when hovered
            property bool hovered: false
            color: hovered ? colour.tiles_inactive : colour.tiles_disabled
            Behavior on color { ColorAnimation { duration: 150; } }


            Rectangle {

                id: sh_title

                width: parent.width/2
                height: parent.height

                color: "transparent"

                // Which shortcut this is
                Text {

                    anchors.fill: parent
                    anchors.margins: 2
                    anchors.leftMargin: 4
                    color: colour.tiles_text_active
                    text: shortcuts[index][1]

                }

            }

            // The buttons
            Rectangle {

                x: parent.width/2+2
                y: 2
                width: parent.width/2-4
                height: parent.height-4

                color: "transparent"

                Text {
                    anchors.fill: parent
                    anchors.margins: 2
                    anchors.leftMargin: 4
                    horizontalAlignment: Text.AlignHCenter
                    color: "grey"
                    text: qsTr("Click to add shortcut")
                }

            }

            // When hovered, change color of this element AND of 'key' button
            // A click adds a new shortcut
            MouseArea {

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered:
                    deleg_top.hovered = true
                onExited:
                    deleg_top.hovered = false
                onClicked:
                    set.addShortcut(shortcuts[index])

            }

        }

    }

}
