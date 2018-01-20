import QtQuick 2.5
import QtQuick.Layouts 1.2

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    // minimum width is 200
    Layout.minimumWidth: 200
    // starting width is read from settings
    width: settings.openFoldersWidth
    // a change in width is written to settings
    onWidthChanged: settings.openFoldersWidth = width

    // some aliases to access things from outside
    property alias folderListView: listView
    property alias folderListModel: listView.model

    // when this is set to true, an 'unsupported protocol' message is displayed
    property bool showUnsupportedProtocolFolderMessage: false

    // if in focus, show a slight blue glimmer
    color: openvariables.currentFocusOn=="folders" ? "#44000055" : "#44000000"

    // Entering the pane (even if not hovering a folder) sets the current focus to folders
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: openvariables.currentFocusOn = "folders"
    }

    // This listview holds all the subfolders found in the current folder
    ListView {

        id: listView

        // fills all the space available in pane
        anchors.fill: parent

        // item for highlighing moves fairly fast
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        // used for dragging folders to userplaces
        property int dragItemIndex: -1

        // Some status messages if no subfolder is found in the folder or the protocol is not supported (like network:/)
        Text {

            // tie size to parent
            anchors.fill: parent

            // displayed in center
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter

            // visibility depends on model count and property value
            visible: (opacity!=0)
            opacity: (listView.model.count==1||showUnsupportedProtocolFolderMessage) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            // some additional styling
            font.bold: true
            color: "grey"
            font.pointSize: 20
            wrapMode: Text.WordWrap

            // the text status messages
            text: showUnsupportedProtocolFolderMessage
                                //: Protocol refers to a file protocol (e.g., for network folders)
                              ? em.pty+qsTr("This protocol is currently not supported")
                                //: Can also be expressed as 'zero subfolders' or '0 subfolders'. It is also possible to drop the 'sub' leaving 'folders' if that works better
                              : em.pty+qsTr("No subfolders")

        }

        // the model is a simple ListModel, filled by handlestuff.js
        model: ListModel { }

        // the item for showing which entry is highlighted
        highlight: Rectangle {

            // it fills the full entry
            width: listView.width
            height: 30

            // slight white background signals highlighted entry
            color: "#88ffffff"

        }

        // This is the component that makes up each file entry
        delegate: Item {

            id: delegateItem

            // full width, fixed height of 30
            width: listView.width
            height: 30

            // the rectangle that can be dragged to userplaces
            Rectangle {

                id: dragRect

                // full width, height of 30
                // DO NOT tie this to the parent, as the rectangle will be reparented when dragged
                width: listView.width
                height: 30

                // these anchors make sure the item falls back into place after being dropped
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                // give the entries an alternating background color
                color: index%2==0 ? "#88000000" : "#44000000"

                // This item holds the icon for the folders
                Item {

                    id: foldericon

                    // its size is square (height==width)
                    width: dragRect.height
                    height: width

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        // not shown for first entry (first entry is '..')
                        visible: index>0

                        // the folder icon is taken from image loader (i.e., from system theme if available)
                        source: "image://icon/folder"

                    }

                }

                // The text of the folder entries
                Text {

                    id: foldertxt

                    // the size and position
                    anchors {
                        left: foldericon.right
                        top: parent.top
                        bottom: parent.bottom
                        right: imagecountertext.left
                        margins: 10
                    }
                    width: childrenRect.width

                    // vertically center text
                    verticalAlignment: Qt.AlignVCenter

                    // some styling
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight

                    // and the folder name
                    text: folder

                }

                // This item holds some tetx showing how many images are found in the folder
                Item {

                    id: imagecountertext

                    // size and width at right end of entry
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        margins: 10
                    }
                    width: imagecountertextitem.width

                    // the text holding how many images there are
                    Text {

                        id: imagecountertextitem

                        // top and bottom are tied to parent, width is defined by text
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }

                        // vertically center the text
                        verticalAlignment: Qt.AlignVCenter

                        // some styling
                        color: "white"
                        font.italic: true
                        font.pixelSize: 15

                        // the text varies depending on if 0, 1, or 2+ images were found
                        text: ((counter==0||folder=="..") ? ""
                                                         : counter + " " + (counter==1
                        //: Used as in '(1 image)'. This string is always used for the singular, exactly one image
                                                                                        ? em.pty+qsTr("image")
                        //: Used as in '(11 images)'. This string is always used for multiple images (at least 2)
                                                                                        : em.pty+qsTr("images")))

                    }

                }

                // mouse area handling clicks and drag
                ToolTip {

                    id: mouseArea

                    // fills full entry
                    anchors.fill: parent

                    // some properties
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    // entering the area sets entry as current item
                    onEntered: listView.currentIndex = index

                    // clicking an entry loads the folder
                    onClicked: openvariables.currentDirectory = path

                    // all entries except the first one (the first one is '..') can be dragged
                    drag.target: index>0?dragRect:undefined

                    // if drag is started
                    drag.onActiveChanged: {
                        if(mouseArea.drag.active) {
                            // store which index is being dragged and that the entry comes from the folders pane
                            listView.dragItemIndex = index;
                            splitview.dragSource = "folders"
                        }
                        dragRect.Drag.drop();
                    }

                    // the folder name is the tooltip (handy for very long folder names that don't fit into the space fully
                    text: folder

                }

                // some states for dragging
                states: [
                    State {
                        // when drag starts, reparent entry to splitview
                        when: dragRect.Drag.active
                        ParentChange {
                            target: dragRect
                            parent: splitview
                        }
                        // (temporarily) remove anchors
                        AnchorChanges {
                            target: dragRect
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]

                // the drag is tied to the mouse area
                Drag.active: mouseArea.drag.active

                // this is the hotspot that has to be dragged somewhere for a drag/drop to occur
                Drag.hotSpot.x: foldericon.width/2
                Drag.hotSpot.y: 10

            }

        }

    }

    // A scrollbar for the folders
    // This bar is very important. Due to support for dragging folders, this is the only way to scroll folders through clicking!
    ScrollBarVertical {
        id: listview_scrollbar
        flickable: listView
        // don't hide, always keep visible
        opacityVisible: 0.8
        opacityHidden: 0.8
    }

    // Also rect to changes in the folder
    Connections {

        target: listView

        // a change in currentIndex sets the focus onto folders
        onCurrentIndexChanged: {
            if(listView.currentIndex != -1)
                openvariables.currentFocusOn = "folders"
        }

    }

    // React to shortcut actions
    Connections {
        target: openfile_top
        onHighlightEntry:
            highlightEntry(distance)
        onHighlightFirst:
            highlightFirst()
        onHighlightLast:
            highlightLast()
        onLoadEntry:
            loadHighlightedFolder()
    }

    // highlight an entry up or down (at given distance)
    function highlightEntry(distance) {

        // check if we have focus
        if(openvariables.currentFocusOn != "folders") return

        // >0 means go down
        if(distance > 0)
            listView.currentIndex = Math.min(listView.currentIndex+distance, listView.model.count-1)
        // <0 means go up
        else
            listView.currentIndex = Math.max(listView.currentIndex+distance, 0)

    }

    // highlight the first entry in the list
    function highlightFirst() {

        // check if we have focus
        if(openvariables.currentFocusOn != "folders") return

        // if there are any items, go to first one
        if(listView.model.count > 0)
            listView.currentIndex = 0

    }

    // highlight the lasy entry in the list
    function highlightLast() {

        // check if we have focus
        if(openvariables.currentFocusOn != "folders") return

        // if there are any items, go to last one
        if(listView.model.count > 0)
            listView.currentIndex = listView.model.count-1

    }

    // Load the entry that is currently highlighted
    function loadHighlightedFolder() {

        // check if we have focus and if entry is valid
        if(openvariables.currentFocusOn != "folders" || listView.model.get(listView.currentIndex) == undefined)
            return

        // load folder
        openvariables.currentDirectory = listView.model.get(listView.currentIndex).path

    }

}
