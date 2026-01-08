/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

Item {

    id: places_top

    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height

    onWidthChanged:
        PQCConstants.filedialogPlacesWidth = width

    clip: true

    property list<var> entries_favorites: []
    property list<var> entries_devices: []

    property int dragItemIndex: -1
    property string dragItemId: ""
    property bool dragReordering: false

    property list<int> hoverIndex: [-1,-1,-1]
    property list<int> pressedIndex: [-1,-1,-1]

    property int availableHeight: height - fd_tweaks.zoomMoveUpHeight

    Timer {
        id: resetHoverIndex
        interval: 50
        property list<int> oldIndex: [-1,-1,-1]
        onTriggered: {
            if(places_top.hoverIndex[0] === oldIndex[0])
                places_top.hoverIndex[0] = -1
            if(places_top.hoverIndex[1] === oldIndex[1])
                places_top.hoverIndex[1] = -1
            if(places_top.hoverIndex[2] === oldIndex[2])
                places_top.hoverIndex[2] = -1
            places_top.hoverIndexChanged()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton|Qt.LeftButton
        onClicked: (mouse) => {
            PQCNotify.filedialogShowAddressEdit(false)
            if(mouse.button === Qt.LeftButton)
                return
            PQCConstants.filedialogPlacesCurrentEntryId = ""
            PQCConstants.filedialogPlacesCurrentEntryHidden = ""
            places_menu.popup()
        }
    }

    PQTextL {
        visible: !view_favorites.visible && !view_devices.visible
        anchors.fill: parent
        anchors.margins: 5
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: palette.disabled.text
        font.italic: true
        text: qsTranslate("filedialog", "bookmarks and devices disabled")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Item {

        id: virtualEntry

        visible: PQCFileFolderModel.virtualFolderContents.length

        x: 5
        y: 5
        width: parent.width-10
        height: 35

        Row {

            x: 5

            Item {
                width: virtualEntry.height
                height: width

                // the icon image
                Image {

                    // fill parent (with margin for better looks)
                    anchors.fill: parent
                    anchors.margins: 5

                    sourceSize: Qt.size(width, height)

                    // the image icon is taken from image loader (i.e., from system theme if available)
                    source: "image://theme/folder"

                }

            }

            // The text of each entry
            Row {

                height: virtualEntry.height

                PQText {

                    id: entrytext

                    width: virtualEntry.width-virtualEntry.height-10
                    height: virtualEntry.height

                    // vertically center text
                    verticalAlignment: Qt.AlignVCenter

                    // some styling
                    elide: Text.ElideRight
                    font.weight: PQCLook.fontWeightNormal
                    font.italic: true

                    text: qsTranslate("filedialog", "virtual folder")

                }

            }

        }

        PQHighlightMarker {
            opacity: virtualMouse.containsMouse ? 1 : 0.8
            visible: virtualMouse.containsMouse || PQCFileFolderModel.folderFileDialog==="::virtual::"
        }

        PQMouseArea {

            id: virtualMouse

            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: {
                PQCNotify.filedialogShowAddressEdit(false)
                filedialog_top.loadNewPath("::virtual::")
            }

        }

    }

    ListView {

        id: view_favorites

        x: 5
        y: (virtualEntry.visible ? virtualEntry.y+virtualEntry.height : 0) + 5
        width: parent.width-10
        height: parent.height - (view_devices.visible ? (view_devices.height+10) : 0) - fd_tweaks.zoomMoveUpHeight - (virtualEntry.visible ? virtualEntry.height : 0)

        clip: true
        visible: PQCSettings.filedialogPlaces
        orientation: ListView.Vertical
        model: places_top.entries_favorites

        delegate: viewcomponent_favs

        DropArea {

            id: droparea

            anchors.fill: parent

            onDropped: {

                if(!PQCScriptsFilesPaths.isFolder(places_top.dragItemId) && !places_top.dragReordering)
                    return

                // find the index on which it was dropped
                var newindex = view_favorites.indexAt(drag.x, drag.y+view_favorites.contentY)

                // not moved, leave in place
                if(newindex === -1)
                    return

                if(newindex === 0)
                    newindex = 1

                // if drag/drop originated from folders panel
                if(!places_top.dragReordering) {

                    // add item at right position
                    PQCScriptsFileDialog.addPlacesEntry(places_top.dragItemId, newindex)

                    // and reload places
                    places_top.loadPlaces()

                // if drag/drop originated from userplaces (reordering)
                } else {

                    // if item was moved (if left in place nothing needs to be done)
                    if(places_top.dragItemIndex !== newindex) {

                        // save the changes to file
                        PQCScriptsFileDialog.movePlacesEntry(places_top.dragItemId, places_top.dragItemIndex<newindex, Math.abs(places_top.dragItemIndex-newindex))

                        // and reload places
                        places_top.loadPlaces()

                    }

                }

            }

            onPositionChanged: {

                if(!PQCScriptsFilesPaths.isFolder(places_top.dragItemId) && !places_top.dragReordering)
                    return

                var ind = view_favorites.indexAt(droparea.drag.x, droparea.drag.y)
                // the first entry is the heading -> ignore
                if(ind === 0)
                    ind = 1
                places_top.hoverIndex[1] = ind
                places_top.hoverIndexChanged()
            }

        }

    }

    Rectangle {

        id: devpla_sep

        y: view_devices.y-5
        width: parent.width
        height: 1

        visible: view_favorites.visible && view_devices.visible
        color: palette.alternateBase
    }

    ListView {
        id: view_devices
        x: 5
        y: view_favorites.visible ? (parent.height-height-fd_tweaks.zoomMoveUpHeight) : 5
        width: parent.width-10
        height: Math.min(300, childrenRect.height)
        visible: PQCSettings.filedialogDevices
        clip: true
        orientation: ListView.Vertical
        model: places_top.entries_devices
        delegate: viewcomponent_devices
    }

    Component {

        id: viewcomponent_favs

        Item {

            id: deleg

            required property int index
/*1off_Qt64
            property string folder: places_top.entries_favorites[index]['folder']
            property string path: places_top.entries_favorites[index]['path']
            property string icon: places_top.entries_favorites[index]['icon']
            property string theid: places_top.entries_favorites[index]['theid']
            property string hidden: places_top.entries_favorites[index]['hidden']
2off_Qt64*/
/*1on_Qt65+*/
            required property string folder
            required property string path
            required property string icon
            required property string theid
            required property string hidden
/*2on_Qt65+*/

            width: parent.width
            height: (hidden==="false"||PQCConstants.filedialogPlacesShowHidden) ? 35 : 0
            opacity: (hidden==="false") ? 1 : 0.5
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

            Connections {
                target: PQCConstants
                function onWhichContextMenusOpenChanged() {
                    deleg.currentContextMenu = PQCConstants.isContextmenuOpen("fileviewplaces") && PQCConstants.filedialogPlacesCurrentEntryId===deleg.theid
                }
            }

            property bool currentContextMenu: false

            PQHighlightMarker {
                opacity: deleg.markDown||deleg.markHovered ? 1 : 0.8
                visible: deleg.markCurrent||deleg.markHovered||deleg.markDown
            }

            property bool markCurrent: path===PQCFileFolderModel.folderFileDialog
            property bool markHovered: places_top.hoverIndex[1]===index||mouseArea.drag.active||currentContextMenu
            property bool markDown: places_top.pressedIndex[1]===index||mouseArea.drag.active||currentContextMenu

            Row {

                x: 5

                Item {

                    id: entryicon

                    opacity: 1

                    // its size is square (height==width)
                    width: deleg.height
                    height: width

                    // not shown for first entry (first entry is category title)
                    visible: deleg.index>0

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        sourceSize: Qt.size(width, height)

                        // the image icon is taken from image loader (i.e., from system theme if available)
                        source: (deleg.index>0 ? ("image://theme/" + deleg.icon) : "")

                    }

                }

                // The text of each entry
                Row {

                    height: deleg.height

                    PQText {

                        id: entrytext

                        width: deleg.width-entryicon.width-10
                        height: deleg.height

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        enabled: deleg.index>0

                        // some styling
                        elide: Text.ElideRight
                        font.weight: deleg.index===0 ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
                        color: enabled ? palette.text : palette.disabled.text

                        text: PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.folder)

                    }

                }

            }

            // mouse area handling clicks
            PQMouseArea {

                id: mouseArea

                // fills full entry
                anchors.fill: parent

                // some properties
                hoverEnabled: true
                acceptedButtons: Qt.RightButton|Qt.LeftButton
                cursorShape: deleg.index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                tooltip: deleg.index===0 ? "" : PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.path)

                onPressed: {
                    PQCNotify.filedialogShowAddressEdit(false)
                    places_top.pressedIndex[1] = deleg.index
                    places_top.pressedIndexChanged()
                }
                onReleased: {
                    places_top.pressedIndex[1] = -1
                    places_top.pressedIndexChanged()
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: (mouse) => {

                    PQCNotify.filedialogShowAddressEdit(false)

                    if(deleg.index == 0)
                        return

                    if(mouse.button === Qt.LeftButton)
                        filedialog_top.loadNewPath(deleg.path)
                    else {
                        if(deleg.index!==0) {
                            PQCConstants.filedialogPlacesCurrentEntryId = deleg.theid
                            PQCConstants.filedialogPlacesCurrentEntryHidden = deleg.hidden
                        } else {
                            PQCConstants.filedialogPlacesCurrentEntryId = ""
                            PQCConstants.filedialogPlacesCurrentEntryHidden = ""
                        }
                        places_menu.popup()
                    }
                }

                onEntered: {
                    places_top.hoverIndex[1] = (deleg.index>0 ? deleg.index : -1)
                    places_top.hoverIndexChanged()
                }
                onExited: {
                    resetHoverIndex.oldIndex[1] = deleg.index
                    resetHoverIndex.start()
                }


                drag.target: (PQCSettings.filedialogDragDropPlaces&&deleg.index>0) ? deleg : undefined
                drag.axis: Drag.YAxis

                // if drag is started
                drag.onActiveChanged: {
                    if(mouseArea.drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        places_top.dragItemIndex = deleg.index
                        places_top.dragItemId = deleg.theid
                        places_top.dragReordering = true
                    }
                    deleg.Drag.drop();
                    if(!mouseArea.drag.active) {
                        // reset variables used for drag/drop
                        places_top.dragItemIndex = -1
                        places_top.dragItemId = ""
                        places_top.dragReordering = false
                    }
                }

            }

            Drag.active: mouseArea.drag.active
            Drag.hotSpot.x: width/2
            Drag.hotSpot.y: -1

            states: [
                State {
                    // when drag starts, reparent entry to splitview
                    when: deleg.Drag.active
                    ParentChange {
                        target: deleg
                        parent: places_top
                    }
                    // (temporarily) remove anchors
                    AnchorChanges {
                        target: deleg
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: undefined
                    }
                }
            ]

        }
    }

    Component {

        id: viewcomponent_devices

        Item {

            id: deleg

            required property int index
/*1off_Qt64
            property string folder: places_top.entries_devices[index]['folder']
            property string path: places_top.entries_devices[index]['path']
            property string fstype: places_top.entries_devices[index]['fstype']
            property string fssize: places_top.entries_devices[index]['fssize']
2off_Qt64*/
/*1on_Qt65+*/
            required property string folder
            required property string path
            required property string fstype
            required property string fssize
/*2on_Qt65+*/

            width: parent.width
            height: 35
            opacity: 1

            PQHighlightMarker {
                opacity: deleg.markDown||deleg.markHovered ? 1 : 0.8
                visible: deleg.markCurrent||deleg.markHovered||deleg.markDown
            }

            property bool markCurrent: path===PQCFileFolderModel.folderFileDialog
            property bool markHovered: places_top.hoverIndex[2]===index
            property bool markDown: places_top.pressedIndex[2]===index

            Row {

                x: 5

                Item {

                    id: entryicon

                    opacity: 1

                    // its size is square (height==width)
                    width: deleg.height
                    height: width

                    // not shown for first entry (first entry is category title)
                    visible: deleg.index>0

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 5

                        sourceSize: Qt.size(width, height)

                        // the image icon is taken from image loader (i.e., from system theme if available)
                        source: (deleg.index>0 ? "image://theme/drive-harddisk" : "")

                    }

                }

                // The text of each entry
                Row {

                    height: deleg.height

                    PQText {

                        id: entrytext

                        width: deleg.width-entryicon.width-(entrysize.visible ? entrysize.width : 0)-10
                        height: deleg.height

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        enabled: deleg.index>0

                        // some styling
                        elide: Text.ElideRight
                        font.weight: deleg.index===0 ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
                        color: enabled ? palette.text : palette.disabled.text

                        text: PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.folder)

                    }

                    PQText {

                        id: entrysize

                        visible: deleg.index>0
                        height: deleg.height

                        color: palette.text

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        text: PQCScriptsFilesPaths.convertBytesToGB(deleg.fssize) + " GB"

                    }

                }

            }

            // mouse area handling clicks
            PQMouseArea {

                id: mouseArea

                // fills full entry
                anchors.fill: parent

                // some properties
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: deleg.index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                tooltip: deleg.index===0 ? "" : (PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.path) + " <i>(" + deleg.fstype + ")</i><br>" + entrysize.text)

                onPressed: {
                    PQCNotify.filedialogShowAddressEdit(false)
                    places_top.pressedIndex[2] = deleg.index
                    places_top.pressedIndexChanged()
                }
                onReleased: {
                    places_top.pressedIndex[2] = -1
                    places_top.pressedIndexChanged()
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: (mouse) => {

                    PQCNotify.filedialogShowAddressEdit(false)

                    if(deleg.index == 0)
                        return

                    filedialog_top.loadNewPath(deleg.path)

                }

                onEntered: {
                    places_top.hoverIndex[2] = (deleg.index>0 ? deleg.index : -1)
                    places_top.hoverIndexChanged()
                }
                onExited: {
                    resetHoverIndex.oldIndex[2] = deleg.index
                    resetHoverIndex.start()
                }

            }
        }
    }

    PQMenu {

        id: places_menu

        PQMenuItem {
            id: entry1
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (PQCConstants.filedialogPlacesCurrentEntryHidden==="true" ? qsTranslate("filedialog", "Show entry") : qsTranslate("filedialog", "Hide entry"))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry1.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.hidePlacesEntry(PQCConstants.filedialogPlacesCurrentEntryId, PQCConstants.filedialogPlacesCurrentEntryHidden==="false")
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            id: entry2
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (qsTranslate("filedialog", "Remove entry"))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry2.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.deletePlacesEntry(PQCConstants.filedialogPlacesCurrentEntryId)
                PQCNotify.filedialogReloadPlaces()
            }
        }

        PQMenuItem {
            id: entry3
            visible: PQCConstants.filedialogPlacesCurrentEntryId!==""
            text: (PQCConstants.filedialogPlacesShowHidden ? (qsTranslate("filedialog", "Hide hidden entries")) : (qsTranslate("filedialog", "Show hidden entries")))
            states: [
                State {
                    when: PQCConstants.filedialogPlacesCurrentEntryId===""
                    PropertyChanges {
                        entry3.height: 0
                    }
                }
            ]
            onTriggered:
            PQCConstants.filedialogPlacesShowHidden = !PQCConstants.filedialogPlacesShowHidden
        }

        PQMenuSeparator { visible: PQCConstants.filedialogPlacesCurrentEntryId!=="" }

        PQMenuItem {
            text: (PQCSettings.filedialogPlaces ? (qsTranslate("filedialog", "Hide bookmarked places")) : (qsTranslate("filedialog", "Show bookmarked places")))
            onTriggered:
            PQCSettings.filedialogPlaces = !PQCSettings.filedialogPlaces
        }

        PQMenuItem {
            text: (PQCSettings.filedialogDevices ? (qsTranslate("filedialog", "Hide storage devices")) : (qsTranslate("filedialog", "Show storage devices")))
            onTriggered:
            PQCSettings.filedialogDevices = !PQCSettings.filedialogDevices
        }

        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("fileviewplaces")
        }

        onAboutToHide: {
            PQCConstants.removeFromWhichContextMenusOpen("fileviewplaces")
        }

    }

    Connections {
        target: PQCSettings
        function onFiledialogDevicesShowTmpfsChanged() {
            places_top.loadDevices()
        }
    }

    Connections {
        target: PQCNotify
        function onFiledialogReloadPlaces() {
            places_top.loadPlaces()
        }
    }

    Component.onCompleted: {
        places_top.loadPlaces()
        places_top.loadDevices()
    }

    function loadDevices() {

        var s = PQCScriptsFileDialog.getDevices()

        entries_devices = []

        // for the heading
        entries_devices.push({"index" : 0,
                  "folder" : qsTranslate("filedialog", "Storage Devices"),
                  "path" : "",
                  "fstype" : "",
                  "fssize" : 0})

        for(var i = 0; i < s.length; i+=4) {

            console.warn(">>>", s[i], s[i+1], s[i+2], s[i+3])

            entries_devices.push({"index" : i+1,
                      "folder" : s[i],           // folder
                      "path" : s[i+3],           // path
                      "fstype" : s[i+2],         // file system type
                      "fssize" : s[i+1]})        // file system size

        }

        entries_devicesChanged()

    }

    function loadPlaces() {

        var upl = PQCScriptsFileDialog.getPlaces()

        entries_favorites = []

        // for the heading
        entries_favorites.push({"index" : 0,
                                "folder" : qsTranslate("filedialog", "Bookmarks"),
                                "path" : "",
                                "icon" : "",
                                "theid" : "",
                                "hidden" : "false"})

        for(var i = 0; i < upl.length; i+=5) {
            entries_favorites.push({"index" : i+1,
                                    "folder" : upl[i],    // folder
                                    "path" : upl[i+1],    // path
                                    "icon" : upl[i+2],    // icon
                                    "theid" : upl[i+3],   // id
                                    "hidden" : upl[i+4]}) // hidden
        }

        entries_favoritesChanged()

    }

}
