import QtQuick 2.5
import QtQuick.Layouts 1.2

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openFoldersWidth
    onWidthChanged: saveFolderWidth.start()

    property alias folderListView: listView
    property alias folderListModel: listView.model
    property bool showUnsupportedProtocolFolderMessage: false

    color: openvariables.currentFocusOn=="folders" ? "#44000055" : "#44000000"

    Timer {
        id: saveFolderWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openFoldersWidth = width
    }

    ListView {

        id: listView

        width: parent.width
        height: parent.height

        highlightMoveDuration: 100
        highlightResizeDuration: 100

        property int dragItemIndex: -1

        Text {
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            text: showUnsupportedProtocolFolderMessage
                                //: Protocol refers to a file protocol (e.g., for network folders)
                              ? qsTr("This protocol is currently not supported")
                                //: Can also be expressed as 'zero subfolders' or '0 subfolders'. It is also possible to drop the 'sub' leaving 'folders' if that works better
                              : qsTr("No subfolders")
            font.bold: true
            color: "grey"
            font.pointSize: 20
            wrapMode: Text.WordWrap
            visible: (opacity!=0)
            opacity: (listView.model.count==1||showUnsupportedProtocolFolderMessage) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        onCurrentIndexChanged: {
            if(currentIndex != -1)
                openvariables.currentFocusOn = "folders"
        }

        model: ListModel { }

        highlight: Rectangle {

            id: highlightDelegate

            width: listView.width
            height: 30

            color: "#88ffffff"

        }

        delegate: Item {
            id: delegateItem
            width: listView.width
            height: 30

            Rectangle {
                id: dragRect
                width: listView.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: index%2==0 ? "#88000000" : "#44000000"
                Behavior on color { ColorAnimation { duration: 100 } }

                Item {
                    id: draghandler
                    width: dragRect.height
                    height: width
                    Image {
                        source: "image://icon/folder"
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: index>0
                    }

                }

                Text {
                    id: foldertxt
                    anchors {
                        left: draghandler.right
                        top: parent.top
                        bottom: parent.bottom
                        right: imagecountertext.left
                    }
                    width: childrenRect.width

                    anchors.margins: 10
                    verticalAlignment: Qt.AlignVCenter
                    text: folder
                    font.bold: true
                    color: "white"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                Item {

                    id: imagecountertext
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        margins: 10
                    }
                    width: imagecountertextitem.width

                    Text {

                        id: imagecountertextitem

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }

                        verticalAlignment: Qt.AlignVCenter
                        text: ((counter==0||folder=="..") ? ""
                                                         : counter + " " + (counter==1
                        //: Used as in '(1 image)'. This string is always used for the singular, exactly one image
                                                                                        ? qsTr("image")
                        //: Used as in '(11 images)'. This string is always used for multiple images (at least 2)
                                                                                        : qsTr("images")))
                        color: "white"
                        font.italic: true
                        font.pixelSize: 15

                    }

                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: listView.currentIndex = index
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openvariables.currentDirectory = path

                    drag.target: index>0?dragRect:undefined

                    drag.onActiveChanged: {
                        if (mouseArea.drag.active) {
                            listView.dragItemIndex = index;
                            splitview.dragSource = "folders"
                        }
                        dragRect.Drag.drop();
                    }
                }

                states: [
                    State {
                        when: dragRect.Drag.active
                        ParentChange {
                            target: dragRect
                            parent: splitview
                        }

                        AnchorChanges {
                            target: dragRect
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]

                Drag.active: mouseArea.drag.active
                Drag.hotSpot.x: draghandler.width/2
                Drag.hotSpot.y: 10
            }
        }
    }

    ScrollBarVertical {
        id: listview_scrollbar
        flickable: listView
        opacityVisible: 0.8
        opacityHidden: 0.8
    }

    Connections {
        target: openfile_top
        onHighlightEntry:
            highlightEntry(distance)
        onHighlightFirst:
            highlightFirst()
        onHighlightLast:
            highlightLast()
        onLoadEntry: {
            if(openvariables.currentFocusOn == "folders")
                loadHighlightedFolder()
        }
    }

    function highlightEntry(distance) {

        if(openvariables.currentFocusOn != "folders") return

        if(distance > 0)
            listView.currentIndex = Math.min(listView.currentIndex+distance, listView.model.count-1)
        else
            listView.currentIndex = Math.max(listView.currentIndex+distance, 0)

    }

    function highlightFirst() {

        if(openvariables.currentFocusOn != "folders") return

        if(listView.model.count > 0)
            listView.currentIndex = 0

    }

    function highlightLast() {

        if(openvariables.currentFocusOn != "folders") return

        if(listView.model.count > 0)
            listView.currentIndex = listView.model.count-1

    }

    function loadHighlightedFolder() {

        if(openvariables.currentFocusOn != "folders" || listView.model.get(listView.currentIndex) == undefined)
            return

        openvariables.currentDirectory = listView.model.get(listView.currentIndex).path

    }

}
