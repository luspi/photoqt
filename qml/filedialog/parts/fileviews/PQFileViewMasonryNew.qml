/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

Flickable {

    id: masonryview

    width: parent.width
    height: parent.height

    contentHeight: Math.max(height, listviewMaxHeight)

    boundsBehavior: Flickable.StopAtBounds

    signal handleEntriesMouseEnter(var index, var currentPath, var fileThumbStatus, var fileInfo, var isFolder,
                                   var numberFilesInsideFolder, var currentFolderThumbNum)
    signal handleEntriesMouseExit(var index)
    signal handleEntriesMouseClick(var index, var currentPath, var isFolder, var mouseModifiers, var mouseButton)

    property string cachePath: ""

    Component.onDestruction:
        PQCNotify.filedialogBusyLoading(false)

    property int model: 0
    onModelChanged: {

        if(model == 0) {
            for(var i = 0; i < masonryview.numColumns; ++i) {
                listviews[i].clear()
            }
            return
        }

        masonryview.setupData()

        // reset position
        // masonryview.contentY = 0
        // cachePath = cacheKey
        // cacheContentY = 0

    }

    property int currentIndex: -1
    onCurrentIndexChanged: {
        // TODO
    }

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

    // onContentYChanged: {
    //     // this check makes sure that value is not reset when a directory is reloaded due to a change
    //     if(contentY > 0)
    //         cacheContentY = contentY
    // }

    PQScrollManager {
        flickable: masonryview
        cursorShape: Qt.PointingHandCursor
    }

    property int numColumns: 0
    property int columnWidth: 0
    property var listviews: ({})

    property int listviewMaxHeight: 0

    Row {

        id: mainrow

        x: 0

        // Counteract the outer Flickable's movement
        y: masonryview.contentY - masonryview.originY

        width: masonryview.width
        height: masonryview.contentHeight

        Repeater {

            id: columnRepeater

            model: masonryview.numColumns

            ListView {

                id: lv

                required property int modelData

                width: masonryview.columnWidth
                height: masonryview.height

                clip: true
                interactive: false

                model: ListModel { id: mdl }

                Component.onCompleted: {
                    masonryview.listviews[modelData] = mdl
                }

                delegate: viewentry

                // Follow the outer Flickable
                contentY: lv.originY + (masonryview.contentY - masonryview.originY)

                // Allow enough scroll range, even for shorter columns
                bottomMargin: masonryview.contentHeight

                // Preload delegates around the viewport
                cacheBuffer: masonryview.height

            }

        }

    }

    Component {
        id: viewentry

        Rectangle {

            id: deleg

            required property int runningIndex
            required property string path
            required property bool isFolder
            required property int itemHeight
            required property string fileSize
            required property int numberFilesInsideFolder

            property string fileName: decodeURIComponent(PQCScriptsFilesPaths.getFilename(path))
            property bool isFileCut: PQGlobalItems.filedialogFileview.currentCuts.indexOf(runningIndex) > -1
            property bool onNetwork: isFolder ? PQCScriptsFilesPaths.isOnNetwork(path) : PQGlobalItems.filedialogFileview.currentFolderOnNetwork

            property bool isHovered: PQGlobalItems.filedialogFileview.currentIndex===runningIndex
            property bool isSelected: PQCConstants.filedialogCurrentSelection.indexOf(runningIndex)>-1

            property int folderthumbCurNum: 0

            width: masonryview.columnWidth
            height: itemHeight
            color: palette.base

            border.width: PQCSettings.filedialogElementPadding
            border.color: PQCLook.baseBorder

            Item {
                id: dragHandler

                anchors.fill: parent

            }

            // the file type icon
            PQFileIcon {

                id: fileicon

                gridlike: true

                isFileCut: deleg.isFileCut
                onNetwork: deleg.onNetwork
                isFolder: deleg.isFolder
                currentPath: deleg.path

                x: PQCSettings.filedialogElementPadding
                y: PQCSettings.filedialogElementPadding
                width: deleg.width - 2*PQCSettings.filedialogElementPadding
                height: deleg.height - 2*PQCSettings.filedialogElementPadding

            }

            // the file thumbnail
            Loader {
                id: filethumbldr
                asynchronous: true

                active: !deleg.isFolder

                sourceComponent:
                PQFileThumb {

                    id: filethumb

                    x: PQCSettings.filedialogElementPadding
                    y: PQCSettings.filedialogElementPadding
                    width: deleg.width - 2*PQCSettings.filedialogElementPadding
                    height: deleg.height - 2*PQCSettings.filedialogElementPadding

                    isFileCut: deleg.isFileCut
                    isFolder: false
                    onNetwork: deleg.onNetwork
                    currentPath: deleg.path
                    myIndex: deleg.runningIndex

                    clip: true

                    onHideFileIcon: {
                        fileicon.source = ""
                    }

                    onShowFileIcon: {
                        fileicon.source = fileicon.sourceString
                    }

                }
            }

            Loader {

                id: folderloader

                active: deleg.isFolder

                sourceComponent:
                Item {

                    x: PQCSettings.filedialogElementPadding
                    y: PQCSettings.filedialogElementPadding
                    width: deleg.width - 2*PQCSettings.filedialogElementPadding
                    height: deleg.height - 2*PQCSettings.filedialogElementPadding

                    // the folder thumbnails
                    PQFolderThumb {

                        id: folderthumb

                        isFileCut: deleg.isFileCut
                        myIndex: deleg.runningIndex
                        isFolder: true

                        anchors.fill: parent

                        onCurnumChanged:
                            deleg.folderthumbCurNum = curnum

                        onHideFileIcon: {
                            fileicon.source = ""
                        }

                    }

                    // how many files inside folder
                    Rectangle {
                        id: numberOfFilesInsideFolder_cont
                        x: (deleg.width-width)-5
                        y: 5
                        width: numberOfFilesInsideFolder.width + 20
                        height: 30
                        radius: 5
                        color: palette.text
                        opacity: 0.8
                        visible: numberOfFilesInsideFolder.text !== "" && numberOfFilesInsideFolder.text !== "0"

                        PQText {
                            id: numberOfFilesInsideFolder
                            x: 10
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold
                            color: palette.base
                            elide: Text.ElideMiddle
                            text: deleg.numberFilesInsideFolder
                        }
                    }

                    // which # thumbnail inside folder
                    Rectangle {
                        id: numberThumbInsideFolderCont
                        x: (deleg.width-width)/2
                        y: 10
                        width: numberThumbInsideFolder.width + 10
                        height: 20
                        radius: 3
                        color: palette.text
                        opacity: 0.6
                        visible: folderthumb.curnum>0 && folderthumb.visible

                        PQTextS {
                            id: numberThumbInsideFolder
                            x: 5
                            y: (parent.height-height)/2-2
                            font.weight: PQCLook.fontWeightBold
                            color: palette.base
                            elide: Text.ElideMiddle
                            text: "#"+folderthumb.curnum
                        }
                    }
                }

            }

            /************************************************************/
            // FILE NAME

            // the filename
            Loader {

                active: PQCSettings.filedialogLabelsShowMasonry||deleg.isFolder

                sourceComponent:
                Rectangle {
                    id: filename_label
                    width: deleg.width
                    height: deleg.height>100 ?
                                (Math.min(50, deleg.height/4) + (deleg.isSelected||deleg.isHovered ? 10 : 0)) :
                                (deleg.isSelected||deleg.isHovered ? Math.min(50, deleg.height) : 0)
                    Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    y: deleg.height-height
                    color: deleg.isSelected ? palette.text : (deleg.isHovered ? palette.alternateBase : palette.base )
                    Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                    opacity: 0.8
                    clip: true

                    PQText {
                        id: filename
                        anchors.fill: parent
                        anchors.margins: 5
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        maximumLineCount: 2
                        elide: Text.ElideMiddle
                        text: deleg.fileName
                        color: palette.text
                        Behavior on color { enabled: !PQCSettings.generalDisableAllAnimations; ColorAnimation { duration: 200 } }
                    }

                    Image {
                        x: (parent.width-width-5)
                        y: (parent.height-height-5)
                        source: "image://svg/:/light/folder.svg"
                        height: 16
                        mipmap: true
                        width: height
                        opacity: 0.3
                        visible: deleg.isFolder && deleg.folderthumbCurNum!==0
                    }

                }

            }

            /************************************************************/
            // HIGHLIGHT/SELECT

            PQHighlightMarker {
                anchors.margins: 0
                opacity: !deleg.isSelected ? 0.5 : 1
                visible: deleg.isHovered || deleg.isSelected
            }

            /************************************************************/

            // mouse area handling general mouse events
            PQMouseArea {

                id: masonrymousearea

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Connections {
                    target: PQCConstants
                    function onWhichContextMenusOpenChanged() {
                        if(PQCConstants.isContextmenuOpen("fileviewentry"))
                            masonrymousearea.closeTooltip()
                    }
                }

                acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.BackButton|Qt.ForwardButton

                drag.target: PQCSettings.filedialogDragDropFileviewMasonry ? dragHandler : undefined

                drag.onActiveChanged: {
                    if(drag.active) {
                        // store which index is being dragged and that the entry comes from the userplaces (reordering only)
                        PQGlobalItems.filedialogPlaces.dragItemIndex = deleg.runningIndex
                        PQGlobalItems.filedialogPlaces.dragReordering = false
                        PQGlobalItems.filedialogPlaces.dragItemId = deleg.path
                    }
                    deleg.Drag.drop();
                    if(!drag.active) {
                        // reset variables used for drag/drop
                        PQGlobalItems.filedialogPlaces.dragItemIndex = -1
                        PQGlobalItems.filedialogPlaces.dragItemId = ""
                    }
                }

                onPressed: {

                    if(!PQCConstants.isContextmenuOpen("fileviewentry"))
                        PQGlobalItems.filedialogFileview.currentIndex = deleg.runningIndex

                    // we only need this when a potential drag might occur
                    // otherwise no need to load this drag thumbnail
                    deleg.dragImageSource = "image://dragthumb/" + deleg.path + ":://::" + (PQGlobalItems.filedialogFileview.currentFileSelected ? PQCConstants.filedialogCurrentSelection.length : 1)

                }

                onEntered: {

                    tooltip = ""
                    tooltip = PQGlobalItems.filedialogFileview.handleEntriesMouseEnter(deleg.runningIndex, deleg.path, fileicon.status, deleg.fileSize,
                                            deleg.isFolder, deleg.numberFilesInsideFolder, deleg.folderthumbCurNum)

                }

                onExited: {
                    if(!selectmouse.containsMouse)
                        PQGlobalItems.filedialogFileview.handleEntriesMouseExit(deleg.runningIndex)
                }

                onClicked: (mouse) => {

                    PQGlobalItems.filedialogFileview.handleEntriesMouseClick(deleg.runningIndex, deleg.path, deleg.isFolder, mouse.modifiers, mouse.button)

                }

            }

            /************************************************************/
            // + ICON TO SELECT/ - ICON TO DESELECT
            // has to be on top of main mouse area

            Rectangle {
                id: selectedornot
                x: 5
                y: deleg.height>40 ? 5 : 0
                width: 30
                height: 30
                radius: 5

                color: "#bbbbbb"
                opacity: (selectmouse.containsMouse||PQCConstants.filedialogCurrentSelection.indexOf(deleg.runningIndex)!==-1)
                                ? 0.8
                                : (PQGlobalItems.filedialogFileview.currentIndex===deleg.runningIndex
                                        ? 0.8 : 0)
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    source: (PQCConstants.filedialogCurrentSelection.indexOf(deleg.runningIndex)!==-1 ? ("image://svg/:/" + PQCLook.iconShade + "/deselectfile.svg") : ("image://svg/:/" + PQCLook.iconShade + "/selectfile.svg"))
                    mipmap: true
                    opacity: selectmouse.containsMouse ? 0.8 : 0.4
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                    PQMouseArea {
                        id: selectmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(PQCConstants.filedialogCurrentSelection.indexOf(deleg.runningIndex)===-1) {
                                PQGlobalItems.filedialogFileview.shiftClickIndexStart = deleg.runningIndex
                                PQCConstants.filedialogCurrentSelection.push(deleg.runningIndex)
                                PQCConstants.filedialogCurrentSelectionChanged()
                            } else {
                                PQGlobalItems.filedialogFileview.shiftClickIndexStart = -1
                                PQCConstants.filedialogCurrentSelection = PQCConstants.filedialogCurrentSelection.filter(item => item!==deleg.runningIndex)
                            }
                        }
                        onEntered: {
                            PQGlobalItems.filedialogFileview.currentIndex = deleg.runningIndex
                        }
                    }
                }

            }

            Drag.active: masonrymousearea.drag.active
            Drag.mimeData: {
                if(!PQGlobalItems.filedialogFileview.currentFileSelected) {
                    return ({"text/uri-list": encodeURI("file:"+deleg.path)})
                } else {
                    var uris = []
                    for(var i in PQCConstants.filedialogCurrentSelection)
                        uris.push(encodeURI("file:" + PQCFileFolderModel.entriesFileDialog[PQCConstants.filedialogCurrentSelection[i]]))
                    return ({"text/uri-list": uris})
                }
            }
            Drag.dragType: Drag.Automatic

            // this is set in the mousearea's onPressed signal
            // this avoid loading all drag thumbnails at the start
            property string dragImageSource: ""
            Drag.imageSource: dragImageSource

        }
    }

    Connections {

        target: PQCFileFolderModel

        function onNewMasonryData(col : int, dat : var, colHeights : list<int>) {
            masonryview.listviews[col].append(dat)
            for(let i = 0; i < numColumns; ++i)
                masonryview.listviewMaxHeight = Math.max(masonryview.listviewMaxHeight, colHeights[i])
        }

        function onMasonryDataLoadingCompleted() {
            PQCNotify.filedialogBusyLoading(false)
        }

    }

    Timer {
        id: callSetup
        interval: 50
        onTriggered:
            setupData()
    }

    function setupData() {

        if(width < 5) {
            callSetup.restart()
            return
        }

        for(let i = 0; i < masonryview.numColumns; ++i)
            masonryview.listviews[i].clear()
        listviewMaxHeight = 0

        var _w = (PQCSettings.filedialogThumbnailSizeFollowsGlobalThumbnails ? 10+PQCSettings.thumbnailsSize : 10+PQCSettings.filedialogZoom*10)
        var nc = Math.floor(width/_w)
        var cw = width/nc

        numColumns = nc
        columnWidth = cw

        PQCNotify.filedialogBusyLoading(true)

        PQCFileFolderModel.generateDataForMasonryView(PQCFileFolderModel.folderFileDialog, nc, cw)

    }

    function goDownARow() {

        // TODO

    }

    function goDownSomeRows() {

        // TODO

    }

    function goUpARow() {

        // TODO

    }

    function goUpSomeRows() {

        // TODO

    }

    function ensureCurrentItemIsVisible() {

        // TODO

    }

}
