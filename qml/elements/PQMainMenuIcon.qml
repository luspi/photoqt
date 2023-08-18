import QtQuick

import PQCNotify

Rectangle {

    width: image.width+10
    height: image.height+4

    property string img: ""
    property string cmd: ""
    property real scaleFactor: 1.5
    property bool active: true

    color: "#11000000"
    Behavior on color { ColorAnimation { duration: 200 } }

    radius: 5

    Image {

        id: image

        x: 5
        y: 2

        opacity: parent.active ? 1 : 0.4

        sourceSize: Qt.size(normalEntryHeight*scaleFactor, normalEntryHeight*scaleFactor)
        source: "/white/" + img

    }
    MouseArea {
        enabled: parent.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: parent.color = "#33000000"
        onExited: parent.color = "#11000000"
        onClicked: PQCNotify.executeInternalCommand(cmd)
    }

}
