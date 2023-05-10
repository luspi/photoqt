/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import "../../elements"

ListView {

    id: userplaces_top

    boundsBehavior: Flickable.StopAtBounds

    model: ListModel { id: places_model }

    property bool showHiddenEntries: false

    property int dragItemIndex: -1
    property string dragItemId: ""
    property int hoverIndex: -1

    visible: PQSettings.openfileUserPlacesUser

    ScrollBar.vertical: PQScrollBar { id: scroll }

    PQTextL {
        anchors.fill: parent
        anchors.margins: 15
        visible: parent.model.count==1&&handlingGeneral.isPugixmlSupportEnabled()
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        //: 'favorites' here refers to the list of favorite folders a user can set in the file dialog
        text: em.pty+qsTranslate("filedialog", "no folder added to favorites yet")
        color: "grey"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.weight: baselook.boldweight
        lineHeight: 1.5
    }

    delegate: Item {

        id: deleg

        width: userplaces_top.width
        height: !visible ? 0 : 30

        visible: ((path!=undefined&&(hidden=="false"||showHiddenEntries))||index==0)
        opacity: hidden=="false" ? 1 : 0.5

        Rectangle {
            x: 0
            y: 0
            width: userplaces_top.width
            height: 1
            z: 999
            color: "white"
            visible: index>0 && (dragItemIndex>-1&&hoverIndex==index || (dragItemIndex>-1&&hoverIndex==0&&index==1))
        }

        Rectangle {
            x: 0
            y: 29
            width: userplaces_top.width
            height: 1
            z: 999
            color: "white"
            visible: (dragItemIndex>-1&&hoverIndex==index) || (dragItemIndex>-1&&hoverIndex==-1&&index==places_model.count-1)
        }

        // the rectangle containing the actual content that can be dragged around
        Rectangle {

            id: deleg_container

            // full width, height of 30
            // DO NOT tie this to the parent, as the rectangle will be reparented when dragged
            width: userplaces_top.width
            height: 30

            // these anchors make sure the item falls back into place after being dropped
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            color: (userplaces_top.hoverIndex==index||mouseArea.drag.active) ? "#555555" : (path!=""&&(filefoldermodel.folderFileDialog == path||filefoldermodel.folderFileDialog == path+"/") ? "#88555555" :"#00555555")
            Behavior on color { ColorAnimation { duration: 200 } }

            // the icon for this entry (e.g., folder, ...)
            Item {

                id: entryicon

                opacity: 1

                // its size is square (height==width)
                width: deleg_container.height
                height: width

                // the icon image
                Image {

                    // fill parent (with margin for better looks)
                    anchors.fill: parent
                    anchors.margins: 5

                    // not shown for first entry (first entry is category title)
                    visible: index>0

                    sourceSize: Qt.size(width*1.5, height*1.5)

                    // the image icon is taken from image loader (i.e., from system theme if available)
                    source: ((icon!==undefined&&icon!="") ? ("image://icon/::theme::" + icon) : "")

                }

            }

            // The text of each entry
            PQText {

                id: entrytextUser

                // size and position
                anchors.fill: parent
                anchors.leftMargin: entryicon.width

                visible: handlingGeneral.isPugixmlSupportEnabled()

                // vertically center text
                verticalAlignment: Qt.AlignVCenter

                // some styling
                color: index==0 ? "grey" : "white"
                font.weight: baselook.boldweight
                elide: Text.ElideRight

                //: This is the category title of user-set folders (or favorites) in the file dialog
                text: index==0 ? em.pty+qsTranslate("filedialog", "Favorites") : (folder != undefined ? folder : "")
            }

            // mouse area handling clicks
            PQMouseArea {

                id: mouseArea

                // fills full entry
                anchors.fill: parent

                // some properties
                hoverEnabled: true
                acceptedButtons: Qt.RightButton|Qt.LeftButton
                cursorShape: index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                tooltip: index == 0 ? em.pty+qsTranslate("filedialog", "Your favorites") : (path==undefined ? "" : (handlingGeneral.amIOnWindows() ? handlingFileDir.pathWithNativeSeparators(path) : path))

                drag.target: parent

                // if drag is started
                drag.onActiveChanged: {
                    if(index == 0) return
                    if (mouseArea.drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        userplaces_top.dragItemIndex = index
                        userplaces_top.dragItemId = id
                        splitview.dragSource = "userplaces"
                    }
                    deleg_container.Drag.drop();
                    if(!mouseArea.drag.active) {
                        // reset variables used for drag/drop
                        userplaces_top.dragItemIndex = -1
                        userplaces_top.dragItemId = ""
                        userplaces_top.hoverIndex = -1
                    }
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: {
                    if(mouse.button == Qt.LeftButton && index > 0)
                        filedialog_top.setCurrentDirectory(path)
                    else if(mouse.button == Qt.RightButton) {
                        if(index == 0) {
                            var pos = parent.mapFromItem(parent, mouse.x, mouse.y)
                            filedialog_top.leftPanelPopupGenericRightClickMenu()
                        } else
                            contextmenu.popup()
                    }
                }

                onEntered:
                    userplaces_top.hoverIndex = (index>0 ? index : -1)
                onExited:
                    if(userplaces_top.hoverIndex == index)
                        userplaces_top.hoverIndex = -1

            }

            PQMenu {

                id: contextmenu

                MenuItem {
                    text: (hidden=="true" ? (em.pty+qsTranslate("filedialog", "Show entry")) : (em.pty+qsTranslate("filedialog", "Hide entry")))
                    onTriggered:
                        handlingFileDialog.hideUserPlacesEntry(id, hidden=="false")
                }

                MenuItem {
                    text: (em.pty+qsTranslate("filedialog", "Remove entry"))
                    onTriggered:
                        handlingFileDialog.removeUserPlacesEntry(id)
                }

                MenuItem {
                    text: (userplaces_top.showHiddenEntries ? (em.pty+qsTranslate("filedialog", "Hide hidden entries")) : (em.pty+qsTranslate("filedialog", "Show hidden entries")))
                    onTriggered:
                        userplaces_top.showHiddenEntries = !userplaces_top.showHiddenEntries
                }

            }

            Drag.active: mouseArea.drag.active&&index>0
            Drag.hotSpot.x: 10
            Drag.hotSpot.y: 10

            states: [
                State {
                    // when drag starts, reparent entry to splitview
                    when: deleg_container.Drag.active
                    ParentChange {
                        target: deleg_container
                        parent: splitview
                    }
                    // (temporarily) remove anchors
                    AnchorChanges {
                        target: deleg_container
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: undefined
                    }
                }
            ]

        }

    }

    DropArea {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#08ffffff"
            visible: parent.containsDrag
        }
        onDropped: {

            // find the index on which it was dropped
            var newindex = userplaces_top.indexAt(drag.x, drag.y+userplaces_top.contentY)
            // a drop on the first entry (category title) is taken as drop on entry below
            if(newindex===0) newindex = 1

            // if drag/drop originated from folders pane
            if(splitview.dragSource == "folders") {

                handlingFileDialog.addNewUserPlacesEntry(splitview.dragItemPath, newindex)

            // if drag/drop originated from userplaces (reordering)
            } else {
                // if item was dropped below any item, set new index to very end
                if(newindex < 0) newindex = userplaces_top.model.count-1

                // if item was moved (if left in place nothing needs to be done)
                if(userplaces_top.dragItemIndex !== newindex) {

                    // move item to location
                    userplaces_top.model.move(userplaces_top.dragItemIndex, newindex, 1)

                    // and save the changes to file
                    handlingFileDialog.moveUserPlacesEntry(dragItemId, dragItemIndex<newindex, Math.abs(dragItemIndex-newindex))

                }

            }

        }

        onPositionChanged:
            hoverIndex = userplaces_top.indexAt(drag.x, drag.y+userplaces_top.contentY)

    }

    Component.onCompleted:
        loadUserPlaces()

    Connections {
        target: filewatcher
        onUserPlacesChanged: {
            loadUserPlaces()
        }
    }

    function loadUserPlaces() {

        var upl = handlingFileDialog.getUserPlaces()

        places_model.clear()

        places_model.append({"folder" : "",
                             "path" : "",
                             "icon" : "",
                             "id" : "",
                             "hidden" : "false"})

        for(var i = 0; i < upl.length; i+=5)
            places_model.append({"folder" : upl[i],
                                 "path" : upl[i+1],
                                 "icon" : upl[i+2],
                                 "id" : upl[i+3],
                                 "hidden" : upl[i+4]})

    }

}
