import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import PContextMenu 1.0

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

    property int settingsQuickInfoCloseXSize: Math.max(5, Math.min(25, settings.quickInfoCloseXSize))

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
            tooltip: em.pty+qsTr("Go backwards in history")

            onClickedButton: Handle.goBackInHistory()
            onRightClickedButton: toleftcontext.popup()

            PContextMenu {
                id: toleftcontext
                Component.onCompleted: {
                    addItem(em.pty+qsTr("Go backwards in history"))
                    addItem(em.pty+qsTr("Go forwards in history"))
                }
                onSelectedIndexChanged: {
                    if(index == 0)
                        Handle.goBackInHistory()
                    else
                        Handle.goForwardsInHistory()
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
            tooltip: em.pty+qsTr("Go forwards in history")

            onClickedButton: Handle.goForwardsInHistory()
            onRightClickedButton: torightcontext.popup()

            PContextMenu {
                id: torightcontext
                Component.onCompleted: {
                    addItem(em.pty+qsTr("Go backwards in history"))
                    addItem(em.pty+qsTr("Go forwards in history"))
                }
                onSelectedIndexChanged: {
                    if(index == 0)
                        Handle.goBackInHistory()
                    else
                        Handle.goForwardsInHistory()
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
        sourceSize: Qt.size(3*settingsQuickInfoCloseXSize, 3*settingsQuickInfoCloseXSize)

        ToolTip {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: openfile_top.hide()
            //: The element in this case is the element for opening files
            text: em.pty+qsTr("Close element")
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

            property var folders: getanddostuff.getFoldersIn(partialpath, false, settings.openShowHiddenFilesFolders)

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
                        var pos = delegButton.parent.mapToItem(mainwindow, delegButton.x, delegButton.y)
                        contextmenu.popup(Qt.point(pos.x+variables.windowXY.x, pos.y+delegButton.height+variables.windowXY.y))
                    }
                }
                onEntered:
                    if(!contextmenu.opened)
                        parent.hovered = true
                onExited:
                    parent.hovered = false
            }

            PContextMenu {
                id: contextmenu
                property int parentIndex: -1
                onSelectedIndexChanged:
                    openvariables.currentDirectory = userData + folders[index-1]
            }

            Component.onCompleted: {
                //: Used as in "Go directly to subfolder of '/path/to/somewhere'"
                contextmenu.addItem(em.pty+qsTr("Go directly to subfolder of") + " '" + getanddostuff.getDirectoryDirName(partialpath) + "'")
                contextmenu.setEnabled(0, false)
                for(var i = 0; i < folders.length; ++i)
                    contextmenu.addItem(folders[i])
                contextmenu.parentIndex = index
                contextmenu.userData = partialpath
            }

        }

    }

}
