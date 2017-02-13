import QtQuick 2.3

Rectangle {

    id: scrollbar

    property Flickable flk : undefined
    color: scrl.visible ? "#22ffffff" : "transparent"

    width: scrl.visible ? 10 : 0
    anchors{
        right: flk.right;
        top: flk.top
        bottom: flk.bottom
    }

    clip: true
    visible: flk.visible
    z:1

    Rectangle {
        id: scrl
        clip: true
        anchors {
            left: parent.left
            right: parent.right
        }
        height: Math.max(20,flk.visibleArea.heightRatio * flk.height)
        visible: flk.visibleArea.heightRatio < 1.0
        radius: 10
        color: "black"

        border.width: 1
        border.color: "#bbbbbb"

        opacity: ma.pressed ? 1 : ma.containsMouse ? 0.8 : 0.6
        Behavior on opacity {NumberAnimation{duration: 150}}

        Binding {
            target: scrl
            property: "y"
            value: !isNaN(flk.visibleArea.heightRatio) ? (ma.drag.maximumY * flk.contentY) / (flk.contentHeight * (1 - flk.visibleArea.heightRatio)) : 0
            when: !ma.drag.active
        }

        Binding {
            target: flk
            property: "contentY"
            value: ((flk.contentHeight * (1 - flk.visibleArea.heightRatio)) * scrl.y) / ma.drag.maximumY
            when: ma.drag.active && flk !== undefined
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.OpenHandCursor
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
            drag {
                target: parent
                axis: Drag.YAxis
                minimumY: 0
                maximumY: flk.height - scrl.height
            }
            preventStealing: true
        }
    }
}
