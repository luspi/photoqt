import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../elements"

Item {

    id: bread_top

    property var pathParts: []

    height: 50

    function goBackwards() {
        backwards.clicked()
    }
    function canGoBackwards() {
        return backwards.enabled
    }

    function goForwards() {
        forwards.clicked()
    }
    function canGoForwards() {
        return forwards.enabled
    }

    PQButton {

        id: backwards

        text: "<"

        enabled: filedialog_top.historyListIndex>0

        font.pointSize: 20
        width: 2*height/3

        x: 0
        y: (bread_top.height-height)/2

        onClicked: {
            if(filedialog_top.historyListIndex > 0) {
                filedialog_top.historyListIndex -= 1
                filedialog_top.setCurrentDirectory(filedialog_top.historyListDirectory[filedialog_top.historyListIndex], false)
            }
        }

        tooltip: em.pty+qsTranslate("filedialog", "Backwards")
        tooltipFollowsMouse: false

    }

    PQButton {

        id: forwards

        text: ">"

        enabled: filedialog_top.historyListIndex<filedialog_top.historyListDirectory.length-1

        font.pointSize: 20
        width: 2*height/3

        anchors.left: backwards.right
        anchors.leftMargin: 5

        y: (bread_top.height-height)/2

        onClicked: {
            if(filedialog_top.historyListIndex < filedialog_top.historyListDirectory.length-1) {
                filedialog_top.historyListIndex += 1
                filedialog_top.setCurrentDirectory(filedialog_top.historyListDirectory[filedialog_top.historyListIndex], false)
            }
        }

        tooltip: em.pty+qsTranslate("filedialog", "Forwards")
        tooltipFollowsMouse: false

    }

    Rectangle {
        id: sep1
        anchors.left: forwards.right
        anchors.leftMargin: 5
        width: 1
        height: bread_top.height
        color: "#444444"
    }

    ListView {

        id: path

        anchors.left: sep1.right
        anchors.leftMargin: 10
        anchors.right: sep2.left
        anchors.rightMargin: 10

        height: bread_top.height

        clip: true
        interactive: false

        boundsBehavior: Flickable.StopAtBounds

        model: Math.max(0, 2*pathParts.length -1)

        orientation: Qt.Horizontal

        delegate: PQButton {

            id: modelentry
            text: index==0||index%2==0 ? "/" : pathParts[(index+1)/2]

            height: bread_top.height

            clickOpensMenu: index==0||index%2==0

            font.bold: true

            property string completePath: ""

            tooltip: index==0||index%2==0 ? em.pty+qsTranslate("filedialog", "List subfolders") : completePath
            tooltipFollowsMouse: false

            onClicked:
                filedialog_top.setCurrentDirectory(completePath)

            Component.onCompleted: {
                completePath = "/"
                for(var i = 1; i <= (index+1)/2; ++i)
                    completePath += pathParts[i] + "/"
                listMenuItems = handlingFileDialog.getFoldersIn(completePath)
            }

            onMenuItemClicked:  {
                var newpath = "/"
                for(var i = 1; i < (index+1)/2; ++i)
                    newpath += pathParts[i] + "/"
                filedialog_top.setCurrentDirectory(newpath+"/"+listMenuItems[pos])
            }

        }

    }

    Rectangle {
        id: sep2
        anchors.right: closefileview.left
        anchors.rightMargin: 5
        width: 1
        height: bread_top.height
        color: "#444444"
    }

    Item {
        id: closefileview
        anchors.right: parent.right
        height: parent.height
        width: height

        Image {

            anchors.fill: parent
            anchors.margins: 10

            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            source: "/filedialog/close.png"

        }

        PQMouseArea {
            anchors.fill: parent
            tooltip: em.pty+qsTranslate("filedialog", "Close")
            tooltipFollowsMouse: false
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: filedialog_top.hideFileDialog()
        }

    }


    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: "#aaaaaa"
    }

}
