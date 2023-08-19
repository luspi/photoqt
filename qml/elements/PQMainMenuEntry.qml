import QtQuick

import PQCNotify

Item {

    property int smallestWidth: 0
    property bool alignCenter: false

    width: smallestWidth==0 ? Math.max(mainmenu_top.colwidth, row.width+10) : Math.max(smallestWidth, row.width+10)
    height: row.height+10

    property alias font: entry.font

    property string img: ""
    property string img_end: ""
    property string txt: ""
    property string cmd: ""
    property bool closeMenu: false
    property bool active: true

    property bool hovered: false

    Rectangle {
        anchors.fill: parent
        color: PQCLook.baseColorHighlight
        radius: 5
        opacity: hovered ? 0.4 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Row {

        id: row

        x: alignCenter ? (parent.width-width)/2 : 5
        y: 5
        spacing: 10

        Image {
            visible: img!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: img!="" ? ("/white/" + img) : ""
            opacity: active ? (hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        PQText {
            id: entry
            text: txt
            opacity: active ? (hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Image {
            visible: img_end!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: img_end!="" ? ("/white/" + img_end) : ""
            opacity: active ? (hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

    }

    PQMouseArea {
        enabled: parent.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: {
            PQCNotify.executeInternalCommand(cmd)
            if(closeMenu)
                mainmenu_top.hideMainMenu()
        }
    }

}
