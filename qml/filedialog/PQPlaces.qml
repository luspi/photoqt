import QtQuick
import QtCore
import QtQuick.Controls

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsFileDialog

import "../elements"

Item {

    id: places_top

    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height

    clip: true

    property var entries_favorites: []
    property var entries_devices: []

    property var entries: [[], entries_favorites, entries_devices]

    property int dragItemIndex: -1
    property string dragItemId: ""
    property bool dragReordering: false

    property var hoverIndex: [-1,-1,-1]
    property var pressedIndex: [-1,-1,-1]

    property int availableHeight: height - fd_tweaks.zoomMoveUpHeight

    property bool showHiddenPlaces: false

    Timer {
        id: resetHoverIndex
        interval: 50
        property var oldIndex: [-1,-1,-1]
        onTriggered: {
            if(hoverIndex[0] === oldIndex[0])
                hoverIndex[0] = -1
            if(hoverIndex[1] === oldIndex[1])
                hoverIndex[1] = -1
            if(hoverIndex[2] === oldIndex[2])
                hoverIndex[2] = -1
            hoverIndexChanged()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton|Qt.LeftButton
        onClicked: (mouse) => {
            fd_breadcrumbs.disableAddressEdit()
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
        color: PQCLook.textColorHighlight
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
        anchors.bottomMargin: fd_tweaks.zoomMoveUpHeight

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
                visible: PQCSettings.filedialogPlaces
                orientation: ListView.Vertical
                model: entries_favorites.length
                property int part: 1
                delegate: viewcomponent
                boundsBehavior: Flickable.StopAtBounds

                DropArea {

                    id: droparea

                    anchors.fill: parent

                    onDropped: {

                        if(!PQCScriptsFilesPaths.isFolder(dragItemId))
                            return

                        // find the index on which it was dropped
                        var newindex = view_favorites.indexAt(drag.x, drag.y+view_favorites.contentY)

                        // not moved, leave in place
                        if(newindex === -1)
                            return

                        if(newindex === 0)
                            newindex = 1

                        // if drag/drop originated from folders panel
                        if(!dragReordering) {

                            // add item at right position
                            PQCScriptsFileDialog.addPlacesEntry(dragItemId, newindex)

                            // and reload places
                            loadPlaces()

                        // if drag/drop originated from userplaces (reordering)
                        } else {

                            // if item was moved (if left in place nothing needs to be done)
                            if(places_top.dragItemIndex !== newindex) {

                                // save the changes to file
                                PQCScriptsFileDialog.movePlacesEntry(dragItemId, dragItemIndex<newindex, Math.abs(dragItemIndex-newindex))

                                // and reload places
                                loadPlaces()

                            }

                        }

                    }

                    onPositionChanged: {

                        if(!PQCScriptsFilesPaths.isFolder(dragItemId))
                            return

                        var ind = view_favorites.indexAt(droparea.drag.x, droparea.drag.y)
                        // the first entry is the heading -> ignore
                        if(ind === 0)
                            ind = 1
                        hoverIndex[1] = ind
                        hoverIndexChanged()
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
                    color: PQCLook.baseColorActive
                }
            }

            ListView {
                id: view_devices
                width: parent.width-5
                height: contentHeight
                visible: PQCSettings.filedialogDevices
                clip: true
                orientation: ListView.Vertical
                model: entries_devices.length
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

            width: parent.width
            height: (hidden==="false"||showHiddenPlaces) ? 35 : 0
            opacity: (hidden==="false") ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }

            property int part: mouseArea.drag.active ? 1 : parent.parent.part
            property var entry: entries[part][index]
            property string hidden: entry===undefined||entry[4]===undefined||part==2 ? "false" : entry[4]

            color: hoverIndex[part]===index
                        ? (pressedIndex[part]===index ? PQCLook.baseColorActive : PQCLook.baseColorHighlight)
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
                    visible: index>0

                    // the icon image
                    Image {

                        // fill parent (with margin for better looks)
                        anchors.fill: parent
                        anchors.margins: 3

                        sourceSize: Qt.size(width, height)

                        // the image icon is taken from image loader (i.e., from system theme if available)
                        source: ((entry!==undefined&&index>0) ? ("image://theme/" + entry[2]) : "")

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

                        enabled: index>0

                        // some styling
                        elide: Text.ElideRight
                        font.weight: index===0 ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal

                        text: entry===undefined ? "" : PQCScriptsFilesPaths.pathWithNativeSeparators(entry[0])

                    }

                    PQText {

                        id: entrysize

                        visible: deleg.part==2 && index>0
                        height: deleg.height

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        text: entry===undefined ? "" : (entry[3] + " GB")

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
                cursorShape: index > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

                tooltipReference: fd_splitview
                text: index===0 ? "" : (PQCScriptsFilesPaths.pathWithNativeSeparators(entry[1]) + (deleg.part == 2 ? ("<br>"+entrysize.text + " (" + entry[4] + ")") : ""))

                onPressed: {
                    fd_breadcrumbs.disableAddressEdit()
                    pressedIndex[deleg.part] = index
                    pressedIndexChanged()
                }
                onReleased: {
                    pressedIndex[deleg.part] = -1
                    pressedIndexChanged()
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: (mouse) => {

                    fd_breadcrumbs.disableAddressEdit()

                    if(index == 0)
                        return

                    if(mouse.button === Qt.LeftButton)
                        filedialog_top.loadNewPath(deleg.entry[1])
                    else {
                        if(deleg.part == 1 && index!==0) {
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
                    hoverIndex[deleg.part] = (index>0 ? index : -1)
                    hoverIndexChanged()
                }
                onExited: {
                    resetHoverIndex.oldIndex[deleg.part] = index
                    resetHoverIndex.start()
                }


                drag.target: (deleg.part==1&&PQCSettings.filedialogDragDropPlaces&&index>0) ? deleg : undefined
                drag.axis: Drag.YAxis

                // if drag is started
                drag.onActiveChanged: {
                    if(mouseArea.drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        places_top.dragItemIndex = index
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
                        target: entry1
                        height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.hidePlacesEntry(contextmenu.currentEntryId, contextmenu.currentEntryHidden==="false")
                loadPlaces()
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
                        target: entry2
                        height: 0
                    }
                }
            ]
            onTriggered: {
                PQCScriptsFileDialog.deletePlacesEntry(contextmenu.currentEntryId)
                loadPlaces()
            }
        }

        PQMenuItem {
            id: entry3
            visible: contextmenu.currentEntryId!==""
            text: (showHiddenPlaces ? (qsTranslate("filedialog", "Hide hidden entries")) : (qsTranslate("filedialog", "Show hidden entries")))
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        target: entry3
                        height: 0
                    }
                }
            ]
            onTriggered:
                showHiddenPlaces = !showHiddenPlaces
        }

        PQMenuSeparator {
            id: sep1
            states: [
                State {
                    when: contextmenu.currentEntryId==""
                    PropertyChanges {
                        target: sep1
                        height: 0
                    }
                }
            ]
        }

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
    }

    // we can load them asynchronously to speed up showing the actual file dialog
    Timer {
        interval: 10
        running: true
        onTriggered: {
            loadPlaces()
            loadDevices()
        }
    }

    function loadDevices() {

        var s = PQCScriptsFileDialog.getDevices()

        var tmp = []

        // for the heading
        tmp.push([qsTranslate("filedialog", "Storage Devices"), "", "", ""])

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

        var upl = PQCScriptsFileDialog.getPlaces()

        var tmp = []

        // for the heading
        tmp.push([qsTranslate("filedialog", "Bookmarks"), "", "", ""])

        for(var i = 0; i < upl.length; i+=5)
            tmp.push([upl[i],       // folder
                      upl[i+1],     // path
                      upl[i+2],     // icon
                      upl[i+3],     // id
                      upl[i+4]])    // hidden

        entries_favorites = tmp

    }

}
