import QtQuick
import QtCore
import QtQuick.Controls

import "../elements"

Item {

    id: places_top

    height: parent.height-fd_breadcrumbs.height-fd_tweaks.height

    clip: true

    property var entries_standard: [
        [qsTranslate("filedialog", "Standard"), qsTranslate("filedialog", "Standard")],
        [StandardPaths.displayName(StandardPaths.HomeLocation), PQCScriptsFilesPaths.cleanPath(StandardPaths.writableLocation(StandardPaths.HomeLocation)), "user-home"],
        [StandardPaths.displayName(StandardPaths.DesktopLocation), PQCScriptsFilesPaths.cleanPath(StandardPaths.writableLocation(StandardPaths.DesktopLocation)), "user-desktop"],
        [StandardPaths.displayName(StandardPaths.PicturesLocation), PQCScriptsFilesPaths.cleanPath(StandardPaths.writableLocation(StandardPaths.PicturesLocation)), "folder-pictures"],
        [StandardPaths.displayName(StandardPaths.DownloadLocation), PQCScriptsFilesPaths.cleanPath(StandardPaths.writableLocation(StandardPaths.DownloadLocation)), "folder-downloads"]
    ]
    property var entries_favorites: []
    property var entries_devices: []

    property var entries: [entries_standard, entries_favorites, entries_devices]

    property var hoverIndex: [-1,-1,-1]
    property var pressedIndex: [-1,-1,-1]

    property int availableHeight: height - fd_tweaks.zoomMoveUpHeight - (PQCScriptsConfig.amIOnWindows() ? (view_standard.height+10) : 0)

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
                id: view_standard
                visible: PQCScriptsConfig.amIOnWindows()
                width: parent.width-5
                clip: true
                orientation: ListView.Vertical
                model: entries_standard.length
                property int part: 0
                delegate: viewcomponent
                boundsBehavior: Flickable.StopAtBounds
            }

            Item {
                visible: PQCScriptsConfig.amIOnWindows()
                width: parent.width
                height: 20
                Rectangle {
                    y: 19
                    width: parent.width
                    height: 1
                    color: PQCLook.baseColorActive
                }
            }

            ListView {
                id: view_favorites
                width: parent.width-5
                height: contentHeight
                clip: true
                orientation: ListView.Vertical
                model: entries_favorites.length
                property int part: 1
                delegate: viewcomponent
                boundsBehavior: Flickable.StopAtBounds
            }

            Item {
                width: parent.width
                height: 20
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
            height: 35

            property int part: parent.parent.part
            property var entry: entries[part][index]

            color: hoverIndex[part]===index ? (pressedIndex[part]===index ? PQCLook.baseColorActive : PQCLook.baseColorHighlight) : PQCLook.baseColor
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
                        source: ((entry[2]!==undefined&&index>0) ? ("image://theme/" + entry[2]) : "")

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

                        text: entry[0]

                    }

                    PQText {

                        id: entrysize

                        visible: deleg.part==2 && index>0
                        height: deleg.height

                        // vertically center text
                        verticalAlignment: Qt.AlignVCenter

                        text: entry[3] + " GB"

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

                text: index===0 ? "" : (PQCScriptsFilesPaths.pathWithNativeSeparators(entry[1]) + (deleg.part == 2 ? ("\n"+entrysize.text + " (" + entry[4] + ")") : ""))

                onPressed: {
                    pressedIndex[deleg.part] = index
                    pressedIndexChanged()
                }
                onReleased: {
                    pressedIndex[deleg.part] = -1
                    pressedIndexChanged()
                }

                // clicking an entry loads the location or shows a context menu (depends on which button was used)
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        console.log("load:", entry[1])
//                        filedialog_top.setCurrentDirectory(locs[(index-1)*3 + 1])
                    else {
//                        var pos = standard_top.mapFromItem(parent, mouse.x, mouse.y)
//                        filedialog_top.leftPanelPopupGenericRightClickMenu(Qt.point(standard_top.x+pos.x, standard_top.y+pos.y))
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

            }

        }
    }

    Component.onCompleted: {
        loadPlaces()
        loadDevices()
    }

    function loadDevices() {

        var s = PQCScriptsFileDialog.getDevices()

        var tmp = []

        // for the heading
        tmp.push([qsTranslate("filedialog", "Devices"), "", "", ""])

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
        tmp.push([qsTranslate("filedialog", "Places"), "", "", ""])

        for(var i = 0; i < upl.length; i+=5)
            tmp.push([upl[i],       // folder
                      upl[i+1],     // path
                      upl[i+2],     // icon
                      upl[i+3],     // id
                      upl[i+4]])    // hidden

        entries_favorites = tmp

    }

}
