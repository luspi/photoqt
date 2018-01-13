import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    id: breadcrumbs_top

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right
    height: 50

    property int contextMenuCurrentIndex: -1

    property alias modelForCrumbs: crumbsmodel
    property alias viewForCrumbs: crumbsview

    color: "#44000000"

    // Two buttons to go backwards/forwards in history
    Rectangle {

        id: hist_but

        // Positioning and styling
        color: "transparent"
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: toleft.width+toright.width

        // Backwards
        CustomButton {

            id: toleft

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 40

            enabled: (openvariables.historypos > 0 && openvariables.history.length > 1)

            text: "<"
            fontsize: 30
            overrideFontColor: "white"
            overrideBackgroundColor: "transparent"

            opacity: enabled ? 1 : 0.4

            //: The history is the list of visited folders in the element for opening files
            tooltip: qsTr("Go backwards in history")

            onClickedButton: Handle.goBackInHistory()
            onRightClickedButton: toleftcontext.popup()

            ContextMenu {
                id: toleftcontext
                MenuItem {
                    //: The history is the list of visited folders in the element for opening files
                    text: qsTr("Go backwards in history")
                    onTriggered: Handle.goBackInHistory()
                }
                MenuItem {
                    //: The history is the list of visited folders in the element for opening files
                    text: qsTr("Go forwards in history")
                    onTriggered: Handle.goForwardsInHistory()
                }

            }

        }

        // Forwards
        CustomButton {

            id: toright

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 40

            enabled: (openvariables.historypos < openvariables.history.length-1 && openvariables.historypos > 0)

            text: ">"
            fontsize: 30
            overrideFontColor: "white"
            overrideBackgroundColor: "transparent"

            opacity: enabled ? 1 : 0.4

            //: The history is the list of visited folders in the element for opening files
            tooltip: qsTr("Go forwards in history")

            onClickedButton: Handle.goForwardsInHistory()
            onRightClickedButton: torightcontext.popup()

            ContextMenu {
                id: torightcontext
                MenuItem {
                    //: The history is the list of visited folders in the element for opening files
                    text: qsTr("Go backwards in history")
                    onTriggered: Handle.goBackInHistory()
                }
                MenuItem {
                    //: The history is the list of visited folders in the element for opening files
                    text: qsTr("Go forwards in history")
                    onTriggered: Handle.goForwardsInHistory()
                }

            }

        }

    }

    // This button closes the OpenFile dialog -> it is displayed to the RIGHT of the ListView below, in the top right corner
    Image {

        id: closeopenfile

        anchors.right: parent.right
        anchors.top: parent.top

        source: "qrc:/img/closingx.png"
        sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

        ToolTip {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: openfile_top.hide()
            //: The element in this case is the element for opening files
            text: qsTr("Close element")
        }

    }

    ListView {

        id: crumbsview

        spacing: 0

        anchors.left: hist_but.right
        anchors.right: closeopenfile.left
        height: parent.height

        orientation: ListView.Horizontal
        interactive: false
        clip: true

        model: ListModel { id: crumbsmodel; }

        property var menuitems: []

        delegate: Button {
            id: delegButton
            y: 7
            height: parent.height-15
            property bool hovered: false

            property bool clicked: false

            Connections {
                target: contextmenu
                onOpenedChanged:
                    delegButton.clicked = (contextmenu.opened&&index==contextmenu.parentIndex)
            }

            style: ButtonStyle {
                background: Rectangle {
                    id: bg
                    anchors.fill: parent
                    color: (hovered||delegButton.clicked) ? "#44ffffff" : "#00000000"
                    radius: 5
                }

                label: Text {
                    id: txt
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                    font.bold: true
                    font.pointSize: 15
                    text: type=="folder" ? " " + location + " " : " / "
                }

            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if(type == "folder")
                        openvariables.currentDirectory = partialpath
                    else {
                        delegButton.clicked = true
                        contextmenu.clear()
                        //: Used as in "Go directly to subfolder of '/path/to/somewhere'"
                        var head = contextmenu.addItem(qsTr("Go directly to subfolder of") + " '" + getanddostuff.getDirectoryDirName(partialpath) + "'")
                        head.enabled = false
                        var folders = getanddostuff.getFoldersIn(partialpath, false, settings.openShowHiddenFilesFolders)
                        for(var i = 0; i < folders.length; ++i) {
                            var item = contextmenu.addItem(folders[i])
                            item.triggered.connect(loadDir)
                        }
                        function loadDir() {
                            openvariables.currentDirectory = partialpath + folders[contextMenuCurrentIndex-1]
                        }
                        contextmenu.parentIndex = index
                        contextmenu.__popup(Qt.rect(parent.x, parent.y, parent.width, parent.height))
                    }
                }
                onEntered:
                    if(!contextmenu.opened)
                        parent.hovered = true
                onExited:
                    parent.hovered = false
            }

        }

    }

    ContextMenu {
        title: "Folders"
        id: contextmenu
        property int parentIndex: -1
        on__CurrentIndexChanged: {
            if(__currentIndex != -1)
                contextMenuCurrentIndex = __currentIndex
        }
    }

}
