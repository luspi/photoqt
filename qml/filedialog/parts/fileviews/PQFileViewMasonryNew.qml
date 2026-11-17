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

    Component.onDestruction:
        PQCNotify.filedialogBusyLoading(false)

    signal addToColumn(var col, var dat)
    signal makeItemVisible(var col, var row)
    signal clearAll()

    property bool firstStart: true

    property string cachePath: ""
    property real cacheContentY: 0.
    property int cacheCurrentIndex: -1

    property int model: 0
    onModelChanged: {

        cacheCurrentIndex = PQGlobalItems.filedialogFileview.currentIndex

        // empty model, clear everything
        if(model == 0) {
            clearAll()
            return
        }

        if(firstStart) {
            // the setup is called from the onWidthChanged signal below!
            firstStart = false;
        } else
            setupData()

    }

    // recreate layout with a delay
    onWidthChanged: {
        delayPrepareLayout.restart()
    }

    // the current index
    property int currentIndex: -1
    // when changed, ensure new item is visible
    onCurrentIndexChanged: {
        if(!masonryview.flicking)
            ensureCurrentItemIsVisible()
    }

    ScrollBar.vertical: PQVerticalScrollBar { id: view_scroll }

    onContentYChanged: {
        // this check makes sure that value is not reset when a directory is reloaded due to a change
        if(contentY > 0)
            cacheContentY = contentY
    }

    PQScrollManager {
        id: scrollmanager
        flickable: masonryview
        cursorShape: Qt.PointingHandCursor
    }

    property int numColumns: 0
    property int columnWidth: 0
    property bool listviewsReady: false

    property int listviewMaxHeight: 0

    Row {

        id: mainrow

        x: 0

        // Counteract the outer Flickable's movement
        y: masonryview.contentY

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
                    masonryview.listviewsReady = true
                }

                Connections {

                    target: masonryview

                    // add new entry to specified column
                    function onAddToColumn(col, dat) {
                        if(col === lv.modelData)
                            mdl.append(dat)
                    }

                    // ensure that the specified item is visible
                    function onMakeItemVisible(col, row) {

                        // not this column
                        if(col !== lv.modelData)
                            return

                        // invalid row
                        if(row < 0 || row >= mdl.count)
                            return

                        // disable scrollmanager
                        // THIS IS IMPORTANT! otherwise there is a 30px offset when ensuring items are visible!
                        scrollmanager.interactive = false

                        // the current item
                        var item = mdl.get(row)

                        // the target y position, unchanged by default
                        var targetY = masonryview.contentY

                        // if item extends above the viewport
                        if(item.offsetY < masonryview.contentY) {

                            targetY = item.offsetY

                        // if item extends below the viewport
                        } else if(item.offsetY+item.itemHeight > masonryview.contentY+masonryview.height) {

                            targetY = item.offsetY+item.itemHeight - masonryview.height

                        // if item is fully visible (do nothing)
                        } else {

                            scrollmanager.interactive = true
                            return

                        }

                        // don't attempt to display an item taller than the viewport!
                        if(item.itemHeight > masonryview.height)
                            targetY = item.offsetY

                        // set target y bound to Flickable boundaries
                        masonryview.contentY = Math.max(0, Math.min(targetY, masonryview.contentHeight-masonryview.height))

                        scrollmanager.interactive = true
                    }

                    function onClearAll() {
                        mdl.clear()
                    }
                }

                delegate: viewentry

                // follow the outer Flickable to scroll all together evenly
                contentY: lv.originY + (masonryview.contentY - masonryview.originY)

                // allow enough scroll range, even for shorter columns
                bottomMargin: masonryview.contentHeight

                // preload delegates around the viewport
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
            required property int offsetY
            required property int itemHeight
            required property string fileSize
            property int numberFilesInsideFolder: 0

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

            Connections {
                target: PQCFileFolderModel
                function onNewNumberFilesInFolder(path : string, num : int) {
                    if(deleg.path === path)
                        deleg.numberFilesInsideFolder = num
                }
            }

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
                                (deleg.isSelected||deleg.isHovered ? Math.min(50, deleg.height) :
                                                                     (deleg.height > 50 ? 30 : 0))
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

    property list<int> currentColHeights: []
    property var currentColIndices: ({})

    Connections {

        target: PQCFileFolderModel

        function onNewMasonryData(col : int, dat : var, colHeights : list<int>, colIndices : var) {
            masonryview.currentColHeights = colHeights
            masonryview.currentColIndices = colIndices
            masonryview.addToColumn(col, dat)
            masonryview.updateContentHeight()
        }

        function onMasonryDataLoadingCompleted() {
            PQCNotify.filedialogBusyLoading(false)
            masonryview.updateContentHeight()

            // same folder reloaded
            if(PQCFileFolderModel.folderFileDialog === cachePath) {

                // restore position
                masonryview.contentY = cacheContentY
                PQGlobalItems.filedialogFileview.currentIndex = cacheCurrentIndex

            // new folder loaded
            } else {

                // reset position
                cachePath = PQCFileFolderModel.folderFileDialog
                cacheContentY = 0.
                cacheCurrentIndex = -1

            }

        }

    }

    Connections {

        target: PQCSettings

        function onFiledialogThumbnailSizeFollowsGlobalThumbnailsChanged() {
            delayPrepareLayout.restart()
        }

        function onThumbnailsSizeChanged() {
            delayPrepareLayout.restart()
        }

        function onFiledialogZoomChanged() {
            delayPrepareLayout.restart()
        }

    }

    function updateContentHeight() {
        for(let i = 0; i < numColumns; ++i)
            masonryview.listviewMaxHeight = Math.max(masonryview.listviewMaxHeight, currentColHeights[i])
    }

    Timer {
        id: delayPrepareLayout
        interval: 500
        onTriggered:
            prepareLayout()
    }

    Timer {
        id: callPrepareLayout
        interval: 50
        onTriggered:
            prepareLayout()
    }

    function prepareLayout() {

        if(width < 5) {
            callPrepareLayout.restart()
            return
        }

        PQCNotify.filedialogBusyLoading(true)

        var _w = (PQCSettings.filedialogThumbnailSizeFollowsGlobalThumbnails ? 10+PQCSettings.thumbnailsSize : 10+PQCSettings.filedialogZoom*10)
        var nc = Math.floor(width/_w)
        var cw = width/nc

        numColumns = nc
        columnWidth = cw

        setupData()

    }

    Timer {
        id: callSetup
        interval: 50
        onTriggered:
            setupData()
    }

    function setupData() {

        if(numColumns == 0 || !listviewsReady) {
            callSetup.restart()
            return
        }

        clearAll()
        listviewMaxHeight = 0

        PQCNotify.filedialogBusyLoading(true)

        PQCFileFolderModel.generateDataForMasonryView(PQCFileFolderModel.folderFileDialog, numColumns, columnWidth)

    }

    function goDownARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = 0
        else
            PQGlobalItems.filedialogFileview.currentIndex = PQCFileFolderModel.navigateMasonryColumn(PQGlobalItems.filedialogFileview.currentIndex, 1)

    }

    function goDownSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = 0
        else
            PQGlobalItems.filedialogFileview.currentIndex = PQCFileFolderModel.navigateMasonryColumn(PQGlobalItems.filedialogFileview.currentIndex, 5)

    }

    function goUpARow() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = currentColIndices[0][currentColIndices[0].length-1]
        else
            PQGlobalItems.filedialogFileview.currentIndex = PQCFileFolderModel.navigateMasonryColumn(PQGlobalItems.filedialogFileview.currentIndex, -1)

    }

    function goUpSomeRows() {

        if(PQGlobalItems.filedialogFileview.currentIndex === -1)
            PQGlobalItems.filedialogFileview.currentIndex = currentColIndices[0][currentColIndices[0].length-1]
        else
            PQGlobalItems.filedialogFileview.currentIndex = PQCFileFolderModel.navigateMasonryColumn(PQGlobalItems.filedialogFileview.currentIndex, -5)

    }

    function ensureCurrentItemIsVisible() {

        var curColRow = PQCFileFolderModel.masonryGetRowCol(PQGlobalItems.filedialogFileview.currentIndex)
        if(curColRow[0] === -1)
            return

        makeItemVisible(curColRow[0], curColRow[1])

    }

}
