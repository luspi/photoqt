/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import PContextMenu 1.0

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    id: userplaces_top

    // minimum width is 200, maximum width is half the element width
    Layout.minimumWidth: 200
    Layout.maximumWidth: openfile_top.width/2
    // starting width is read from settings
    width: settings.openUserPlacesWidth
    // a change in width is written to settings
    onWidthChanged: settings.openUserPlacesWidth = width

    // Below this threshold, we collapse this pane
    property int minimisedThreshold: 1000
    // If the pane is intially visible, the window is resized small enough and it is hidden, and afterwards increased again it will be shown again
    // If, on the other hand, the user has hidden it himself, it will stay hidden
    property bool tmpOpenHideUserPlaces: false

    // The pane can be hidden if not wanted
    visible: !settings.openHideUserPlaces

    // margin in between the different categories
    property int marginBetweenCategories: 20

    // some aliases to access things from outside
    property alias userPlacesView: userPlaces
    property alias userPlacesModel: userPlaces.model
    property alias storageInfoModel: storageinfo.model

    // used for drag/drop of items to/within userplaces
    property int hoveringOver: -1

    // if in focus, show a slight blue glimmer
    color: openvariables.currentFocusOn=="userplaces" ? "#44000055" : "#44000000"

    // a click on background by default shows a context menu for showing/hiding categories
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        onClicked: headingmenu.popup()
        onEntered: openvariables.currentFocusOn = "userplaces"
    }

    Text {

        // tie size to parent
        anchors.fill: parent
        anchors.margins: 10

        // displayed in center
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter

        // visibility depends on model count and property value
        visible: (opacity!=0)
        opacity: (settings.openUserPlacesStandard || settings.openUserPlacesUser || settings.openUserPlacesVolumes) ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

        // some additional styling
        font.bold: true
        color: "grey"
        font.pointSize: 20
        wrapMode: Text.WordWrap

        // the text status messages
        text: em.pty+qsTr("No categories enabled! They can be shown on right click!")

    }

    // This listview holds the standard locations
    ListView {

        id: standardlocations

        // size and position depends on whether this category is actually visible
        y: settings.openUserPlacesStandard ? marginBetweenCategories : 0
        width: parent.width
        height: settings.openUserPlacesStandard ? childrenRect.height : 0

        // visibility from settings
        visible: settings.openUserPlacesStandard

        // not interactive, fixed height
        interactive: false

        // item for highlighing moves fairly fast
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        // if the current index changes, then reset currentIndex for userplaces and storageinfo
        onCurrentIndexChanged:
            handleChangeCurrentIndex("standard")

        // The model is a simple listmodel with 4 fixed entries (they don't change)
        model: ListModel {
            Component.onCompleted: {
                // the first entry is used for the category title
                append({"name" : "",
                        "location" : "",
                        "icon" : ""})
                //: This is used as name of the HOME folder
                append({"name" : em.pty+qsTr("Home"),
                        "location" : getanddostuff.getHomeDir(),
                        "icon" : "user-home"})
                //: This is used as name of the DESKTOP folder
                append({"name" : em.pty+qsTr("Desktop"),
                        "location" : getanddostuff.getDesktopDir(),
                        "icon" : "user-desktop"})
                //: This is used as name of the PICTURES folder
                append({"name" : em.pty+qsTr("Pictures"),
                        "location" : getanddostuff.getPicturesDir(),
                        "icon" : "folder-pictures"})
                //: This is used as name of the DOWNLOADS folder
                append({"name" : em.pty+qsTr("Downloads"),
                        "location" : getanddostuff.getDownloadsDir(),
                        "icon" : "folder-download"})
            }
        }

        // the item for showing which entry is highlighted
        highlight: Rectangle {

            // it fills the full entry
            width: userPlaces.width
            height: 30

            // slight white background signals highlighted entry
            color: "#88ffffff"

        }

        // This is the component that makes up each file entry of the standard location
        delegate: Item {

            id: standarddeleg

            // full width, fixed height of 30
            width: standardlocations.width
            height: 30

            // a rectangle for each item
            Rectangle {

                // full width and height
                width: standardlocations.width
                height: 30

                // give the entries an alternating background color
                color: index%2==0 ? "#88000000" : "#44000000"

                // This item holds the icon for the folders
                Item {

                    id: iconitem

                    // its size is square (height==width)
                    width: parent.height
                    height: width

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        // not shown for first entry (first entry is '..')
                        visible: index>0

                        // the image icon taken from image loader (i.e., from system theme if available)
                        source: "image://icon/" + icon

                    }

                }

                // The text of each entry
                Text {

                    id: entrytextStandard

                    // size and position
                    anchors.fill: parent
                    anchors.leftMargin: iconitem.width

                    // vertically center text
                    verticalAlignment: Qt.AlignVCenter

                    // some styling
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight

                    //: This is the category title of standard/common folders (like Home, Desktop, ...) in the element for opening files
                    text: index==0 ? em.pty+qsTr("Standard") : name

                }

                // mouse area handles changes to currentIndex and clicked events
                ToolTip {

                    // a click everywhere works
                    anchors.fill: parent

                    text: entrytextStandard.text

                    // some properties
                    hoverEnabled: true
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                    // entering the area sets entry as current item
                    onEntered: standardlocations.currentIndex = index

                    // clicking an entry loads the location
                    onClicked: openvariables.currentDirectory = location

                }

            }

        }

    }

    // This listview holds the userplaces (can be changed by user)
    ListView {

        id: userPlaces

        // size and position. Expands to fill all the space in the middle
        anchors {
            top: standardlocations.bottom
            right: parent.right
            topMargin: marginBetweenCategories
        }
        width: parent.width
        height: settings.openUserPlacesUser ? parent.height-standardlocations.height-storageinfo.height-3*marginBetweenCategories : 0

        // visibility depends on settings
        visible: settings.openUserPlacesUser

        // item for highlighing moves fairly fast
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        // used for handling reordering of userplaces by drag/drop
        property int dragItemIndex: -1

        // if the current index changes, then reset currentIndex for standardlocations and storageinfo
        onCurrentIndexChanged:
            handleChangeCurrentIndex("userplaces")

        Text {

            // tie size to parent
            anchors.fill: parent
            anchors.margins: 10

            // displayed in center
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter

            // visibility depends on model count and property value
            visible: (opacity!=0)
            opacity: userPlaces.model.count===1
            Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            // some additional styling
            font.bold: true
            color: "grey"
            font.pointSize: 15
            wrapMode: Text.WordWrap

            // the text status messages
            text: em.pty+qsTr("No user places set yet. You can drag and drop folders here to bookmark them.")

        }

        // The drop area for drag/drop and/or reordering
        DropArea {

            id: dropArea

            // fills the entire listview
            anchors.fill: parent

            // when item was dropped on it
            onDropped: {

                // find the index on which it was dropped
                var newindex = userPlaces.indexAt(drag.x, drag.y+userPlaces.contentY)
                // a drop on the first entry (category title) is taken as drop on entry below
                if(newindex===0) newindex = 1

                // if drag/drop originated from folders pane
                if(splitview.dragSource == "folders") {

                    // if item was dropped on an item, insert folder at that location
                    if(newindex !== -1)
                        userPlaces.model.insert(newindex, folders.folderListView.model.get(folders.folderListView.dragItemIndex))
                    // if item was dropped below the items, simply append it to the model
                    else
                        userPlaces.model.append(folders.folderListView.model.get(folders.folderListView.dragItemIndex))

                    // and save the changes to file
                    Handle.saveUserPlaces()

                // if drag/drop originated from userplaces (reordering)
                } else {
                    // if item was dropped below any item, set new index to very end
                    if(newindex < 0) newindex = userPlaces.model.count-1

                    // if item was moved (if left in place nothing needs to be done)
                    if(userPlaces.dragItemIndex !== newindex) {

                        // move item to location
                        userPlaces.model.move(userPlaces.dragItemIndex, newindex, 1)

                        // and save the changes to file
                        Handle.saveUserPlaces()

                    }

                }

                // reset variables used for drag/drop
                folders.folderListView.dragItemIndex = -1
                userplaces_top.hoveringOver = -1

            }

            // if mouse is moved during a drag
            onPositionChanged: {

                // get new index
                var newindex = userPlaces.indexAt(drag.x, drag.y+userPlaces.contentY)
                // if drag is below any item, set newindex to end
                if(newindex === -1)
                    newindex = userPlaces.model.count

                // store where the drag is located right now (updates marker in model)
                userplaces_top.hoveringOver = newindex

            }

            // if drag leaves drop area, we stop following it
            onExited: userplaces_top.hoveringOver = -1

        }

        // The model is a simple listmodel that at start loads the userplaces
        model: ListModel {
            Component.onCompleted: {
                Handle.loadUserPlaces()
            }
        }

        // the item for showing which entry is highlighted
        highlight: Rectangle {

            // it fills the full entry
            width: userPlaces.width
            height: 30

            // slight white background signals highlighted entry
            color: "#88ffffff"

        }

        // This is the component that makes up each entry
        delegate: Item {

            id: userPlacesDelegate

            // This is needed for deleting an entry from the context menu, as the signal that is received there passes on a variable that is also named index
            property int myIndex: index

            // full width, fixed height of 30 (if entry not hidden)
            width: userPlaces.width
            height: !visible ? 0 : 30

            // an entry can be hidden (property in XML file). We still load it so that when we save the file we keep all information
            // the 'notvisible' key allows the functions below to find out whether this item is hidden or not
            // if entry is not set, the item defaults to being visible
            visible: notvisible=="0"
            Component.onCompleted:
                notvisible = (((path!=undefined&&hidden=="false")||index==0) ? "0" : "1")

            // hovering over an item shows a marker line above (and below)
            Rectangle {

                // full width, height of 1 (thin line)
                width: userPlaces.width
                height: 1

                // white color for good looks
                color: "white"

                // opacity depends on drag/drop and is animated slightly
                opacity: (userplaces_top.hoveringOver==index&&index>0)||(userplaces_top.hoveringOver==index-1&&index==1) ? 1 : 0
                visible: opacity!=0
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

            }

            // the rectangle containing the actual content that can be dragged around
            Rectangle {

                id: dragRect

                // full width, height of 30
                // DO NOT tie this to the parent, as the rectangle will be reparented when dragged
                width: userPlaces.width
                height: 30

                // these anchors make sure the item falls back into place after being dropped
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                // give the entries an alternating background color
                color: index%2==0 ? "#88000000" : "#44000000"

                // the icon for this entry (e.g., folder, ...)
                Item {

                    id: entryicon

                    // its size is square (height==width)
                    width: dragRect.height
                    height: width

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        // not shown for first entry (first entry is category title)
                        visible: index>0

                        // the image icon is taken from image loader (i.e., from system theme if available)
                        source: "image://icon/" + icon

                    }

                }

                // The text of each entry
                Text {

                    id: entrytextUser

                    // size and position
                    anchors.fill: parent
                    anchors.leftMargin: entryicon.width

                    // vertically center text
                    verticalAlignment: Qt.AlignVCenter

                    // some styling
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight

                    //: This is the category title of user set folders (or favorites) in the element for opening files
                    text: index==0 ? em.pty+qsTr("Places") : (folder != undefined ? folder : "")
                }

                // mouse area handling clicks and drag
                ToolTip {

                    id: mouseArea

                    // fills full entry
                    anchors.fill: parent

                    text: entrytextUser.text

                    // some properties
                    hoverEnabled: true
                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: index>0

                    // entering the area sets entry as current item
                    onEntered: userPlaces.currentIndex = index

                    // clicking an entry loads the location or shows a context menu (depends on which button was used)
                    onClicked: {
                        if(mouse.button == Qt.LeftButton)
                            openvariables.currentDirectory = path
                        else
                            delegcontext.popup()
                    }

                    // this enables dragging the entry
                    drag.target: dragRect

                    // if drag is started
                    drag.onActiveChanged: {
                        if (mouseArea.drag.active) {
                            // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                            userPlaces.dragItemIndex = index;
                            splitview.dragSource = "userplaces"
                        }
                        dragRect.Drag.drop();
                    }
                }

                // A context menu for removing an item from the list of userplaces
                // so far this is the only context menu item there is
                PContextMenu {

                    id: delegcontext

                    Component.onCompleted:
                        //: Remove an entry from the list of user places (or favorites) in the element for opening files
                        addItem(em.pty+qsTr("Remove entry"))

                    onSelectedIndexChanged: {
                        // Remove from model. We use the myIndex property as this signal passes on a variable that is also named 'index'
                        userPlaces.model.remove(userPlacesDelegate.myIndex)

                        // and save the changes to file
                        Handle.saveUserPlaces()
                    }

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
                Drag.hotSpot.x: dragRect.width / 3
                Drag.hotSpot.y: 10

            }

            // hovering over an item shows a marker line (above and) below
            Rectangle {

                // full width, height of 1 (thin line) and at bottom
                anchors.top: dragRect.bottom
                width: userPlaces.width
                height: 1

                // white color for good looks
                color: "white"

                // opacity depends on drag/drop and is animated slightly
                opacity: (userplaces_top.hoveringOver==index&&index>0)||(userplaces_top.hoveringOver==index+1&&index==userPlaces.model.count-1)
                visible: opacity!=0
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
            }

        }
    }

    // a scrollbar is always shown (if necessary)
    ScrollBarVertical {
        id: listview_scrollbar
        flickable: userPlaces
        opacityVisible: 0.8
        opacityHidden: 0.8
    }

    // This listview holds the currently connected storage devices (harddrives, usb, ...)
    ListView {

        id: storageinfo

        // displayed at bottom of left pane
        anchors.top: userPlaces.bottom
        width: parent.width
        height: settings.openUserPlacesVolumes ? childrenRect.height : 1

        // visibility depends on settings
        visible: settings.openUserPlacesVolumes

        // no interactivity, all items are always shown
        interactive: false

        // item for highlighing moves fairly fast
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        // if the current index changes, then reset currentIndex for standardlocations and userplaces
        onCurrentIndexChanged:
            handleChangeCurrentIndex("storage")

        // The model is a simple listmodel, not editable by user
        model: ListModel {
            Component.onCompleted: {
                Handle.loadStorageInfo()
            }
        }

        // the item for showing which entry is highlighted
        highlight: Rectangle {

            // it fills the full entry
            width: storageinfo.width
            height: 30

            // slight white background signals highlighted entry
            color: "#88ffffff"

        }

        // This is the component that makes up each file entry of the storageinfo category
        delegate: Item {

            // full width, fixed height of 30
            width: storageinfo.width
            height: 30

            // A rectangle for each of the items
            Rectangle {

                // full width and height
                width: storageinfo.width
                height: 30

                // give the entries an alternating background color
                color: index%2==0 ? "#88000000" : "#44000000"

                // This item holds the icon for the folders
                Item {

                    id: iconitemstorage

                    // its size is square (height==width)
                    width: parent.height
                    height: width

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        // not shown for first entry (first entry is category title)
                        visible: index>0

                        // the location icon taken from image loader (i.e., from system theme if available)
                        source: "image://icon/" + icon

                    }

                }

                // The text of each entry
                Text {

                    id: entrytextStorage

                    // size and position
                    anchors.fill: parent
                    anchors.leftMargin: iconitemstorage.width

                    // vertically center text
                    verticalAlignment: Qt.AlignVCenter

                    // some styling
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight

                    //: This is the category title of storage devices to open (like USB keys) in the element for opening files
                    text: index==0 ? em.pty+qsTr("Storage devices") : (name!=undefined ? name : "")

                }

                // mouse area handles changes to currentIndex and clicked events
                ToolTip {

                    // a click everywhere works
                    anchors.fill: parent

                    text: entrytextStorage.text

                    // some properties
                    hoverEnabled: true
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                    // entering the area sets entry as current item
                    onEntered: storageinfo.currentIndex = index

                    // clicking an entry loads the location
                    onClicked: openvariables.currentDirectory = location

                }

            }

        }
    }

    // This context menu is shown by default on the background to show/hide categories
    PContextMenu {

        id: headingmenu

        Component.onCompleted: {
            //: The standard/common folders (like Home, Desktop, ...)
            addItem(em.pty+qsTr("Show standard locations"))
            setCheckable(0, true)
            setChecked(0, settings.openUserPlacesStandard)
            //: The user set folders (or favorites) in the element for opening files
            addItem(em.pty+qsTr("Show user locations"))
            setCheckable(1, true)
            setChecked(1, settings.openUserPlacesUser)
            //: The storage devices (like USB keys)
            addItem(em.pty+qsTr("Show devices"))
            setCheckable(2, true)
            setChecked(2, settings.openUserPlacesVolumes)
        }

        onCheckedChanged: {
            if(index == 0)
                settings.openUserPlacesStandard = checked
            else if(index == 1)
                settings.openUserPlacesUser = checked
            else if(index == 2)
                settings.openUserPlacesVolumes = checked

            if(!isChecked(0) && !isChecked(1) && !isChecked(2))
                settings.openHideUserPlaces = true
        }

    }

    // React to shortcut events
    Connections {
        target: openfile_top
        onHighlightEntry:
            highlightEntry(distance)
        onHighlightFirst:
            highlightFirst()
        onHighlightLast:
            highlightLast()
        onLoadEntry:
            loadHighlightedItem()
        onWidthChanged: {
            // if window is small, user pane is visible and hasn been hidden already: hide it
            if(openfile_top.width < minimisedThreshold && !settings.openHideUserPlaces && !tmpOpenHideUserPlaces)  {
                tmpOpenHideUserPlaces = true
                settings.openHideUserPlaces = true
            // If window is large enough and has been hidden automatically: show it
            } else if(openfile_top.width >= minimisedThreshold && tmpOpenHideUserPlaces) {
                tmpOpenHideUserPlaces = false
                settings.openHideUserPlaces = false
            }
        }
    }

    // Only one of the three categories can have a highlight at any given time. Gives the illusion of one big listview instead of the three ones
    function handleChangeCurrentIndex(source) {

        verboseMessage("OpenFile/UserPlaces", "handleChangeCurrentIndex(): " + source)

        // currentIndex of standardlocations has changed
        if(source === "standard") {

            // this likely means that the currentIndex was unset (set to -1) -> do nothing
            if(standardlocations.currentIndex == -1) return

            // the category title cannot be highlighted, automatically chooses the next entry
            if(standardlocations.currentIndex == 0)
                standardlocations.currentIndex = 1

            // unset currentIndex of other two categories
            userPlaces.currentIndex = -1
            storageinfo.currentIndex = -1

            // set focus on left pane
            openvariables.currentFocusOn = "userplaces"

        // currentIndex of userplaces has changed
        } else if(source === "userplaces") {

            // this likely means that the currentIndex was unset (set to -1) -> do nothing
            if(userPlaces.currentIndex == -1) return

            // the category title cannot be highlighted, automatically chooses the next entry
            if(userPlaces.currentIndex == 0)
                userPlaces.currentIndex = 1

            // unset currentIndex of other two categories
            standardlocations.currentIndex = -1
            storageinfo.currentIndex = -1

            // set focus on left pane
            openvariables.currentFocusOn = "userplaces"

        // currentIndex of storageinfo has changed
        } else if(source === "storage") {

            // this likely means that the currentIndex was unset (set to -1) -> do nothing
            if(storageinfo.currentIndex == -1) return

            // the category title cannot be highlighted, automatically chooses the next entry
            if(storageinfo.currentIndex == 0)
                storageinfo.currentIndex = 1

            // unset currentIndex of other two categories
            standardlocations.currentIndex = -1
            userPlaces.currentIndex = -1

            // set focus on left pane
            openvariables.currentFocusOn = "userplaces"
        }

    }

    // highlight the first entry
    function highlightFirst() {

        // check if we have focus
        if(openvariables.currentFocusOn != "userplaces") return

        verboseMessage("OpenFile/UserPlaces", "highlightFirst()")

        // we go from top down: standardstandardlocations -> userplaces -> storageinfo
        // the first one visible gets its first entry highlighted
        if(standardlocations.visible)
            standardlocations.currentIndex = 1
        else if(userPlaces.visible && userPlaces.model.count > 1)
            userPlaces.currentIndex = 1
        else if(storageinfo.visible && storageinfo.model.count > 1)
            storageinfo.currentIndex = 1
    }

    function highlightLast() {

        // check if we have focus
        if(openvariables.currentFocusOn != "userplaces") return

        verboseMessage("OpenFile/UserPlaces", "highlightLast()")

        // we go from bottom up: storageinfo -> userplaces -> standardstandardlocations
        // the first one visible gets its last entry highlighted
        if(storageinfo.visible && storageinfo.model.count > 1)
            storageinfo.currentIndex = storageinfo.model.count-1
        else if(userPlaces.visible && userPlaces.model.count > 1)
            userPlaces.currentIndex = userPlaces.model.count-1
        else if(standardlocations.visible)
            standardlocations.currentIndex = standardlocations.model.count-1
    }

    // highlight an entry up or down (at given distance)
    function highlightEntry(distance) {

        // check if we have focus
        if(openvariables.currentFocusOn != "userplaces") return

        verboseMessage("OpenFile/UserPlaces", "highlightEntry(): " + distance)

        // >0 means go down
        if(distance > 0) {

            // move from standard to userplaces
            if(standardlocations.currentIndex != -1 && userPlaces.visible && standardlocations.currentIndex+distance > standardlocations.model.count-1
                    && standardlocations.currentIndex-1+distance < (standardlocations.model.count-1)+(userPlaces.model.count-1)) {
                userPlaces.currentIndex = Math.min(1 + ((standardlocations.currentIndex+distance) - standardlocations.model.count), userPlaces.model.count-1)
                return
            }

            // move from standard to storageinfo (userplaces too short)
            if(standardlocations.currentIndex != -1 && userPlaces.visible && storageinfo.visible &&
                    standardlocations.currentIndex+distance > (standardlocations.model.count-1)+(userPlaces.model.count-1)) {
                storageinfo.currentIndex = Math.min(2 + ((standardlocations.currentIndex+distance) - standardlocations.model.count-userPlaces.model.count), storageinfo.model.count-1)
                return
            }

            // move from standard to storageinfo (no userplaces)
            if(standardlocations.currentIndex != -1 && !userPlaces.visible && storageinfo.visible && standardlocations.currentIndex+distance > standardlocations.model.count-1) {
                storageinfo.currentIndex = Math.min(1 + ((standardlocations.currentIndex+distance) - standardlocations.model.count), storageinfo.model.count-1)
                return
            }

            // move from userplaces to storageinfo
            if(userPlaces.currentIndex != -1 && storageinfo.visible && userPlaces.currentIndex+distance > userPlaces.model.count-1) {
                storageinfo.currentIndex = Math.min(1 + ((userPlaces.currentIndex+distance) - userPlaces.model.count), storageinfo.model.count)
                return
            }

            // move inside standard
            if(standardlocations.currentIndex != -1) {
                standardlocations.currentIndex = Math.min(standardlocations.currentIndex+distance, standardlocations.model.count-1)
                return
            }

            // move inside userplaces
            if(userPlaces.currentIndex != -1) {
                if(userPlaces.currentIndex == userPlaces.model.count-1)
                    return
                // since we have to skip the not visible items, we count any visible item we find
                while(distance > 0) {
                    userPlaces.currentIndex += 1
                    if(userPlaces.model.get(userPlaces.currentIndex).notvisible==="0")
                        distance -= 1
                    if(userPlaces.currentIndex == userPlaces.model.count-1)
                        distance = 0
                }
                return
            }

            // move inside storageinfo
            if(storageinfo.currentIndex != -1) {
                storageinfo.currentIndex = Math.min(storageinfo.currentIndex+distance, storageinfo.model.count-1)
                return
            }

        // <0 means go up
        } else {

            distance *= -1

            // move from userplaces to standard
            if(userPlaces.currentIndex != -1 && standardlocations.visible && userPlaces.currentIndex-distance < 1) {
                standardlocations.currentIndex = Math.max(standardlocations.count-1 - (distance-userPlaces.currentIndex), 1)
                return
            }

            // move from storageinfo to standard (userplaces too short)
            if(storageinfo.currentIndex != -1 && userPlaces.visible && standardlocations.visible && storageinfo.currentIndex-distance-1 < 1 &&
                    userPlaces.model.count-1-(distance-storageinfo.currentIndex) < 1) {
                standardlocations.currentIndex = Math.max(standardlocations.count-1 - ((distance-storageinfo.currentIndex) - (userPlaces.model.count-1)), 1)
                return
            }

            // move from storageinfo to standard (no userplaces)
            if(storageinfo.currentIndex != -1 && !userPlaces.visible && standardlocations.visible && storageinfo.currentIndex-distance < 1) {
                standardlocations.currentIndex = Math.max(standardlocations.count-1 - (distance-storageinfo.currentIndex), 1)
                return
            }

            // move from storageinfo to userplaces
            if(storageinfo.currentIndex != -1 && userPlaces.visible && storageinfo.currentIndex-distance < 1) {
                userPlaces.currentIndex = Math.max(userPlaces.count-1 - (distance-storageinfo.currentIndex), 1)
                return
            }

            // move inside standard
            if(standardlocations.currentIndex != -1) {
                standardlocations.currentIndex = Math.max(standardlocations.currentIndex-distance, 1)
                return
            }

            // move inside userplaces
            if(userPlaces.currentIndex != -1) {
                // since we have to skip the not visible items, we count any visible item we find
                while(distance > 0) {
                    userPlaces.currentIndex -= 1
                    if(userPlaces.model.get(userPlaces.currentIndex).notvisible==="0")
                        distance -= 1
                    if(userPlaces.currentIndex == 1)
                        distance = 0
                }
                return
            }

            // move inside storageinfo
            if(storageinfo.currentIndex != -1) {
                storageinfo.currentIndex = Math.max(storageinfo.currentIndex-distance, 1)
                return
            }

        }

    }

    // Load the entry that is currently highlighted
    function loadHighlightedItem() {

        // check if we have focus
        if(openvariables.currentFocusOn != "userplaces")
            return

        verboseMessage("OpenFile/UserPlaces", "loadHighlightedItem()")

        // load standardlocations location
        if(standardlocations.visible && standardlocations.currentIndex != -1) {

            if(standardlocations.model.get(standardlocations.currentIndex) === undefined)
                return

            openvariables.currentDirectory = standardlocations.model.get(standardlocations.currentIndex).location

        // load userplaces location
        } else if(userPlaces.visible && userPlaces.currentIndex != -1) {

            if(userPlaces.model.get(userPlaces.currentIndex) === undefined)
                return

            openvariables.currentDirectory = userPlaces.model.get(userPlaces.currentIndex).path

        // load storageinfo location
        } else if(storageinfo.visible && storageinfo.currentIndex != -1) {

            if(storageinfo.model.get(storageinfo.currentIndex) === undefined)
                return

            openvariables.currentDirectory = storageinfo.model.get(storageinfo.currentIndex).location

        }

    }

}
