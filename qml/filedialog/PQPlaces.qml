pragma ComponentBehavior: Bound
/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsFileDialog

import "../elements"

Item {

    id: places_top

    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height // qmllint disable unqualified

    clip: true

    property list<var> entries_favorites: []
    property list<var> entries_devices: []

    property list<var> entries: [[], entries_favorites, entries_devices]

    property int dragItemIndex: -1
    property string dragItemId: ""
    property bool dragReordering: false

    property list<int> hoverIndex: [-1,-1,-1]
    property list<int> pressedIndex: [-1,-1,-1]

    property int availableHeight: height - fd_tweaks.zoomMoveUpHeight // qmllint disable unqualified

    property bool showHiddenPlaces: false

    property alias context: contextmenu

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
            fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified
            if(mouse.button === Qt.LeftButton)
                return
            contextmenu.currentEntryId = ""
            contextmenu.currentEntryHidden = ""
            contextmenu.popup()
        }
    }

    PQTextL {
        visible: !view_favorites.visible && !view_devices.visible
        anchors.fill: parent
        anchors.margins: 5
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: PQCLook.textColorDisabled // qmllint disable unqualified
        font.italic: true
        text: qsTranslate("filedialog", "bookmarks and devices disabled")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Flickable {

        id: flickable
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: fd_tweaks.zoomMoveUpHeight // qmllint disable unqualified

        contentHeight: col.height

        ScrollBar.vertical: PQVerticalScrollBar { id: scrollbar }

        Column {

            id: col

            width: parent.width - (scrollbar.size<1.0 ? 6 : 0)

            ListView {
                id: view_favorites
                width: parent.width-5
                height: contentHeight
                clip: true
                visible: PQCSettings.filedialogPlaces // qmllint disable unqualified
                orientation: ListView.Vertical
                model: places_top.entries_favorites.length
                property int part: 1
                delegate: viewcomponent
                boundsBehavior: Flickable.StopAtBounds

                DropArea {

                    id: droparea

                    anchors.fill: parent

                    onDropped: {

                        if(!PQCScriptsFilesPaths.isFolder(places_top.dragItemId) && !places_top.dragReordering) // qmllint disable unqualified
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

                        if(!PQCScriptsFilesPaths.isFolder(places_top.dragItemId) && !places_top.dragReordering) // qmllint disable unqualified
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

            Item {
                width: parent.width
                height: 20
                visible: view_favorites.visible && view_devices.visible
                Rectangle {
                    y: 19
                    width: parent.width
                    height: 1
                    color: PQCLook.baseColorActive // qmllint disable unqualified
                }
            }

            ListView {
                id: view_devices
                width: parent.width-5
                height: contentHeight
                visible: PQCSettings.filedialogDevices // qmllint disable unqualified
                clip: true
                orientation: ListView.Vertical
                model: places_top.entries_devices.length
                property int part: 2
                delegate: viewcomponent
                boundsBehavior: Flickable.StopAtBounds
            }

        }

    }

    Component {

        id: viewcomponent

        Rectangle {

            id: deleg

            required property int modelData

            width: parent.width
            height: (hidden==="false"||places_top.showHiddenPlaces) ? 35 : 0
            opacity: (hidden==="false") ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }

            property int part: mouseArea.drag.active ? 1 : parent.parent.part // qmllint disable missing-property
            property var entry: places_top.entries[part][modelData]
            property string hidden: entry===undefined||entry[4]===undefined||part==2 ? "false" : entry[4]

            color: places_top.hoverIndex[part]===modelData
                        ? (places_top.pressedIndex[part]===modelData ? PQCLook.baseColorActive : PQCLook.baseColorHighlight) // qmllint disable unqualified
                        : (entry!==undefined && entry[1]===PQCFileFolderModel.folderFileDialog ? PQCLook.baseColorAccent : PQCLook.baseColor)
            Behavior on color { ColorAnimation { duration: 200 } }

            Row {

                x: 5

                Item {

                    id: entryicon

                    opacity: 1

                    // its size is square (height==width)
                    width: deleg.height
                    height: width

                    // not shown for first entry (first entry is category title)
                    visible: deleg.modelData>0

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 3

                        sourceSize: Qt.size(width, height)

                        // the image icon is taken from image loader (i.e., from system theme if available)
                        source: ((deleg.entry!==undefined&&deleg.modelData>0) ? ("image://theme/" + deleg.entry[2]) : "")

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

                        enabled: deleg.modelData>0

                        // some styling
                        elide: Text.ElideRight
                        font.weight: deleg.modelData===0 ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal // qmllint disable unqualified

                        text: deleg.entry===undefined ? "" : PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.entry[0]) // qmllint disable unqualified

                    }

                    PQText {

                        id: entrysize

                        visible: deleg.part==2 && deleg.modelData>0
                        height: deleg.height

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        text: deleg.entry===undefined ? "" : (deleg.entry[3] + " GB") // qmllint disable unqualified

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
                cursorShape: deleg.modelData > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                tooltipReference: fd_splitview // qmllint disable unqualified
                text: (deleg.modelData===0 || deleg.entry === undefined) ? "" : (PQCScriptsFilesPaths.pathWithNativeSeparators(deleg.entry[1]) + (deleg.part == 2 ? ("<br>"+entrysize.text + " (" + deleg.entry[4] + ")") : "")) // qmllint disable unqualified

                onPressed: {
                    fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified
                    places_top.pressedIndex[deleg.part] = deleg.modelData
                    places_top.pressedIndexChanged()
                }
                onReleased: {
                    places_top.pressedIndex[deleg.part] = -1
                    places_top.pressedIndexChanged()
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: (mouse) => {

                    fd_breadcrumbs.disableAddressEdit() // qmllint disable unqualified

                    if(deleg.modelData == 0)
                        return

                    if(mouse.button === Qt.LeftButton)
                        filedialog_top.loadNewPath(deleg.entry[1])
                    else {
                        if(deleg.part == 1 && deleg.modelData!==0) {
                            contextmenu.currentEntryId = deleg.entry[3]
                            contextmenu.currentEntryHidden = deleg.entry[4]
                        } else {
                            contextmenu.currentEntryId = ""
                            contextmenu.currentEntryHidden = ""
                        }

                        contextmenu.popup()
                    }
                }

                onEntered: {
                    places_top.hoverIndex[deleg.part] = (deleg.modelData>0 ? deleg.modelData : -1)
                    places_top.hoverIndexChanged()
                }
                onExited: {
                    resetHoverIndex.oldIndex[deleg.part] = deleg.modelData
                    resetHoverIndex.start()
                }


                drag.target: (deleg.part==1&&PQCSettings.filedialogDragDropPlaces&&deleg.modelData>0) ? deleg : undefined // qmllint disable unqualified
                drag.axis: Drag.YAxis

                // if drag is started
                drag.onActiveChanged: {
                    if(mouseArea.drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        places_top.dragItemIndex = deleg.modelData
                        places_top.dragItemId = deleg.entry[3]
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

    PQMenu {
        id: contextmenu

        property string currentEntryHidden: ""
        property string currentEntryId: ""

        PQMenuItem {
            id: entry1
            visible: contextmenu.currentEntryId!==""
            text: (contextmenu.currentEntryHidden=="true" ? qsTranslate("filedialog", "Show entry") : qsTranslate("filedialog", "Hide entry"))
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        entry1.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.hidePlacesEntry(contextmenu.currentEntryId, contextmenu.currentEntryHidden==="false") // qmllint disable unqualified
                places_top.loadPlaces()
            }
        }

        PQMenuItem {
            id: entry2
            visible: contextmenu.currentEntryId!==""
            text: (qsTranslate("filedialog", "Remove entry"))
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        entry2.height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.deletePlacesEntry(contextmenu.currentEntryId) // qmllint disable unqualified
                places_top.loadPlaces()
            }
        }

        PQMenuItem {
            id: entry3
            visible: contextmenu.currentEntryId!==""
            text: (places_top.showHiddenPlaces ? (qsTranslate("filedialog", "Hide hidden entries")) : (qsTranslate("filedialog", "Show hidden entries")))
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        entry3.height: 0
                    }
                }
            ]
            onTriggered:
                places_top.showHiddenPlaces = !places_top.showHiddenPlaces
        }

        PQMenuSeparator {
            id: sep1
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        sep1.height: 0
                    }
                }
            ]
        }

        PQMenuItem {
            text: (PQCSettings.filedialogPlaces ? (qsTranslate("filedialog", "Hide bookmarked places")) : (qsTranslate("filedialog", "Show bookmarked places"))) // qmllint disable unqualified
            onTriggered:
                PQCSettings.filedialogPlaces = !PQCSettings.filedialogPlaces // qmllint disable unqualified
        }

        PQMenuItem {
            text: (PQCSettings.filedialogDevices ? (qsTranslate("filedialog", "Hide storage devices")) : (qsTranslate("filedialog", "Show storage devices"))) // qmllint disable unqualified
            onTriggered:
                PQCSettings.filedialogDevices = !PQCSettings.filedialogDevices // qmllint disable unqualified
        }
    }

    Connections {
        target: PQCSettings // qmllint disable unqualified
        function onFiledialogDevicesShowTmpfsChanged() {
            places_top.loadDevices()
        }
    }

    // we can load them asynchronously to speed up showing the actual file dialog
    Timer {
        interval: 10
        running: true
        onTriggered: {
            places_top.loadPlaces()
            places_top.loadDevices()
        }
    }

    function loadDevices() {

        var s = PQCScriptsFileDialog.getDevices() // qmllint disable unqualified

        var tmp = []

        // for the heading
        tmp.push([qsTranslate("filedialog", "Storage Devices"), "", "", "", "2"])

        for(var i = 0; i < s.length; i+=4) {

            tmp.push([s[i],             // name
                      s[i+3],           // path
                      "drive-harddisk",
                      Math.round(s[i+1]/1024/1024/1024 +1), // size
                      s[i+2]])          // file system type

        }

        entries_devices = tmp

    }

    function loadPlaces() {

        var upl = PQCScriptsFileDialog.getPlaces() // qmllint disable unqualified

        var tmp = []

        // for the heading
        tmp.push([qsTranslate("filedialog", "Bookmarks"), "", "", "", "1"])

        for(var i = 0; i < upl.length; i+=5)
            tmp.push([upl[i],       // folder
                      upl[i+1],     // path
                      upl[i+2],     // icon
                      upl[i+3],     // id
                      upl[i+4]])    // hidden

        entries_favorites = tmp

    }

}
