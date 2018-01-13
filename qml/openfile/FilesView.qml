import QtQuick 2.6
import QtQuick.Layouts 1.1

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    Layout.fillWidth: true

    color: (openvariables.currentFocusOn=="filesview") ? "#44000055" : "#44000000"

    property alias filesViewModel: gridview.model
    property alias filesView: gridview
    property alias filesEditRect: editRect

    GridView {

        id: gridview

        anchors.fill: parent
        anchors.bottomMargin: editRect.height

        cellWidth: settings.openDefaultView=="icons" ? settings.openZoomLevel*4 : width
        cellHeight: settings.openDefaultView=="icons" ? settings.openZoomLevel*4 : settings.openZoomLevel
        Behavior on cellWidth { NumberAnimation { duration: 200 } }
        Behavior on cellHeight { NumberAnimation { duration: 100 } }

        Text {
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("No image files found")
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
            opacity: settings.openPreview ? 0.8 : 0
            visible: (opacity != 0)
            Behavior on opacity { NumberAnimation { duration: 200 } }
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width,height)
            source: ""
            z: -1
        }

        model: ListModel { }

        delegate: files
        highlight: fileshighlight
        focus: true

    }

    CustomLineEdit {
        id: editRect
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 5
        }
    }

    Component {

        id: files

        Rectangle {

            y: 1
            width: gridview.cellWidth
            height: gridview.cellHeight-(settings.openDefaultView=="list" ? 2 : 0)

            color: "#44000000"

            Image {
                id: thumb
                x: 3
                y: 3
                height: settings.openDefaultView=="list" ? parent.height-6 : 2*parent.height/3 -6
                width: settings.openDefaultView=="list" ? parent.height-6 : parent.width-6
                source: openfile_top.visible
                        ? (filename!=undefined&&settings.openThumbnails)
                          ? ("image://thumb/" + openvariables.currentDirectory + "/" + filename)
                          : "image://icon/image-" + getanddostuff.getSuffix(openvariables.currentDirectory + "/" + filename)
                        : ""
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                Image {
                    anchors.fill: parent
                    visible: thumb.status!=Image.Ready
                    fillMode: Image.PreserveAspectFit
                    source: openfile_top.visible
                             ? "image://icon/image-" + getanddostuff.getSuffix(openvariables.currentDirectory + "/" + filename)
                             : ""
                }
            }

            Text {
                id: fn_list
                visible: settings.openDefaultView=="list"
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
                font.pixelSize: settings.openZoomLevel/2
            }

            Rectangle {
                id: fn_icon
                visible: settings.openDefaultView=="icons"
                width: parent.width-4
                height: parent.height/3 -4
                x: 2
                y: 2*parent.height/3 +2
                color: "#88000000"
                radius: 5
                Text {
                    anchors.fill: parent
                    maximumLineCount: 1
                    elide: Text.ElideMiddle
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: filename
                    color: "white"
                    font.bold: true
                    font.pixelSize: settings.openZoomLevel/2
                }
            }

            Text {
                id: fs_list
                visible: settings.openDefaultView=="list"
                anchors{
                    left: fn_list.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 10
                }
                width: settings.openDefaultView=="list" ? childrenRect.width : 0
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignRight
                text: filesize
                color: "white"
                font.bold: true
                font.pixelSize: settings.openZoomLevel/2
            }

            ToolTip {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: gridview.currentIndex = index
                //: Refers to the filename. Keep string short!
                text: "<tr><td align='right'><b>" + qsTr("Name") + ": </b></td><td><b>" + filename + "</b></td></tr>
                //: Refers to the filesize. Keep string short!
                       <tr><td align='right'><b>" + qsTr("Size") + ": </b></td><td><b>" + filesize + "</b></td></tr>"
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

            color: "#88ffffff"

        }
    }

    Connections {

        target: gridview

        onCurrentIndexChanged: {
            if(openvariables.highlightingFromUserInput)
                return

            var f = ""
            if(gridview.model.get(gridview.currentIndex) == undefined)
                f = ""
            else {
                f = gridview.model.get(gridview.currentIndex).filename
                if(f == undefined) f = ""
            }
            if(f == "") {
                bgthumb.source = ""
                openvariables.textEditedFromHighlighting = true
                editRect.text = ""
                openvariables.textEditedFromHighlighting = false
            } else {
                bgthumb.source = settings.openPreview
                    ? "image://" + (settings.openPreviewHighQuality ? "full" : "thumb") + "/" + openvariables.currentDirectory + "/" + f
                    : ""
                openvariables.textEditedFromHighlighting = true
                editRect.text = gridview.model.get(gridview.currentIndex).filename
                editRect.selectAll()
                openvariables.textEditedFromHighlighting = false
            }

        }
    }

    Connections {
        target: editRect
        onTextEdited: {
            if(openvariables.textEditedFromHighlighting)
                return
            var pattern = new RegExp(editRect.getText().replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&") + ".*","i")
            var index = -1
            for(var i = 0; i < openvariables.currentDirectoryFiles.length; i+=2) {
                if(pattern.test(openvariables.currentDirectoryFiles[i])) {
                    index = i/2
                    break;
                }
            }
            openvariables.highlightingFromUserInput = true
            if(index != -1)
                gridview.currentIndex = index
            openvariables.highlightingFromUserInput = false
        }
    }

}
