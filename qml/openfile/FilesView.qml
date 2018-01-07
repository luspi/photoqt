import QtQuick 2.6
import QtQuick.Layouts 1.1

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    Layout.fillWidth: true

    color: (openvariables.currentFocusOn=="filesview") ? "#44000055" : "#44000000"

    property alias filesViewModel: gridview.model

    GridView {

        id: gridview

        anchors.fill: parent

        cellWidth: openvariables.filesViewMode=="icon" ? 120 : parent.width
        cellHeight: openvariables.filesViewMode=="icon" ? 120 : 30
        Behavior on cellWidth { NumberAnimation { duration: 200 } }
        Behavior on cellHeight { NumberAnimation { duration: 100 } }

        Text {
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            text: "No image files found"
            font.bold: true
            color: "grey"
            font.pointSize: 20
            visible: (opacity!=0)
            opacity: gridview.model.count==0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        Image {
            id: bgthumb
            anchors.fill: parent
            opacity: 0.3
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width,height)
            source: ""
            Connections {
                target: gridview
                onCurrentIndexChanged:
                    bgthumb.source = "image://" + (settings.openThumbnailsHighQuality ? "full" : "thumb") + "/" + openvariables.currentDirectory + "/" + gridview.model.get(gridview.currentIndex).filename
            }
        }

        model: ListModel { }

        delegate: files
        highlight: fileshighlight
        focus: true

    }

    Component {

        id: files

        Rectangle {

            y: 1
            width: gridview.cellWidth
            height: gridview.cellHeight-(openvariables.filesViewMode=="list" ? 2 : 0)

            color: index%2==0 ? "#22ffffff" : "#11ffffff"

            Image {
                id: thumb
                x: 3
                y: 3
                height: openvariables.filesViewMode=="list" ? parent.height-6 : 2*parent.height/3 -6
                width: openvariables.filesViewMode=="list" ? parent.height-6 : parent.width-6
                source: filename!=undefined ? ("image://thumb/" + openvariables.currentDirectory + "/" + filename) : ""
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: fn_list
                visible: openvariables.filesViewMode=="list"
                anchors{
                    left: thumb.right
                    right: fs_list.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 10
                }
                verticalAlignment: Qt.AlignVCenter
                text: filename
                color: "white"
                font.bold: true
            }

            Rectangle {
                id: fn_icon
                visible: openvariables.filesViewMode=="icon"
                width: parent.width
                height: parent.height/3
                x: 0
                y: 2*parent.height/3
                color: "#88000000"
                radius: 5
                Text {
                    anchors.fill: parent
                    maximumLineCount: 2
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideMiddle
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: filename
                    color: "white"
                    font.bold: true
                }
            }

            Text {
                id: fs_list
                visible: openvariables.filesViewMode=="list"
                anchors{
                    left: fn_list.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 10
                }
                width: openvariables.filesViewMode=="list" ? childrenRect.width : 0
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignRight
                text: filesize
                color: "white"
                font.bold: true
            }

            ToolTip {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: gridview.currentIndex = index
                text: "<tr><td align='right'>Name: </td><td>" + filename + "</td></tr><tr><td align='right'>Size: </td><td>" + filesize + "</td></tr>"
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mainwindow.loadFile(openvariables.currentDirectory + "/" + filename)
                    openfile_top.hide()
                }
            }

        }

    }

    Component {

        id: fileshighlight

        Rectangle {

            width: gridview.cellWidth
            height: gridview.cellHeight

            color: "#5d5d5d"

        }
    }

}
