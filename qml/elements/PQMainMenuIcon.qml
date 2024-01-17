import QtQuick

import PQCNotify

Item {

    width: image.width+10
    height: image.height+4

    property string img: ""
    property string cmd: ""
    property real scaleFactor: 1.5
    property bool active: true

    property bool hovered: false

    Rectangle {
        anchors.fill: parent
        color: PQCLook.baseColorHighlight
        radius: 5
        opacity: hovered ? 0.4 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Image {

        id: image

        x: 5
        y: 2

        opacity: parent.active ? 1 : 0.4

        sourceSize: Qt.size(normalEntryHeight*scaleFactor, normalEntryHeight*scaleFactor)
        source: "image://svg/:/white/" + img

    }
    MouseArea {
        enabled: parent.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: PQCNotify.executeInternalCommand(cmd)
    }

}
