import QtQuick 2.9
import "../../../elements"

Rectangle {

    id: item

    color: "#22ffffff"
    radius: 5

    property Item dragParent
    property int listIndex: 0
    property int visualIndex: 0

    x: 5
    y: 5
    width: 290
    height: 40

    anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }

    Text {
        id: txt
        anchors.centerIn: parent
        color: "white"
        text: (item.visualIndex+1) + ") " + visualModel.imagelibraries_disp[item.listIndex]
    }

    PQMouseArea {
        id: dragHandler
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag.target: item
        onEntered:
            item.color = "#44ffffff"
        onExited:
            item.color = "#22ffffff"
        tooltip: em.pty+qsTranslate("settingsmanager_filetypes", "Click-and-drag to reorder items")
    }

    Drag.active: dragHandler.drag.active
    Drag.source: item
    Drag.hotSpot.x: item.width/2
    Drag.hotSpot.y: item.height/2

    states: [
        State {
            when: dragHandler.drag.active
            ParentChange {
                target: item
                parent: item.dragParent
            }

            AnchorChanges {
                target: item
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: undefined
            }
        }
    ]

}
